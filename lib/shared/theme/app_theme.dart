import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData get dark => ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF4A90D9),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
        navigationRailTheme: const NavigationRailThemeData(
          backgroundColor: Color(0xFF1A1D23),
          indicatorColor: Color(0xFF2D5A8E),
        ),
        scaffoldBackgroundColor: const Color(0xFF13161C),
        cardColor: const Color(0xFF1E2128),
        dividerColor: const Color(0xFF2E3340),
      );
}
