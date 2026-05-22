import 'package:flutter/material.dart';

/// iOS 风配色 —— 跟着原型走
class AppColors {
  // 系统色
  static const accent = Color(0xFF007AFF);   // SystemBlue
  static const accentSoft = Color(0x2E007AFF);
  static const success = Color(0xFF34C759);  // SystemGreen
  static const danger = Color(0xFFFF3B30);   // SystemRed
  static const warning = Color(0xFFFF9F0A);  // SystemOrange
  static const info = Color(0xFF5E5CE6);     // SystemIndigo

  // 暗色
  static const bg = Color(0xFF18181A);
  static const bg2 = Color(0xFF1F1F22);
  static const surface = Color(0xFF26262A);
  static const surface2 = Color(0xFF2E2E32);
  static const surface3 = Color(0xFF36363A);

  static const text = Color(0xFFFFFFFF);
  static const textDim = Color(0xFF8E8E93);
  static const textFaint = Color(0xFF636366);

  static const stroke = Color(0x14FFFFFF);   // rgba(255,255,255,0.08)
  static const strokeStrong = Color(0x24FFFFFF); // rgba(255,255,255,0.14)
}

class AppRadius {
  static const s = 8.0;
  static const m = 10.0;
  static const l = 14.0;
  static const xl = 22.0;
}

ThemeData buildTheme() {
  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.bg,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.accent,
      secondary: AppColors.accent,
      surface: AppColors.surface,
      error: AppColors.danger,
    ),
    fontFamily: '.SF UI Text', // iOS / fallback system on Android
    cardTheme: CardTheme(
      color: AppColors.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.l),
        side: const BorderSide(color: AppColors.stroke, width: 0.5),
      ),
      margin: EdgeInsets.zero,
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.all(Colors.white),
      trackColor: WidgetStateProperty.resolveWith((states) =>
          states.contains(WidgetState.selected) ? AppColors.accent : AppColors.surface2),
    ),
    sliderTheme: const SliderThemeData(
      activeTrackColor: AppColors.text,
      inactiveTrackColor: AppColors.surface2,
      thumbColor: Colors.white,
      trackHeight: 3,
    ),
  );
}
