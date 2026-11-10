import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_app/core/localization/language_cubit.dart';
import 'package:mobile_app/features/auth/logic/role_cubit.dart';
import 'package:mobile_app/features/auth/presentation/dual_onboarding_screen.dart';

void main() {
  testWidgets('DualOnboardingScreen renders seeker and provider choices', (WidgetTester tester) async {
    await tester.pumpWidget(
      MultiBlocProvider(
        providers: [
          BlocProvider<LanguageCubit>(create: (_) => LanguageCubit()),
          BlocProvider<RoleCubit>(create: (_) => RoleCubit()),
        ],
        child: MaterialApp(
          home: DualOnboardingScreen(
            onSelectSeeker: () {},
            onSelectProvider: () {},
          ),
        ),
      ),
    );

    // Verify presence of role options
    expect(find.byType(DualOnboardingScreen), findsOneWidget);
    expect(find.byIcon(Icons.home_repair_service_rounded), findsOneWidget);
    expect(find.byIcon(Icons.construction_rounded), findsOneWidget);
  });
}
