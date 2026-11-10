import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/asset_paths.dart';
import '../../../core/localization/app_strings.dart';
import '../../../core/network/skill_commerce_repository.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/models/polyglot_models.dart';
import '../bidding/bidding_proposals_modal.dart';
import '../bidding/create_custom_job_modal.dart';
import '../support/dokkho_ai_chat_modal.dart';

class MyBookingsScreen extends StatefulWidget {
  final Function(BookingModel booking) onSelectBookingForTracking;
  final VoidCallback onBackToCatalog;

  const MyBookingsScreen({
    super.key,
    required this.onSelectBookingForTracking,
    required this.onBackToCatalog,
  });

  @override
  State<MyBookingsScreen> createState() => _MyBookingsScreenState();
}

class _MyBookingsScreenState extends State<MyBookingsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<BookingModel> _bookings = [];
  List<CustomJobModel> _customJobs = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final repo = context.read<SkillCommerceRepository>();
    final bookings = await repo.getMyBookings(asRole: 'customer');
    final jobs = await repo.getCustomJobs();

    if (mounted) {
      setState(() {
        _bookings = bookings;
        _customJobs = jobs;
        _isLoading = false;
      });
    }
  }

  List<BookingModel> get _activeBookings =>
      _bookings.where((b) => b.status != 'Completed' && b.status != 'Cancelled').toList();

  List<BookingModel> get _completedBookings =>
      _bookings.where((b) => b.status == 'Completed' || b.status == 'Cancelled').toList();

  void _showInvoiceSheet(BookingModel booking) {
    final strings = AppStrings.of(context);
    final isBn = strings.isBengali;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  isBn ? 'ইনভয়েস ও পেমেন্ট রসিদ' : 'Invoice & Payment Receipt',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(ctx)),
              ],
            ),
            const Divider(),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(strings.laborCharge, style: const TextStyle(fontSize: 14)),
                Text('৳ ${strings.formatNumber(booking.laborAmount.toInt())}', style: const TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
            if (booking.urgencyFee > 0) ...[
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(strings.urgentSurcharge, style: const TextStyle(fontSize: 14, color: AppColors.urgentRed)),
                  Text('৳ ${strings.formatNumber(booking.urgencyFee.toInt())}', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.urgentRed)),
                ],
              ),
            ],
            if (booking.materialsAmount > 0) ...[
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(strings.materialsCharge, style: const TextStyle(fontSize: 14)),
                  Text('৳ ${strings.formatNumber(booking.materialsAmount.toInt())}', style: const TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
            ],
            const SizedBox(height: 10),
            const Divider(),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(strings.totalPayable, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                Text(
                  '৳ ${strings.formatNumber(booking.totalAmount.toInt())}',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: AppColors.forestGreen),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.forestGreen.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.verified, color: AppColors.forestGreen, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    isBn ? 'পেমেন্ট স্ট্যাটাস: পরিশোধিত (Paid)' : 'Payment Status: Paid',
                    style: const TextStyle(color: AppColors.forestGreen, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final isBn = strings.isBengali;

    return Scaffold(
      backgroundColor: AppColors.softOffWhite,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: widget.onBackToCatalog,
        ),
        title: Text(strings.myBookings),
        actions: [
          IconButton(
            icon: const Icon(Icons.support_agent_rounded, color: AppColors.forestGreen),
            tooltip: 'Dokkho AI Assistant',
            onPressed: () => DokkhoAiChatModal.show(context),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.forestGreen,
          unselectedLabelColor: AppColors.slateMuted,
          indicatorColor: AppColors.forestGreen,
          indicatorWeight: 3,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          tabs: [
            Tab(text: strings.activeBookings),
            Tab(text: strings.customJobs),
            Tab(text: strings.completedBookings),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.forestGreen))
          : TabBarView(
              controller: _tabController,
              children: [
                // Tab 1: Active Bookings
                _buildActiveBookingsTab(strings, isBn),

                // Tab 2: Custom Jobs & Bidding
                _buildCustomJobsTab(strings, isBn),

                // Tab 3: Completed History
                _buildCompletedHistoryTab(strings, isBn),
              ],
            ),
    );
  }

  Widget _buildActiveBookingsTab(AppStrings strings, bool isBn) {
    if (_activeBookings.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.assignment_turned_in_outlined, size: 48, color: AppColors.slateMuted),
            const SizedBox(height: 12),
            Text(
              strings.noBookings,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.slateNavy),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: widget.onBackToCatalog,
              child: Text(isBn ? 'সেবাসমূহ দেখুন' : 'Explore Services'),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: _activeBookings.length,
      separatorBuilder: (_, __) => const SizedBox(height: 14),
      itemBuilder: (context, index) {
        final booking = _activeBookings[index];
        return InkWell(
          onTap: () => widget.onSelectBookingForTracking(booking),
          borderRadius: BorderRadius.circular(18),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.forestGreen.withValues(alpha: 0.4), width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: AppColors.forestGreen.withValues(alpha: 0.08),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
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
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.forestGreen.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.radar, size: 14, color: AppColors.forestGreen),
                          const SizedBox(width: 4),
                          Text(
                            booking.status,
                            style: const TextStyle(
                              color: AppColors.forestGreen,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '#${booking.bookingId}',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.slateMuted),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    CircleAvatar(
                      radius: 22,
                      backgroundImage: AssetImage(AssetPaths.getPath('ac_technician')),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            booking.skillName,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.slateNavy),
                          ),
                          Text(
                            booking.providerName,
                            style: const TextStyle(fontSize: 12, color: AppColors.slateMuted),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '৳ ${strings.formatNumber(booking.totalAmount.toInt())}',
                          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: AppColors.forestGreen),
                        ),
                        Text(isBn ? 'মোট বিল' : 'Total', style: const TextStyle(fontSize: 10, color: AppColors.slateMuted)),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Icon(Icons.location_on, size: 14, color: AppColors.urgentRed),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        booking.serviceAddress,
                        style: const TextStyle(fontSize: 12, color: AppColors.slateMuted),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: () => widget.onSelectBookingForTracking(booking),
                  icon: const Icon(Icons.navigation_rounded, size: 16),
                  label: Text(isBn ? 'লাইভ ট্র্যাকিং দেখুন' : 'View Live Tracking'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 38),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCustomJobsTab(AppStrings strings, bool isBn) {
    return Column(
      children: [
        // Post New Custom Job CTA banner
        Container(
          margin: const EdgeInsets.fromLTRB(16, 14, 16, 8),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [Color(0xFF1E3A8A), Color(0xFF3B82F6)]),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.blue.withValues(alpha: 0.2),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.add_task_rounded, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      strings.postCustomJob,
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    Text(
                      strings.postCustomJobSub,
                      style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 11),
                    ),
                  ],
                ),
              ),
              ElevatedButton(
                onPressed: () async {
                  final job = await CreateCustomJobModal.show(context);
                  if (!mounted || job == null) return;
                  _loadData();
                  if (!mounted) return;
                  final confirmed = await BiddingProposalsModal.show(context, job: job);
                  if (confirmed != null) {
                    widget.onSelectBookingForTracking(confirmed);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.urgentAmber,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(60, 36),
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                ),
                child: Text(isBn ? 'পোস্ট' : 'Post'),
              ),
            ],
          ),
        ),

        // List of Custom Jobs
        Expanded(
          child: _customJobs.isEmpty
              ? Center(
                  child: Text(
                    isBn ? 'কোনো কাস্টম কাজের রিকোয়েস্ট নেই' : 'No custom jobs posted yet',
                    style: const TextStyle(color: AppColors.slateMuted),
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: _customJobs.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final job = _customJobs[index];
                    final isAssigned = job.status == 'Assigned';

                    return Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: AppColors.cardBorder),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
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
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: isAssigned
                                      ? AppColors.forestGreen.withValues(alpha: 0.12)
                                      : AppColors.urgentAmber.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  isAssigned
                                      ? (isBn ? 'নিযুক্ত (Assigned)' : 'Assigned')
                                      : (isBn ? 'চলমান বিডিং (Open)' : 'Open for Bids'),
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 11,
                                    color: isAssigned ? AppColors.forestGreen : AppColors.urgentAmber,
                                  ),
                                ),
                              ),
                              Text(
                                'বাজেট: ৳ ${strings.formatNumber(job.budget.toInt())}',
                                style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.forestGreen),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text(
                            job.title,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.slateNavy),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            job.description,
                            style: const TextStyle(fontSize: 12, color: AppColors.slateMuted),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              const Icon(Icons.location_on, size: 14, color: AppColors.urgentRed),
                              const SizedBox(width: 4),
                              Text(job.location, style: const TextStyle(fontSize: 12, color: AppColors.slateMuted)),
                              const Spacer(),
                              Text(
                                isBn
                                    ? '${strings.formatNumber(job.proposals.length)} টি প্রস্তাব এসেছে'
                                    : '${job.proposals.length} Proposals',
                                style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.forestGreen, fontSize: 12),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          ElevatedButton.icon(
                            onPressed: () {
                              BiddingProposalsModal.show(context, job: job).then((confirmed) {
                                if (confirmed != null) {
                                  _loadData();
                                  widget.onSelectBookingForTracking(confirmed);
                                }
                              });
                            },
                            icon: const Icon(Icons.gavel_rounded, size: 16),
                            label: Text(
                              isBn ? 'প্রস্তাবগুলো দেখুন ও তুলনা করুন' : 'View & Compare Proposals',
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.forestGreen,
                              minimumSize: const Size(double.infinity, 38),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildCompletedHistoryTab(AppStrings strings, bool isBn) {
    if (_completedBookings.isEmpty) {
      return Center(
        child: Text(
          isBn ? 'কোনো পূর্বের সম্পন্ন কাজের ইতিহাস নেই' : 'No completed history found',
          style: const TextStyle(color: AppColors.slateMuted),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: _completedBookings.length,
      separatorBuilder: (_, __) => const SizedBox(height: 14),
      itemBuilder: (context, index) {
        final booking = _completedBookings[index];
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.cardBorder),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.forestGreen.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      strings.statusCompleted,
                      style: const TextStyle(color: AppColors.forestGreen, fontWeight: FontWeight.bold, fontSize: 11),
                    ),
                  ),
                  Text(
                    '#${booking.bookingId}',
                    style: const TextStyle(color: AppColors.slateMuted, fontSize: 12),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                booking.skillName,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.slateNavy),
              ),
              Text(
                booking.providerName,
                style: const TextStyle(fontSize: 12, color: AppColors.slateMuted),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '৳ ${strings.formatNumber(booking.totalAmount.toInt())}',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppColors.forestGreen),
                  ),
                  OutlinedButton.icon(
                    onPressed: () => _showInvoiceSheet(booking),
                    icon: const Icon(Icons.receipt_long, size: 16),
                    label: Text(isBn ? 'রসিদ দেখুন' : 'View Receipt'),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(100, 36),
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
