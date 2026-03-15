import 'package:flutter/material.dart';

// ألوان التطبيق متناسقة مع السبلاش (مراقبة إشارات المخ – تنبيه الصرع)
const kPrimaryColor = Color(0xFF5B3E90);
const kAccentColor = Color(0xFF00D9FF);
const kBackgroundColor = Color(0xFF0F0F23);
const kSurfaceColor = Color(0xFF16213E);
const kSurfaceLightColor = Color(0xFF1A0B2E);
const kOnBackgroundColor = Color(0xFFFFFFFF);
const kOnSurfaceColor = Color(0xFFE0E0E0);
const kOnSurfaceVariantColor = Color(0xFFB0B0B0);
const kErrorColor = Color(0xFFE57373);
const kFloatingButtonColor = Color(0xFF2A2A4A);

// جراديانت الخلفية (مثل السبلاش)
const kBackgroundGradient = LinearGradient(
  begin: Alignment.topCenter,
  end: Alignment.bottomCenter,
  colors: [Color(0xFF1A0B2E), Color(0xFF16213E), Color(0xFF0F0F23)],
);
