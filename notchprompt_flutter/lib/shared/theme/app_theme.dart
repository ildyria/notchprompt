import 'package:flutter/material.dart';

/// App-wide theme definitions.
ThemeData get appDarkTheme => ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.white,
        brightness: Brightness.dark,
      ),
      scaffoldBackgroundColor: const Color(0xFF1A1A1A),
      cardColor: const Color(0xFF2A2A2A),
      sliderTheme: const SliderThemeData(
        thumbShape: RoundSliderThumbShape(enabledThumbRadius: 7),
        trackHeight: 3,
      ),
      textTheme: const TextTheme(
        bodyMedium: TextStyle(fontSize: 13, height: 1.4),
        labelLarge: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
      ),
    );
