import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/asset_paths.dart';
import '../../../core/localization/app_strings.dart';
import '../../../core/localization/language_cubit.dart';
import '../../../core/theme/app_colors.dart';
import '../logic/role_cubit.dart';

class DualOnboardingScreen extends StatelessWidget {
  final VoidCallback onSelectSeeker;
  final VoidCallback onSelectProvider;

  const DualOnboardingScreen({
    super.key,
    required this.onSelectSeeker,
    required this.onSelectProvider,
  });

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final isBn = strings.isBengali;

    return Scaffold(
      backgroundColor: AppColors.softOffWhite,
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.forestGreen,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.handyman_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              strings.appName,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ],
        ),
        actions: [
          // 1-Tap Language Switcher Pill
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () => context.read<LanguageCubit>().toggleLanguage(),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.forestGreen.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.forestGreen, width: 1.2),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.language,
                      size: 16,
                      color: AppColors.forestGreen,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      isBn ? 'EN' : 'বাংলা',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: AppColors.forestGreen,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 12),

              // Welcome Tagline
              Text(
                strings.tagline,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.slateNavy,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                isBn
                    ? 'আপনার প্রয়োজন অনুযায়ী অপশন বেছে নিন'
                    : 'Choose your desired role to get started',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
              ),

              const SizedBox(height: 32),

              // Option 1: Need Service (Seeker)
              Expanded(
                child: _PersonaSelectionCard(
                  title: strings.needService,
                  subtitle: strings.needServiceSub,
                  badgeText: isBn ? 'গ্রাহক / কাস্টমার' : 'Customer',
                  badgeColor: AppColors.forestGreen,
                  cardBorderColor: AppColors.forestGreen,
                  icon: Icons.home_repair_service_rounded,
                  avatarPath: AssetPaths.getPath('general_technician'),
                  onTap: () {
                    context.read<RoleCubit>().setRole(AppRole.seeker);
                    onSelectSeeker();
                  },
                ),
              ),

              const SizedBox(height: 18),

              // Option 2: Provide Service (Provider)
              Expanded(
                child: _PersonaSelectionCard(
                  title: strings.provideService,
                  subtitle: strings.provideServiceSub,
                  badgeText: isBn ? 'কারিগর / টেকনিশিয়ান' : 'Technician',
                  badgeColor: AppColors.urgentAmber,
                  cardBorderColor: AppColors.urgentAmber,
                  icon: Icons.construction_rounded,
                  avatarPath: AssetPaths.getPath('electrician'),
                  onTap: () {
                    context.read<RoleCubit>().setRole(AppRole.provider);
                    onSelectProvider();
                  },
                ),
              ),

              const SizedBox(height: 20),

              // Bottom note on dual role
              Text(
                isBn
                    ? '💡 আপনি পরবর্তীতে যেকোনো সময় অ্যাপের ভেতর থেকে মোড পরিবর্তন করতে পারবেন।'
                    : '💡 You can switch modes at any time inside the app without re-logging.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}

class _PersonaSelectionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String badgeText;
  final Color badgeColor;
  final Color cardBorderColor;
  final IconData icon;
  final String avatarPath;
  final VoidCallback onTap;

  const _PersonaSelectionCard({
    required this.title,
    required this.subtitle,
    required this.badgeText,
    required this.badgeColor,
    required this.cardBorderColor,
    required this.icon,
    required this.avatarPath,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: cardBorderColor.withValues(alpha: 0.4),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Avatar / Icon Circle
            Stack(
              alignment: Alignment.bottomRight,
              children: [
                Container(
                  width: 76,
                  height: 76,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                      image: AssetImage(avatarPath),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: badgeColor,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: Icon(icon, color: Colors.white, size: 14),
                ),
              ],
            ),
            const SizedBox(width: 16),

            // Text Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: badgeColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      badgeText,
                      style: TextStyle(
                        color: badgeColor,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.slateNavy,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade600,
                      height: 1.25,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            const SizedBox(width: 8),
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: cardBorderColor,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
