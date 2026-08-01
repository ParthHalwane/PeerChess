import '../../../core/constants/app_constants.dart';

class AppSettings {
  final BoardThemeOption boardTheme;
  final String pieceStyle;
  final bool soundEnabled;
  final bool vibrationEnabled;
  final bool keepScreenAwake;
  final double animationSpeed;

  const AppSettings({
    this.boardTheme = BoardThemeOption.chessCom,
    this.pieceStyle = 'standard',
    this.soundEnabled = true,
    this.vibrationEnabled = true,
    this.keepScreenAwake = true,
    this.animationSpeed = 1.0,
  });

  AppSettings copyWith({
    BoardThemeOption? boardTheme,
    String? pieceStyle,
    bool? soundEnabled,
    bool? vibrationEnabled,
    bool? keepScreenAwake,
    double? animationSpeed,
  }) {
    return AppSettings(
      boardTheme: boardTheme ?? this.boardTheme,
      pieceStyle: pieceStyle ?? this.pieceStyle,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      vibrationEnabled: vibrationEnabled ?? this.vibrationEnabled,
      keepScreenAwake: keepScreenAwake ?? this.keepScreenAwake,
      animationSpeed: animationSpeed ?? this.animationSpeed,
    );
  }
}
