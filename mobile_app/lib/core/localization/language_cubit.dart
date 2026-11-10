import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageCubit extends Cubit<Locale> {
  static const String _prefKey = 'selected_locale';

  LanguageCubit() : super(const Locale('bn', 'BD')) {
    _loadSavedLocale();
  }

  Future<void> _loadSavedLocale() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final code = prefs.getString(_prefKey);
      if (code != null) {
        if (code == 'en') {
          emit(const Locale('en', 'US'));
        } else {
          emit(const Locale('bn', 'BD'));
        }
      }
    } catch (_) {
      // fallback to default Bengali
    }
  }

  Future<void> toggleLanguage() async {
    final newLocale = state.languageCode == 'bn'
        ? const Locale('en', 'US')
        : const Locale('bn', 'BD');
    emit(newLocale);

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefKey, newLocale.languageCode);
    } catch (_) {}
  }

  bool get isBengali => state.languageCode == 'bn';
}

