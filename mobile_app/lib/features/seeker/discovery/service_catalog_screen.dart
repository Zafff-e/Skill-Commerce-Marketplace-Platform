import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/asset_paths.dart';
import '../../../core/localization/app_strings.dart';
import '../../../core/localization/language_cubit.dart';
import '../../../core/network/skill_commerce_repository.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/models/polyglot_models.dart';
import '../../auth/logic/role_cubit.dart';
import '../bidding/bidding_proposals_modal.dart';
import '../bidding/create_custom_job_modal.dart';
import '../support/dokkho_ai_chat_modal.dart';

class ServiceCatalogScreen extends StatefulWidget {
  final Function(SkillModel skill) onSkillSelected;
  final VoidCallback onOpenMap;
  final VoidCallback onViewMyBookings;
  final Function(BookingModel booking)? onCustomJobConfirmed;

  const ServiceCatalogScreen({
    super.key,
    required this.onSkillSelected,
    required this.onOpenMap,
    required this.onViewMyBookings,
    this.onCustomJobConfirmed,
  });

  @override
  State<ServiceCatalogScreen> createState() => _ServiceCatalogScreenState();
}

class _ServiceCatalogScreenState extends State<ServiceCatalogScreen> {
  List<CategoryModel> _categories = [];
  bool _isLoading = true;
  String _searchQuery = '';
  int _selectedCategoryIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadCatalog();
  }

  Future<void> _loadCatalog() async {
    final repo = context.read<SkillCommerceRepository>();
    final categories = await repo.getCategories();
    if (mounted) {
      setState(() {
        _categories = categories;
        _isLoading = false;
      });
    }
  }

  List<SkillModel> get _displayedSkills {
    if (_categories.isEmpty) return [];

    List<SkillModel> list = [];
    if (_selectedCategoryIndex == 0) {
      // All skills combined
      for (final cat in _categories) {
        list.addAll(cat.skills);
      }
    } else {
      list = _categories[_selectedCategoryIndex - 1].skills;
    }

    if (_searchQuery.isNotEmpty) {
      list = list
          .where(
            (s) =>
                s.skillName.toLowerCase().contains(_searchQuery.toLowerCase()),
          )
          .toList();
    }
    return list;
  }

  String _getAvatarKeyForSkill(String skillName) {
    final lower = skillName.toLowerCase();
    if (lower.contains('ac')) return 'ac_technician';
    if (lower.contains('electr')) return 'electrician';
    if (lower.contains('plumb')) return 'plumber';
    if (lower.contains('clean')) return 'cleaner';
    if (lower.contains('pest')) return 'pest_control';
    if (lower.contains('carpenter')) return 'carpenter';
    if (lower.contains('paint')) return 'painter';
    if (lower.contains('nurse') || lower.contains('care')) return 'caregiver';
    if (lower.contains('cctv')) return 'cctv_technician';
    if (lower.contains('shift') || lower.contains('mover')) {
      return 'packer_mover';
    }
    return 'general_technician';
  }

  String _getLocalizedName(String text, bool isBn) {
    if (text.contains('(') && text.contains(')')) {
      final parts = text.split('(');
      final en = parts[0].trim();
      final bn = parts[1].replaceAll(')', '').trim();
      return isBn ? (bn.isNotEmpty ? bn : en) : (en.isNotEmpty ? en : bn);
    }
    return text;
  }

  Future<void> _handleCustomJobCreation([AiIntakeResultModel? initialIntake]) async {
    final job = await CreateCustomJobModal.show(context, initialAiIntake: initialIntake);
    if (!mounted || job == null) return;
    final confirmed = await BiddingProposalsModal.show(context, job: job);
    if (confirmed != null && widget.onCustomJobConfirmed != null) {
      widget.onCustomJobConfirmed!(confirmed);
    }
  }

  void _triggerAiVoiceIntakeSheet() {
    final strings = AppStrings.of(context);
    final isBn = strings.isBengali;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.urgentAmber.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.mic, color: AppColors.urgentAmber, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        strings.aiVoiceButton,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: AppColors.slateNavy,
                        ),
                      ),
                      Text(
                        isBn
                            ? 'আপনার কী সেবা প্রয়োজন মুখে বলুন বা নির্বাচন করুন:'
                            : 'Speak or select what service you need:',
                        style: const TextStyle(fontSize: 12, color: AppColors.slateMuted),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 10),
            _buildVoiceSampleTile(
              ctx: ctx,
              icon: Icons.ac_unit,
              label: isBn ? '❄️ এসি থেকে পানি পড়ছে, ঠান্ডা হচ্ছে না' : '❄️ AC water leaking & not cooling',
              query: 'আমার এসি থেকে পানি পড়ছে এবং ঠান্ডা হচ্ছে না, বনানী রোড ১১ তে মিস্ত্রি লাগবে।',
            ),
            _buildVoiceSampleTile(
              ctx: ctx,
              icon: Icons.electrical_services,
              label: isBn ? '⚡ মেইন সুইচে শর্ট সার্কিট ও স্পার্ক' : '⚡ Main switch sparking & trip',
              query: 'মেইন ডিবি বোর্ডে শর্ট সার্কিট হয়েছে ধোঁয়া বের হচ্ছে, দ্রুত জরুরি ইলেকট্রিশিয়ান পাঠান।',
            ),
            _buildVoiceSampleTile(
              ctx: ctx,
              icon: Icons.plumbing,
              label: isBn ? '🚰 কিচেনের সিঙ্ক ড্রেন জ্যাম ও পাইপ লিক' : '🚰 Kitchen sink jammed & pipe leaking',
              query: 'কিচেনের পাইপ লিক হয়ে পানি পড়ছে, দ্রুত প্লাম্বার লাগবে ধানমন্ডি ৫ এ।',
            ),
            _buildVoiceSampleTile(
              ctx: ctx,
              icon: Icons.cleaning_services,
              label: isBn ? '🧹 সোফা ও কার্পেট ডিপ ড্রাই-ওয়াশ' : '🧹 Sofa & Carpet Deep Dry Wash',
              query: 'বাসার ৭ সিটের সোফা ও কার্পেট ড্রাই ওয়াশ ও ডিপ ক্লিনিং সার্ভিস প্রয়োজন।',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVoiceSampleTile({
    required BuildContext ctx,
    required IconData icon,
    required String label,
    required String query,
  }) {
    return InkWell(
      onTap: () {
        Navigator.pop(ctx);
        _processAiVoiceRequest(query);
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.softOffWhite,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.cardBorder),
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: AppColors.forestGreen),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.slateNavy,
                ),
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 12, color: AppColors.slateMuted),
          ],
        ),
      ),
    );
  }

  Future<void> _processAiVoiceRequest(String text) async {
    final strings = AppStrings.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.slateNavy,
        duration: const Duration(seconds: 2),
        content: Row(
          children: [
            const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                strings.aiAnalyzing,
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );

    final repo = context.read<SkillCommerceRepository>();
    final aiResult = await repo.processVoiceIntake(transcribedText: text);

    if (!mounted) return;
    await _handleCustomJobCreation(aiResult);
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final isBn = strings.isBengali;

    return Scaffold(
      backgroundColor: AppColors.softOffWhite,
      appBar: AppBar(
        titleSpacing: 16,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.location_on,
                  color: AppColors.forestGreen,
                  size: 16,
                ),
                const SizedBox(width: 4),
                Text(
                  isBn ? 'বনানী, ঢাকা' : 'Banani, Dhaka',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Icon(
                  Icons.arrow_drop_down,
                  color: AppColors.slateNavy,
                  size: 18,
                ),
              ],
            ),
            Text(
              strings.appName,
              style: const TextStyle(fontSize: 11, color: AppColors.slateMuted),
            ),
          ],
        ),
        actions: [
          // 1-Tap Dual-Role Switcher Pill
          Padding(
            padding: const EdgeInsets.only(right: 6),
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () => context.read<RoleCubit>().toggleRole(),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: AppColors.urgentAmber.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.urgentAmber, width: 1),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.sync_alt,
                      size: 14,
                      color: AppColors.urgentAmber,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      isBn ? 'কারিগর মোড' : 'Provider',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: AppColors.urgentAmber,
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
                  color: AppColors.forestGreen.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.forestGreen, width: 1),
                ),
                child: Text(
                  isBn ? 'EN' : 'বাং',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: AppColors.forestGreen,
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
              onRefresh: _loadCatalog,
              color: AppColors.forestGreen,
              child: CustomScrollView(
                slivers: [
                  // Search Bar Header
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                      child: TextField(
                        onChanged: (val) => setState(() => _searchQuery = val),
                        decoration: InputDecoration(
                          hintText: strings.searchPlaceholder,
                          hintStyle: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade500,
                          ),
                          prefixIcon: const Icon(
                            Icons.search,
                            color: AppColors.forestGreen,
                          ),
                          suffixIcon: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(
                                  Icons.mic_rounded,
                                  color: AppColors.urgentAmber,
                                ),
                                onPressed: _triggerAiVoiceIntakeSheet,
                                tooltip: strings.aiVoiceButton,
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.map_outlined,
                                  color: AppColors.forestGreen,
                                ),
                                onPressed: widget.onOpenMap,
                                tooltip: 'View Nearby Providers on Map',
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Emergency Callout Banner
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 6,
                      ),
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF00875A), Color(0xFF005A3C)],
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.forestGreen.withValues(
                                alpha: 0.2,
                              ),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.18),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.flash_on_rounded,
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    strings.emergencyService,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  Text(
                                    isBn
                                        ? '১৫ মিনিটে কারিগর পৌঁছে যাবে'
                                        : 'Technician arrives within 15 mins',
                                    style: TextStyle(
                                      color: Colors.white.withValues(
                                        alpha: 0.85,
                                      ),
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            ElevatedButton(
                              onPressed: widget.onOpenMap,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.urgentAmber,
                                foregroundColor: Colors.white,
                                minimumSize: const Size(80, 36),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: Text(
                                isBn ? 'ম্যাপ দেখুন' : 'View Map',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Custom Job & Bidding Card
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      child: InkWell(
                        onTap: () => _handleCustomJobCreation(),
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF1E3A8A), Color(0xFF2563EB)],
                            ),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.blue.withValues(alpha: 0.18),
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
                                child: const Icon(
                                  Icons.gavel_rounded,
                                  color: Colors.white,
                                  size: 22,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      strings.postCustomJob,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                    Text(
                                      strings.postCustomJobSub,
                                      style: TextStyle(
                                        color: Colors.white.withValues(alpha: 0.85),
                                        fontSize: 11,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(
                                Icons.arrow_forward_ios_rounded,
                                color: Colors.white,
                                size: 16,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Category Filter Tabs
                  SliverToBoxAdapter(
                    child: SizedBox(
                      height: 48,
                      child: ListView.separated(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 6,
                        ),
                        scrollDirection: Axis.horizontal,
                        itemCount: _categories.length + 1,
                        separatorBuilder: (_, __) => const SizedBox(width: 8),
                        itemBuilder: (context, index) {
                          final isSelected = _selectedCategoryIndex == index;
                          final rawTitle = index == 0
                              ? (isBn ? 'সব সেবা' : 'All')
                              : _categories[index - 1].categoryName;
                          final title = index == 0 ? rawTitle : _getLocalizedName(rawTitle, isBn);

                          return ChoiceChip(
                            label: Text(title),
                            selected: isSelected,
                            selectedColor: AppColors.forestGreen,
                            backgroundColor: Colors.white,
                            labelStyle: TextStyle(
                              color: isSelected
                                  ? Colors.white
                                  : AppColors.slateNavy,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.w500,
                              fontSize: 12,
                            ),
                            onSelected: (selected) {
                              if (selected) {
                                setState(() => _selectedCategoryIndex = index);
                              }
                            },
                          );
                        },
                      ),
                    ),
                  ),

                  // Service Tiles Grid
                  SliverPadding(
                    padding: const EdgeInsets.all(16),
                    sliver: SliverGrid(
                      gridDelegate:
                          SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: MediaQuery.of(context).size.width > 600 ? 3 : 2,
                            crossAxisSpacing: 14,
                            mainAxisSpacing: 14,
                            childAspectRatio: MediaQuery.of(context).size.width > 380 ? 0.88 : 0.82,
                          ),
                      delegate: SliverChildBuilderDelegate((context, index) {
                        final skill = _displayedSkills[index];
                        final avatarKey = _getAvatarKeyForSkill(
                          skill.skillName,
                        );
                        final avatarPath = AssetPaths.getPath(avatarKey);

                        return InkWell(
                          onTap: () => widget.onSkillSelected(skill),
                          borderRadius: BorderRadius.circular(18),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(color: AppColors.cardBorder),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.03),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width: 64,
                                  height: 64,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    image: DecorationImage(
                                      image: AssetImage(avatarPath),
                                      fit: BoxFit.cover,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(
                                          alpha: 0.08,
                                        ),
                                        blurRadius: 6,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  _getLocalizedName(skill.skillName, isBn),
                                  textAlign: TextAlign.center,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.slateNavy,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '৳ ${strings.formatNumber(skill.basicPrice.toInt())} / ${isBn ? "শুরু" : "starts"}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.forestGreen,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }, childCount: _displayedSkills.length),
                    ),
                  ),
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => DokkhoAiChatModal.show(context),
        backgroundColor: AppColors.forestGreen,
        icon: const CircleAvatar(
          radius: 12,
          backgroundImage: AssetImage(AssetPaths.aiChatbot),
          backgroundColor: Colors.white,
        ),
        label: Text(
          isBn ? 'Dokkho AI চ্যাট' : 'Dokkho AI Chat',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.white),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        selectedItemColor: AppColors.forestGreen,
        unselectedItemColor: AppColors.slateMuted,
        backgroundColor: Colors.white,
        onTap: (index) {
          if (index == 1) widget.onOpenMap();
          if (index == 2) widget.onViewMyBookings();
        },
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.grid_view_rounded),
            label: isBn ? 'সেবাসমূহ' : 'Services',
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.map_rounded),
            label: isBn ? 'ম্যাপ' : 'Map',
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.receipt_long_rounded),
            label: isBn ? 'বুকিং' : 'Bookings',
          ),
        ],
      ),
    );
  }
}
