import 'package:flutter/material.dart';
import '../constants/app_constants.dart';

class AppTheme {
  static const Color darkBackground = Color(0xFF121214);
  static const Color darkSurface = Color(0xFF1E1E24);
  static const Color darkCard = Color(0xFF26262E);
  static const Color primaryGreen = Color(0xFF81B64C);
  static const Color primaryGreenHover = Color(0xFFA3D169);
  static const Color accentGold = Color(0xFFF7C04A);
  static const Color textPrimary = Color(0xFFF1F1F5);
  static const Color textSecondary = Color(0xFFA0A0AB);

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: darkBackground,
      colorScheme: const ColorScheme.dark(
        primary: primaryGreen,
        secondary: accentGold,
        surface: darkSurface,
        onPrimary: Colors.black,
        onSecondary: Colors.black,
        onSurface: textPrimary,
      ),
      cardTheme: CardThemeData(
        color: darkCard,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: darkSurface,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
        iconTheme: IconThemeData(color: textPrimary),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryGreen,
          foregroundColor: Colors.black,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryGreen,
          side: const BorderSide(color: primaryGreen, width: 2),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  static BoardColors getBoardColors(BoardThemeOption theme) {
    switch (theme) {
      case BoardThemeOption.chessCom:
        return const BoardColors(
          lightSquare: Color(0xFFEEEED2),
          darkSquare: Color(0xFF769656),
          selectedSquare: Color(0xFFBBCE59),
          highlightSquare: Color(0xFFF5F682),
          lastMoveLight: Color(0xFFCED26B),
          lastMoveDark: Color(0xFFAAA23A),
        );
      case BoardThemeOption.wood:
        return const BoardColors(
          lightSquare: Color(0xFFF0D9B5),
          darkSquare: Color(0xFFB58863),
          selectedSquare: Color(0xFFDDA653),
          highlightSquare: Color(0xFFE9C579),
          lastMoveLight: Color(0xFFD3A466),
          lastMoveDark: Color(0xFF8F5831),
        );
      case BoardThemeOption.midnight:
        return const BoardColors(
          lightSquare: Color(0xFF9EA3B0),
          darkSquare: Color(0xFF485268),
          selectedSquare: Color(0xFF6B87B5),
          highlightSquare: Color(0xFF8BA5CE),
          lastMoveLight: Color(0xFF677B9B),
          lastMoveDark: Color(0xFF333E53),
        );
      case BoardThemeOption.cyberpunk:
        return const BoardColors(
          lightSquare: Color(0xFF2D3748),
          darkSquare: Color(0xFF1A202C),
          selectedSquare: Color(0xFF00F5D4),
          highlightSquare: Color(0xFF7B2CBF),
          lastMoveLight: Color(0xFF00BBF9),
          lastMoveDark: Color(0xFFF15BB5),
        );
    }
  }
}

class BoardColors {
  final Color lightSquare;
  final Color darkSquare;
  final Color selectedSquare;
  final Color highlightSquare;
  final Color lastMoveLight;
  final Color lastMoveDark;

  const BoardColors({
    required this.lightSquare,
    required this.darkSquare,
    required this.selectedSquare,
    required this.highlightSquare,
    required this.lastMoveLight,
    required this.lastMoveDark,
  });
}
