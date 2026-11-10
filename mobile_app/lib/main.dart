import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'app.dart';
import 'core/localization/language_cubit.dart';
import 'core/network/dio_client.dart';
import 'core/network/skill_commerce_repository.dart';
import 'core/realtime/signalr_service.dart';
import 'features/auth/logic/role_cubit.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final dioClient = DioClient();
  final repository = SkillCommerceRepository(dioClient: dioClient);
  final signalRService = SignalRService(dioClient: dioClient);

  // Attempt non-blocking SignalR hub connection
  unawaited(signalRService.connect());

  runApp(
    MultiRepositoryProvider(
      providers: [
        RepositoryProvider<DioClient>.value(value: dioClient),
        RepositoryProvider<SkillCommerceRepository>.value(value: repository),
        RepositoryProvider<SignalRService>.value(value: signalRService),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<LanguageCubit>(create: (_) => LanguageCubit()),
          BlocProvider<RoleCubit>(create: (_) => RoleCubit()),
        ],
        child: const SkillCommerceApp(),
      ),
    ),
  );
}

void unawaited(Future<void> future) {}

