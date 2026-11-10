import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AppRole { seeker, provider }

class RoleState {
  final AppRole currentRole;
  final bool hasDualRoleAccess;
  final int? providerProfileId;

  const RoleState({
    required this.currentRole,
    this.hasDualRoleAccess = true,
    this.providerProfileId,
  });

  bool get isSeeker => currentRole == AppRole.seeker;
  bool get isProvider => currentRole == AppRole.provider;

  RoleState copyWith({
    AppRole? currentRole,
    bool? hasDualRoleAccess,
    int? providerProfileId,
  }) {
    return RoleState(
      currentRole: currentRole ?? this.currentRole,
      hasDualRoleAccess: hasDualRoleAccess ?? this.hasDualRoleAccess,
      providerProfileId: providerProfileId ?? this.providerProfileId,
    );
  }
}

class RoleCubit extends Cubit<RoleState> {
  static const String _roleKey = 'active_app_role';

  RoleCubit() : super(const RoleState(currentRole: AppRole.seeker)) {
    _loadSavedRole();
  }

  Future<void> _loadSavedRole() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getString(_roleKey);
      if (saved == 'provider') {
        emit(state.copyWith(currentRole: AppRole.provider));
      } else {
        emit(state.copyWith(currentRole: AppRole.seeker));
      }
    } catch (_) {}
  }

  Future<void> setRole(AppRole role) async {
    emit(state.copyWith(currentRole: role));
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_roleKey, role.name);
    } catch (_) {}
  }

  Future<void> toggleRole() async {
    final nextRole = state.isSeeker ? AppRole.provider : AppRole.seeker;
    await setRole(nextRole);
  }
}

