import 'package:flutter/material.dart';

class AppLocalizations {
  AppLocalizations(this.locale);

  final Locale locale;

  static const supportedLocales = <Locale>[
    Locale('en'),
    Locale('ar'),
  ];

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static AppLocalizations of(BuildContext context) {
    final result = Localizations.of<AppLocalizations>(
      context,
      AppLocalizations,
    );
    return result ?? AppLocalizations(const Locale('en'));
  }

  bool get _isArabic => locale.languageCode.toLowerCase().startsWith('ar');

  String get retryConnection =>
      _isArabic ? 'إعادة محاولة الاتصال' : 'Retry connection';
  String get noInternetBanner => _isArabic
      ? 'لا يوجد اتصال بالإنترنت. قد تتوقف البيانات الحية والمزامنة.'
      : 'No internet connection. Live data and sync may be unavailable.';
  String get emergencyTitle => _isArabic ? 'طوارئ' : 'Emergency';
  String get emergencyHint => _isArabic
      ? 'اتصل بالطوارئ المحلية بسرعة. هذا التطبيق ليس بديلاً للرعاية الطبية.'
      : 'Tap to call local emergency quickly. This app is not a substitute for medical care.';
  String get journalTitle => _isArabic ? 'ملاحظات صحية' : 'Health notes';
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool isSupported(Locale locale) {
    return AppLocalizations.supportedLocales
        .map((e) => e.languageCode)
        .contains(locale.languageCode);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
