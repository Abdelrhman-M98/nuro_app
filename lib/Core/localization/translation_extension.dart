import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nervix_app/Core/localization/locale_cubit.dart';

extension TranslationExtension on BuildContext {
  String t(String en, String ar) {
    final locale = read<LocaleCubit>().state;
    return locale.languageCode == 'ar' ? ar : en;
  }

  bool get isArabic => read<LocaleCubit>().isArabic;
}
