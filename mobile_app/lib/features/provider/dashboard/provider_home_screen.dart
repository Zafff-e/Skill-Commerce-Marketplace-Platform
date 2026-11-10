import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/asset_paths.dart';
import '../../../core/localization/app_strings.dart';
import '../../../core/localization/language_cubit.dart';
import '../../../core/network/skill_commerce_repository.dart';
import '../../../core/realtime/signalr_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/models/polyglot_models.dart';
import '../../auth/logic/role_cubit.dart';
import '../materials/ad_hoc_materials_sheet.dart';
import '../requests/incoming_request_modal.dart';

class ProviderHomeScreen extends StatefulWidget {
  final VoidCallback onOpenSeekerMode;

  const ProviderHomeScreen({super.key, required this.onOpenSeekerMode});

  @override
  State<ProviderHomeScreen> createState() => _ProviderHomeScreenState();
}

class _ProviderHomeScreenState extends State<ProviderHomeScreen> {
  bool _isOnline = true;
  bool _isLoading = true;
  List<BookingModel> _bookings = [];
  List<CustomJobModel> _availableJobs = [];
  BookingModel? _activeJob;

  @override
  void initState() {
    super.initState();
    _loadProviderData();
  }

  Future<void> _loadProviderData() async {
    final repo = context.read<SkillCommerceRepository>();
    final list = await repo.getMyBookings(asRole: 'provider');
    final customJobs = await repo.getCustomJobs();
    if (mounted) {
      setState(() {
        _bookings = list;
        _availableJobs = customJobs.where((j) => j.status == 'Open').toList();
        _activeJob = list.isNotEmpty
            ? list.firstWhere(
                (b) => b.status != 'Completed' && b.status != 'Cancelled',
                orElse: () => list.first,
              )
            : null;
        _isLoading = false;
      });
    }
  }

