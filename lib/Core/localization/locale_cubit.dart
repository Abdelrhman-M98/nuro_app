import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleCubit extends Cubit<Locale> {
  LocaleCubit() : super(_getInitialLocale()) {
    _loadSavedLocale();
  }

  static Locale _getInitialLocale() {
    final systemLocale = PlatformDispatcher.instance.locale;
    if (systemLocale.languageCode == 'ar') {
      return const Locale('ar');
    }
    return const Locale('en');
  }

  static const String _localeKey = 'app_locale';

  Future<void> _loadSavedLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final String? languageCode = prefs.getString(_localeKey);
    if (languageCode != null) {
      emit(Locale(languageCode));
    }
  }

  Future<void> changeLanguage(String languageCode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_localeKey, languageCode);
    emit(Locale(languageCode));
  }

  bool get isArabic => state.languageCode == 'ar';
}
