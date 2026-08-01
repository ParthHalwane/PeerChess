import 'time_control.dart';

class ClockState {
  final int whiteRemainingMs;
  final int blackRemainingMs;
  final String activeTurn; // 'w' or 'b'
  final bool isRunning;
  final bool isPaused;
  final int activeDelayMs;
  final TimeControl timeControl;

  const ClockState({
    required this.whiteRemainingMs,
    required this.blackRemainingMs,
    this.activeTurn = 'w',
    this.isRunning = false,
    this.isPaused = false,
    this.activeDelayMs = 0,
    required this.timeControl,
  });

  ClockState copyWith({
    int? whiteRemainingMs,
    int? blackRemainingMs,
    String? activeTurn,
    bool? isRunning,
    bool? isPaused,
    int? activeDelayMs,
    TimeControl? timeControl,
  }) {
    return ClockState(
      whiteRemainingMs: whiteRemainingMs ?? this.whiteRemainingMs,
      blackRemainingMs: blackRemainingMs ?? this.blackRemainingMs,
      activeTurn: activeTurn ?? this.activeTurn,
      isRunning: isRunning ?? this.isRunning,
      isPaused: isPaused ?? this.isPaused,
      activeDelayMs: activeDelayMs ?? this.activeDelayMs,
      timeControl: timeControl ?? this.timeControl,
    );
  }
}
