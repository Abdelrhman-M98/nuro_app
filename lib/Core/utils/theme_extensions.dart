import 'package:flutter/material.dart';

extension ThemeExtension on BuildContext {
  ThemeData get theme => Theme.of(this);
  ColorScheme get colorScheme => theme.colorScheme;
  TextTheme get textTheme => theme.textTheme;
  bool get isDarkMode => theme.brightness == Brightness.dark;
  
  // Custom semantic colors that adapt to theme
  Color get surfaceColor => colorScheme.surface;
  Color get onSurfaceColor => colorScheme.onSurface;
  Color get surfaceContainer => colorScheme.surfaceContainer;
  Color get surfaceContainerLow => colorScheme.surfaceContainerLow;
  Color get surfaceContainerHigh => colorScheme.surfaceContainerHigh;
  
  // Text colors with varying prominence
  Color get textPrimary => colorScheme.onSurface;
  Color get textSecondary => colorScheme.onSurface.withValues(alpha: 0.7);
  Color get textTertiary => colorScheme.onSurface.withValues(alpha: 0.54);
  Color get textDisabled => colorScheme.onSurface.withValues(alpha: 0.38);
}
