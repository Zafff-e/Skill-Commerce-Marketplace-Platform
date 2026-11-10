import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'core/localization/language_cubit.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/logic/role_cubit.dart';
import 'features/auth/presentation/dual_onboarding_screen.dart';
import 'features/provider/dashboard/provider_home_screen.dart';
import 'features/seeker/booking/map_booking_screen.dart';
import 'features/seeker/bookings/my_bookings_screen.dart';
import 'features/seeker/checkout/booking_checkout_modal.dart';
import 'features/seeker/discovery/service_catalog_screen.dart';
import 'features/seeker/tracking/live_tracking_screen.dart';
import 'shared/models/polyglot_models.dart';

class SkillCommerceApp extends StatefulWidget {
  const SkillCommerceApp({super.key});

  @override
  State<SkillCommerceApp> createState() => _SkillCommerceAppState();
}

class _SkillCommerceAppState extends State<SkillCommerceApp> {
  bool _hasSeenOnboarding = false;
  BookingModel? _currentActiveBooking;
  bool _showingMapScreen = false;
  bool _showingMyBookings = false;
  SkillModel? _selectedSkillForBooking;

  @override
  Widget build(BuildContext context) {
    final locale = context.watch<LanguageCubit>().state;
    final roleState = context.watch<RoleCubit>().state;

    return MaterialApp(
      title: 'SkillCommerce - Dokkho Lok Khuji',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      locale: locale,
      supportedLocales: const [
        Locale('bn', 'BD'),
        Locale('en', 'US'),
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: Builder(
        builder: (context) {
          // 1. Initial Dual-Persona Onboarding Screen
          if (!_hasSeenOnboarding) {
            return DualOnboardingScreen(
              onSelectSeeker: () {
                setState(() => _hasSeenOnboarding = true);
              },
              onSelectProvider: () {
                setState(() => _hasSeenOnboarding = true);
              },
            );
          }

          // 2. Provider Mode
          if (roleState.isProvider) {
            return ProviderHomeScreen(
              onOpenSeekerMode: () {
                context.read<RoleCubit>().setRole(AppRole.seeker);
              },
            );
          }

          // 3. Seeker Mode: Live Tracking Screen
          if (_currentActiveBooking != null) {
            return LiveTrackingScreen(
              initialBooking: _currentActiveBooking!,
              onBackToHome: () {
                setState(() => _currentActiveBooking = null);
              },
            );
          }

          // 4. Seeker Mode: My Bookings & Order History Screen
          if (_showingMyBookings) {
            return MyBookingsScreen(
              onSelectBookingForTracking: (booking) {
                setState(() {
                  _showingMyBookings = false;
                  _currentActiveBooking = booking;
                });
              },
              onBackToCatalog: () {
                setState(() => _showingMyBookings = false);
              },
            );
          }

          // 5. Seeker Mode: Interactive Map Booking Screen
          if (_showingMapScreen) {
            return MapBookingScreen(
              selectedSkill: _selectedSkillForBooking,
              onBack: () {
                setState(() => _showingMapScreen = false);
              },
              onDirectBook: (provider, isUrgent) {
                BookingCheckoutModal.show(
                  context,
                  skill: _selectedSkillForBooking,
                  provider: provider,
                  isUrgent: isUrgent,
                ).then((confirmedBooking) {
                  if (confirmedBooking != null) {
                    setState(() {
                      _showingMapScreen = false;
                      _currentActiveBooking = confirmedBooking;
                    });
                  }
                });
              },
            );
          }

          // 6. Seeker Mode: Main Service Discovery Grid
          return ServiceCatalogScreen(
            onSkillSelected: (skill) {
              setState(() {
                _selectedSkillForBooking = skill;
                _showingMapScreen = true;
              });
            },
            onOpenMap: () {
              setState(() {
                _selectedSkillForBooking = null;
                _showingMapScreen = true;
              });
            },
            onViewMyBookings: () {
              setState(() {
                _showingMyBookings = true;
              });
            },
            onCustomJobConfirmed: (booking) {
              setState(() {
                _currentActiveBooking = booking;
              });
            },
          );
        },
      ),
    );
  }
}

