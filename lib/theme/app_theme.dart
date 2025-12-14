import 'package:flutter/material.dart';

class AppTheme {
  // Color palette based on the reference design
  static const Color primaryYellow = Color(0xFFFFD700);
  static const Color darkBackground = Color(0xFF121212);
  static const Color cardBackground = Color(0xFF1E1E1E);
  static const Color surfaceColor = Color(0xFF2A2A2A);
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFB3B3B3);
  static const Color textTertiary = Color(0xFF808080);
  static const Color accentGreen = Color(0xFF1DB954);
  static const Color accentRed = Color(0xFFE22E2E);

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      primarySwatch: MaterialColor(0xFFFFD700, _yellowSwatch),
      primaryColor: primaryYellow,
      scaffoldBackgroundColor: darkBackground,
      cardColor: cardBackground,
      
      // AppBar theme
      appBarTheme: const AppBarTheme(
        backgroundColor: darkBackground,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
        iconTheme: IconThemeData(color: textPrimary),
      ),
      
      // Text theme
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          color: textPrimary,
          fontWeight: FontWeight.bold,
          fontSize: 24,
        ),
        headlineMedium: TextStyle(
          color: textPrimary,
          fontWeight: FontWeight.w600,
          fontSize: 20,
        ),
        headlineSmall: TextStyle(
          color: textPrimary,
          fontWeight: FontWeight.w600,
          fontSize: 18,
        ),
        titleLarge: TextStyle(
          color: textPrimary,
          fontWeight: FontWeight.w600,
          fontSize: 16,
        ),
        titleMedium: TextStyle(
          color: textPrimary,
          fontWeight: FontWeight.w500,
          fontSize: 14,
        ),
        bodyLarge: TextStyle(
          color: textSecondary,
          fontSize: 16,
        ),
        bodyMedium: TextStyle(
          color: textSecondary,
          fontSize: 14,
        ),
        bodySmall: TextStyle(
          color: textTertiary,
          fontSize: 12,
        ),
        labelLarge: TextStyle(
          color: textPrimary,
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
      ),
      
      // Input decoration theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryYellow, width: 2),
        ),
        hintStyle: const TextStyle(color: textTertiary),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      
      // Elevated button theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryYellow,
          foregroundColor: darkBackground,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          textStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ),
      
      // Chip theme
      chipTheme: ChipThemeData(
        backgroundColor: surfaceColor,
        selectedColor: primaryYellow,
        labelStyle: const TextStyle(color: textSecondary),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      
      // Icon theme
      iconTheme: const IconThemeData(
        color: textSecondary,
        size: 24,
      ),
      
      // Card theme
      cardTheme: CardThemeData(
        color: cardBackground,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      
      // Drawer theme
      drawerTheme: const DrawerThemeData(
        backgroundColor: cardBackground,
        elevation: 8,
      ),
      
      // Bottom navigation bar theme
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: cardBackground,
        selectedItemColor: primaryYellow,
        unselectedItemColor: textTertiary,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      
      // Divider theme
      dividerTheme: const DividerThemeData(
        color: surfaceColor,
        thickness: 1,
      ),
    );
  }

  // Material color swatch for primary yellow
  static const Map<int, Color> _yellowSwatch = {
    50: Color(0xFFFFFDE7),
    100: Color(0xFFFFF9C4),
    200: Color(0xFFFFF59D),
    300: Color(0xFFFFF176),
    400: Color(0xFFFFEE58),
    500: Color(0xFFFFD700),
    600: Color(0xFFFFCA28),
    700: Color(0xFFFFC107),
    800: Color(0xFFFFB300),
    900: Color(0xFFFF8F00),
  };
}