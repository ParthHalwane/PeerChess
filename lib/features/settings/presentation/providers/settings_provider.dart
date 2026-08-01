import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/sound_manager.dart';
import '../../domain/app_settings.dart';

class SettingsNotifier extends StateNotifier<AppSettings> {
  SettingsNotifier() : super(const AppSettings()) {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final themeIndex = prefs.getInt('boardTheme') ?? 0;
    final sound = prefs.getBool('soundEnabled') ?? true;
    final vibration = prefs.getBool('vibrationEnabled') ?? true;
    final wakelock = prefs.getBool('keepScreenAwake') ?? true;

    final theme = BoardThemeOption.values.elementAt(
      themeIndex.clamp(0, BoardThemeOption.values.length - 1),
    );

    state = AppSettings(
      boardTheme: theme,
      soundEnabled: sound,
      vibrationEnabled: vibration,
      keepScreenAwake: wakelock,
    );

    SoundManager().soundEnabled = sound;
    SoundManager().vibrationEnabled = vibration;
    if (wakelock) {
      WakelockPlus.enable();
    }
  }

  Future<void> updateBoardTheme(BoardThemeOption theme) async {
    state = state.copyWith(boardTheme: theme);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('boardTheme', theme.index);
  }

  Future<void> toggleSound(bool enabled) async {
    state = state.copyWith(soundEnabled: enabled);
    SoundManager().soundEnabled = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('soundEnabled', enabled);
  }

  Future<void> toggleVibration(bool enabled) async {
    state = state.copyWith(vibrationEnabled: enabled);
    SoundManager().vibrationEnabled = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('vibrationEnabled', enabled);
  }

  Future<void> toggleKeepScreenAwake(bool enabled) async {
    state = state.copyWith(keepScreenAwake: enabled);
    if (enabled) {
      WakelockPlus.enable();
    } else {
      WakelockPlus.disable();
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('keepScreenAwake', enabled);
  }
}

final settingsProvider = StateNotifierProvider<SettingsNotifier, AppSettings>((ref) {
  return SettingsNotifier();
});
