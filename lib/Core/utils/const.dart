import 'package:flutter/material.dart';

// --- Global Brand Colors ---
const kPrimaryColor = Color(0xFF6366F1); // Modern Indigo
const kAccentColor = Color(0xFF0EA5E9);  // Sky Blue (better contrast than Cyan in light mode)
const kErrorColor = Color(0xFFEF4444);   // Rose Red

// --- Dark Mode Palette ---
const kDarkBgColor = Color(0xFF070B14);      // Deep Midnight
const kDarkSurfaceColor = Color(0xFF111827); // Rich Slate
const kDarkSurfaceLight = Color(0xFF1F2937); // Lighter Slate
const kDarkOnBgColor = Color(0xFFF9FAFB);    // Near White
const kDarkOnSurface = Color(0xFFE5E7EB);    // Light Grey
const kDarkOnSurfaceSub = Color(0xFF9CA3AF); // Muted Grey

const kDarkGradient = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [Color(0xFF070B14), Color(0xFF111827), Color(0xFF1E1B4B)],
);

// --- Light Mode Palette ---
const kLightBgColor = Color(0xFFF1F5F9);      // Slate 100 (Slightly darker for better depth)
const kLightSurfaceColor = Color(0xFFFFFFFF); // Pure White
const kLightSurfaceLight = Color(0xFFE2E8F0); // Slate 200 (for borders/dividers)
const kLightOnBgColor = Color(0xFF0F172A);    // Slate 900
const kLightOnSurface = Color(0xFF1E293B);    // Slate 800
const kLightOnSurfaceSub = Color(0xFF64748B); // Slate 500

const kLightGradient = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [Color(0xFFF8FAFC), Color(0xFFF1F5F9)],
);

// --- Legacy support (to avoid immediate breakage during refactor) ---
const kBackgroundColor = kDarkBgColor;
const kSurfaceColor = kDarkSurfaceColor;
const kSurfaceLightColor = kDarkSurfaceLight;
const kOnBackgroundColor = kDarkOnBgColor;
const kOnSurfaceColor = kDarkOnSurface;
const kOnSurfaceVariantColor = kDarkOnSurfaceSub;
const kFloatingButtonColor = Color(0xFF2A2A4A);
const kBackgroundGradient = kDarkGradient;

// --- Other Constants ---
const String kEmergencyTelUri = 'tel:112';
const String kEmergencyDisplayNumber = '112';

