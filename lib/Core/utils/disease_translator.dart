import 'package:flutter/material.dart';
import 'package:nervix_app/Core/localization/translation_extension.dart';

class DiseaseTranslator {
  static String translate(BuildContext context, String disease) {
    final List<String> items = disease.split(RegExp(r'[,،\n]')).map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
    final List<String> translatedItems = items.map((d) => _getTranslation(context, d)).toList();
    return translatedItems.join(', ');
  }

  static String _getTranslation(BuildContext context, String d) {
    final clean = d.trim().toLowerCase();
    if (clean == 'diabetes' || clean == 'السكري') return context.t('Diabetes', 'السكري');
    if (clean == 'hypertension' || clean == 'ضغط الدم') return context.t('Hypertension', 'ضغط الدم');
    if (clean == 'heart disease' || clean == 'أمراض القلب') return context.t('Heart Disease', 'أمراض القلب');
    if (clean == 'asthma' || clean == 'الربو') return context.t('Asthma', 'الربو');
    if (clean == 'arthritis' || clean == 'التهاب المفاصل') return context.t('Arthritis', 'التهاب المفاصل');
    if (clean == 'kidney disease' || clean == 'أمراض الكلى') return context.t('Kidney Disease', 'أمراض الكلى');
    if (clean == 'liver disease' || clean == 'أمراض الكبد') return context.t('Liver Disease', 'أمراض الكبد');
    if (clean == 'cancer' || clean == 'السرطان') return context.t('Cancer', 'السرطان');
    if (clean == 'none' || clean == 'لا يوجد') return context.t('None', 'لا يوجد');
    
    // Neural history/status translations
    if (clean.contains('eplipce') || clean.contains('epilepsy') || clean.contains('صرع')) {
      if (clean.contains('95%')) return context.t('95% Epilepsy', 'صرع 95%');
      if (clean.contains('90%')) return context.t('90% Epilepsy', 'صرع 90%');
      if (clean.contains('80%')) return context.t('80% Epilepsy', 'صرع 80%');
      return context.t('Epilepsy', 'صرع');
    }
    if (clean == 'normal' || clean == 'طبيعي') return context.t('Normal', 'طبيعي');

    return d;
  }

  // Version that doesn't need context if we have isArabic
  static String translateWithLocale(String disease, bool isArabic) {
    final List<String> items = disease.split(RegExp(r'[,،\n]')).map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
    final List<String> translatedItems = items.map((d) => _getTranslationManual(d, isArabic)).toList();
    return translatedItems.join(', ');
  }

  static String _getTranslationManual(String d, bool isArabic) {
    final clean = d.trim().toLowerCase();
    
    String getT(String en, String ar) => isArabic ? ar : en;

    if (clean == 'diabetes' || clean == 'السكري') return getT('Diabetes', 'السكري');
    if (clean == 'hypertension' || clean == 'ضغط الدم') return getT('Hypertension', 'ضغط الدم');
    if (clean == 'heart disease' || clean == 'أمراض القلب') return getT('Heart Disease', 'أمراض القلب');
    if (clean == 'asthma' || clean == 'الربو') return getT('Asthma', 'الربو');
    if (clean == 'arthritis' || clean == 'التهاب المفاصل') return getT('Arthritis', 'التهاب المفاصل');
    if (clean == 'kidney disease' || clean == 'أمراض الكلى') return getT('Kidney Disease', 'أمراض الكلى');
    if (clean == 'liver disease' || clean == 'أمراض الكبد') return getT('Liver Disease', 'أمراض الكبد');
    if (clean == 'cancer' || clean == 'السرطان') return getT('Cancer', 'السرطان');
    if (clean == 'none' || clean == 'لا يوجد') return getT('None', 'لا يوجد');
    
    if (clean.contains('eplipce') || clean.contains('epilepsy') || clean.contains('صرع')) {
      if (clean.contains('95%')) return getT('95% Epilepsy', 'صرع 95%');
      if (clean.contains('90%')) return getT('90% Epilepsy', 'صرع 90%');
      if (clean.contains('80%')) return getT('80% Epilepsy', 'صرع 80%');
      return getT('Epilepsy', 'صرع');
    }
    if (clean == 'normal' || clean == 'طبيعي') return getT('Normal', 'طبيعي');

    return d;
  }
}
