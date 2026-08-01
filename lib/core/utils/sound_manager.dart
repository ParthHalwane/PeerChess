import 'package:vibration/vibration.dart';

class SoundManager {
  static final SoundManager _instance = SoundManager._internal();
  factory SoundManager() => _instance;
  SoundManager._internal();

  bool soundEnabled = true;
  bool vibrationEnabled = true;

  Future<void> playMoveSound() async {
    if (vibrationEnabled) {
      bool? hasVibrator = await Vibration.hasVibrator();
      if (hasVibrator == true) {
        Vibration.vibrate(duration: 25, amplitude: 60);
      }
    }
  }

  Future<void> playCaptureSound() async {
    if (vibrationEnabled) {
      bool? hasVibrator = await Vibration.hasVibrator();
      if (hasVibrator == true) {
        Vibration.vibrate(duration: 45, amplitude: 120);
      }
    }
  }

  Future<void> playCheckSound() async {
    if (vibrationEnabled) {
      bool? hasVibrator = await Vibration.hasVibrator();
      if (hasVibrator == true) {
        Vibration.vibrate(pattern: [0, 50, 50, 50], intensities: [0, 150, 0, 200]);
      }
    }
  }

  Future<void> playGameEndSound() async {
    if (vibrationEnabled) {
      bool? hasVibrator = await Vibration.hasVibrator();
      if (hasVibrator == true) {
        Vibration.vibrate(pattern: [0, 100, 100, 200], intensities: [0, 200, 0, 255]);
      }
    }
  }
}