  void _showSubmitProposalSheet(CustomJobModel job) {
    final strings = AppStrings.of(context);
    final isBn = strings.isBengali;
    final priceController = TextEditingController(text: job.budget.toInt().toString());
    final minsController = TextEditingController(text: '15');
    final noteController = TextEditingController(
      text: isBn ? 'দক্ষতার সাথে কাজটি সম্পন্ন করবো এবং কাজের ওয়ারেন্টি দিবো।' : 'Will complete with full satisfaction and 3-month guarantee.',
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  strings.submitProposal,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(ctx)),
              ],
            ),
            const Divider(),
            const SizedBox(height: 8),
            Text(job.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            Text(
              'গ্রাহকের বাজেট: ৳ ${strings.formatNumber(job.budget.toInt())} • ${job.location}',
              style: const TextStyle(fontSize: 12, color: AppColors.slateMuted),
            ),
            const SizedBox(height: 14),
            Text(isBn ? 'আপনার প্রস্তাবিত মূল্য (টাকা)' : 'Your Bid Amount (BDT)', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            const SizedBox(height: 6),
            TextField(
              controller: priceController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                prefixText: '৳ ',
                isDense: true,
              ),
            ),
            const SizedBox(height: 12),
            Text(isBn ? 'কত মিনিটে পৌঁছাতে পারবেন?' : 'Estimated arrival time (minutes)', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            const SizedBox(height: 6),
            TextField(
              controller: minsController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                isDense: true,
                suffixText: isBn ? 'মিনিট' : 'mins',
              ),
            ),
            const SizedBox(height: 12),
            Text(isBn ? 'কাজের বার্তা / স্পেশাল নোট' : 'Message to customer', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            const SizedBox(height: 6),
            TextField(
              controller: noteController,
              maxLines: 2,
              decoration: const InputDecoration(isDense: true),
            ),
            const SizedBox(height: 18),
            ElevatedButton(
              onPressed: () async {
                final proposed = double.tryParse(priceController.text.trim()) ?? job.budget;
                final mins = int.tryParse(minsController.text.trim()) ?? 15;
                final repo = context.read<SkillCommerceRepository>();

                await repo.submitJobProposal(
                  jobId: job.jobId,
                  providerId: 1,
                  providerName: 'মোঃ রফিকুল ইসলাম (Rafiqul)',
                  providerAvatarKey: 'ac_technician',
                  proposedAmount: proposed,
                  arrivalMins: mins,
                  note: noteController.text.trim(),
                  phone: '+8801711223344',
                );

                if (ctx.mounted) Navigator.pop(ctx);
                _loadProviderData();

                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(strings.proposalSuccess),
                      backgroundColor: AppColors.forestGreen,
                    ),
                  );
                }
              },
              child: Text(strings.submitProposal),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleAdvanceState(String action) async {
    if (_activeJob == null) return;
    final repo = context.read<SkillCommerceRepository>();
    final signalR = context.read<SignalRService>();

    final updated = await repo.advanceBookingStatus(
      bookingId: _activeJob!.bookingId,
      action: action,
    );

    // If starting travel, emit simulated location update
    if (action == 'start-travel') {
      await signalR.sendLocation(
        bookingId: updated.bookingId,
        latitude: updated.latitude + 0.003,
        longitude: updated.longitude + 0.002,
      );
    }

    if (!mounted) return;
    setState(() {
      _activeJob = updated;
    });

    final isBn = AppStrings.of(context).isBengali;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isBn
              ? 'কাজের অবস্থা পরিবর্তন হয়েছে: ${updated.status}'
              : 'Status updated to: ${updated.status}',
        ),
      ),
    );
  }

  void _simulateIncomingRequest() {
    IncomingRequestModal.show(
      context,
      customerName: 'তানজিলা হক (Tanjila Haque)',
      serviceName: 'ইলেকট্রিশিয়ান ও শর্ট সার্কিট মেরামত',
      address: 'রোড ৭, ব্লক সি, নিকেতন, গুলশান',
      distanceKm: 1.2,
      estimatedEarnings: 540.0, // (600 - 10%)
      isUrgent: true,
    ).then((accepted) {
      if (accepted == true) {
        _loadProviderData();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final isBn = strings.isBengali;

    return Scaffold(
      backgroundColor: AppColors.softOffWhite,
      appBar: AppBar(
        titleSpacing: 16,
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundImage: AssetImage(AssetPaths.getPath('ac_technician')),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'মোঃ রফিকুল ইসলাম',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
                Text(
                  strings.currentModeProvider,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.forestGreen,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          // 1-Tap Dual-Role Switcher Pill
          Padding(
            padding: const EdgeInsets.only(right: 6),
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () {
                context.read<RoleCubit>().toggleRole();
                widget.onOpenSeekerMode();
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: AppColors.forestGreen.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.forestGreen, width: 1),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.sync_alt,
                      size: 14,
                      color: AppColors.forestGreen,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      isBn ? 'গ্রাহক মোড' : 'Seeker',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: AppColors.forestGreen,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // 1-Tap Language Switcher
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () => context.read<LanguageCubit>().toggleLanguage(),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  isBn ? 'EN' : 'বাং',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.forestGreen),
            )
          : RefreshIndicator(
              onRefresh: _loadProviderData,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Availability Toggle Card (Redis Heartbeat)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.cardBorder),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: _isOnline
                                    ? AppColors.successGreen
                                    : Colors.grey,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _isOnline
                                      ? (isBn
                                            ? 'আপনি অনলাইনে আছেন'
                                            : 'You are Online')
                                      : (isBn
                                            ? 'আপনি অফলাইনে আছেন'
                                            : 'You are Offline'),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                                Text(
                                  _isOnline
                                      ? (isBn
                                            ? 'নতুন কাজের অনুরোধ গ্রহণ করছেন'
                                            : 'Ready to receive jobs')
                                      : (isBn
                                            ? 'কোনো অনুরোধ পাঠানো হবে না'
                                            : 'Not receiving jobs'),
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Switch(
                          value: _isOnline,
                          activeThumbColor: AppColors.forestGreen,
                          onChanged: (val) {
                            setState(() => _isOnline = val);
                          },
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 14),

                  // Today's Earnings Summary Cards
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.cardBorder),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                isBn ? 'আজকের আয়' : "Today's Earnings",
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.slateMuted,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '৳ ${strings.formatNumber(1620)}',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.forestGreen,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.cardBorder),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                isBn ? 'কাজ সম্পন্ন' : 'Completed Jobs',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.slateMuted,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${strings.formatNumber(_bookings.where((b) => b.status == 'Completed').isNotEmpty ? _bookings.where((b) => b.status == 'Completed').length : 3)} টি',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.slateNavy,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.cardBorder),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                isBn ? 'রেটিং' : 'Rating',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.slateMuted,
                                ),
                              ),
                              const SizedBox(height: 4),
                              const Row(
                                children: [
                                  Icon(
                                    Icons.star,
                                    color: Colors.amber,
                                    size: 16,
                                  ),
                                  SizedBox(width: 2),
                                  Text(
                                    '4.9',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Active Assigned Job Card (State Machine execution)
                  Text(
                    isBn ? 'চলতি কাজ (Active Job)' : 'Active Job',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),

                  if (_activeJob != null) ...[
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: AppColors.forestGreen,
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.forestGreen.withValues(
                              alpha: 0.06,
                            ),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.forestGreen.withValues(
                                    alpha: 0.12,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  'স্ট্যাটাস: ${_activeJob!.status}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                    color: AppColors.forestGreen,
                                  ),
                                ),
                              ),
                              Text(
                                'বুকিং #${_activeJob!.bookingId}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                  color: AppColors.slateMuted,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 12),

                          Text(
                            _activeJob!.skillName,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.slateNavy,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(
                                Icons.person,
                                size: 14,
                                color: AppColors.slateMuted,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                _activeJob!.customerName,
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: AppColors.slateNavy,
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Icon(
                                Icons.phone,
                                size: 14,
                                color: AppColors.slateMuted,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                _activeJob!.customerPhone,
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: AppColors.slateMuted,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(
                                Icons.location_on,
                                size: 14,
                                color: AppColors.urgentRed,
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  _activeJob!.serviceAddress,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppColors.slateMuted,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),

                          // Consumed Parts in this active job
                          if (_activeJob!.parts.isNotEmpty) ...[
                            const SizedBox(height: 10),
                            const Divider(height: 1),
                            const SizedBox(height: 8),
                            Text(
                              isBn
                                  ? 'যুক্ত করা যন্ত্রাংশসমূহ:'
                                  : 'Attached Parts:',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 4),
                            ..._activeJob!.parts.map(
                              (p) => Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    '• ${p.itemDescription} (${p.quantity}x)',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: AppColors.slateMuted,
                                    ),
                                  ),
                                  Text(
                                    '৳ ${strings.formatNumber(p.lineTotal.toInt())}',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],

                          const SizedBox(height: 14),
                          const Divider(height: 1),
                          const SizedBox(height: 12),

                          // Action Buttons
                          Row(
                            children: [
                              // Add Parts Button
                              Expanded(
                                flex: 2,
                                child: OutlinedButton.icon(
                                  onPressed: () {
                                    AdHocMaterialsSheet.show(
                                      context,
                                      bookingId: _activeJob!.bookingId,
                                    ).then((updated) {
                                      if (updated != null) {
                                        setState(() => _activeJob = updated);
                                      }
                                    });
                                  },
                                  icon: const Icon(
                                    Icons.add_shopping_cart,
                                    size: 16,
                                  ),
                                  label: Text(
                                    strings.addParts,
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                  style: OutlinedButton.styleFrom(
                                    minimumSize: const Size(0, 46),
                                    padding: EdgeInsets.zero,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),

                              // State Machine Transition Action
                              Expanded(
                                flex: 3,
                                child: _buildStateActionButton(context),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ] else ...[
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.cardBorder),
                      ),
                      child: Center(
                        child: Column(
                          children: [
                            const Icon(
                              Icons.check_circle_outline,
                              color: AppColors.forestGreen,
                              size: 40,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              isBn
                                  ? 'এই মুহূর্তে কোনো সক্রিয় কাজ নেই'
                                  : 'No active jobs right now',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],

                  const SizedBox(height: 24),

                  // Available Custom Jobs Nearby (Bidding Opportunities)
                  Text(
                    strings.providerCustomJobs,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),

                  if (_availableJobs.isNotEmpty) ...[
                    ..._availableJobs.map(
                      (job) => Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.cardBorder),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    job.title,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                      color: AppColors.slateNavy,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: AppColors.forestGreen.withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    'বাজেট: ৳ ${strings.formatNumber(job.budget.toInt())}',
                                    style: const TextStyle(
                                      color: AppColors.forestGreen,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              job.description,
                              style: const TextStyle(fontSize: 12, color: AppColors.slateMuted),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Icon(Icons.location_on, size: 14, color: AppColors.urgentRed),
                                const SizedBox(width: 4),
                                Text(
                                  job.location,
                                  style: const TextStyle(fontSize: 11, color: AppColors.slateMuted),
                                ),
                                const Spacer(),
                                ElevatedButton.icon(
                                  onPressed: () => _showSubmitProposalSheet(job),
                                  icon: const Icon(Icons.gavel_rounded, size: 14),
                                  label: Text(
                                    strings.submitProposal,
                                    style: const TextStyle(fontSize: 11),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    minimumSize: const Size(100, 32),
                                    padding: const EdgeInsets.symmetric(horizontal: 8),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ] else ...[
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.cardBorder),
                      ),
                      child: Center(
                        child: Text(
                          isBn ? 'এই মুহূর্তে নতুন কোনো কাজের অফার নেই' : 'No available custom jobs right now',
                          style: const TextStyle(fontSize: 12, color: AppColors.slateMuted),
                        ),
                      ),
                    ),
                  ],

                  const SizedBox(height: 18),

                  // Floating Test Trigger: Simulate Incoming Dispatch Alert
                  ElevatedButton.icon(
                    onPressed: _simulateIncomingRequest,
                    icon: const Icon(Icons.sensors, size: 20),
                    label: Text(
                      isBn
                          ? 'নতুন কাজের রিকোয়েস্ট টেস্ট করুন'
                          : 'Test Incoming Job Radar Alert',
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.urgentAmber,
                      minimumSize: const Size(double.infinity, 48),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildStateActionButton(BuildContext context) {
    final status = _activeJob?.status ?? 'Accepted';
    final strings = AppStrings.of(context);

    if (status == 'Accepted') {
      return ElevatedButton.icon(
        onPressed: () => _handleAdvanceState('start-travel'),
        icon: const Icon(Icons.navigation, size: 16),
        label: Text(strings.startTravel, style: const TextStyle(fontSize: 13)),
        style: ElevatedButton.styleFrom(minimumSize: const Size(0, 46)),
      );
    } else if (status == 'OnTheWay') {
      return ElevatedButton.icon(
        onPressed: () => _handleAdvanceState('arrive'),
        icon: const Icon(Icons.location_on, size: 16),
        label: Text(strings.markArrived, style: const TextStyle(fontSize: 13)),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.emeraldMint,
          minimumSize: const Size(0, 46),
        ),
      );
    } else if (status == 'Arrived') {
      return ElevatedButton.icon(
        onPressed: () => _handleAdvanceState('start-work'),
        icon: const Icon(Icons.build, size: 16),
        label: Text(strings.startWork, style: const TextStyle(fontSize: 13)),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.forestGreen,
          minimumSize: const Size(0, 46),
        ),
      );
    } else if (status == 'InProgress') {
      return ElevatedButton.icon(
        onPressed: () => _handleAdvanceState('complete'),
        icon: const Icon(Icons.check_circle, size: 16),
        label: Text(strings.completeJob, style: const TextStyle(fontSize: 13)),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.forestGreen,
          minimumSize: const Size(0, 46),
        ),
      );
    }

    return ElevatedButton(
      onPressed: null,
      child: Text(strings.statusCompleted),
    );
  }
}
