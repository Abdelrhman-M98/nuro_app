import 'package:shared_preferences/shared_preferences.dart';

class AppPreferences {
  static const _kDisclaimer = 'medical_disclaimer_accepted_v1';
  static const _kMonitoringGuide = 'monitoring_guide_seen_v1';
  static const _kSafetyOnboardingSeen = 'safety_onboarding_seen_v1';

  static Future<bool> isMedicalDisclaimerAccepted() async {
    final p = await SharedPreferences.getInstance();
    return p.getBool(_kDisclaimer) ?? false;
  }

  static Future<void> setMedicalDisclaimerAccepted() async {
    final p = await SharedPreferences.getInstance();
    await p.setBool(_kDisclaimer, true);
  }

  static Future<bool> hasSeenMonitoringGuide() async {
    final p = await SharedPreferences.getInstance();
    return p.getBool(_kMonitoringGuide) ?? false;
  }

  static Future<void> setMonitoringGuideSeen() async {
    final p = await SharedPreferences.getInstance();
    await p.setBool(_kMonitoringGuide, true);
  }

  static Future<bool> hasSeenSafetyOnboarding() async {
    final p = await SharedPreferences.getInstance();
    return p.getBool(_kSafetyOnboardingSeen) ?? false;
  }

  static Future<void> setSafetyOnboardingSeen() async {
    final p = await SharedPreferences.getInstance();
    await p.setBool(_kSafetyOnboardingSeen, true);
  }
}
