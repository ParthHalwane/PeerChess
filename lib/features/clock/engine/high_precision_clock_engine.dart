import 'dart:async';
import '../domain/clock_state.dart';
import '../domain/time_control.dart';

typedef OnClockTickCallback = void Function(ClockState state);
typedef OnTimeFlaggedCallback = void Function(String playerColor);

class HighPrecisionClockEngine {
  final Stopwatch _stopwatch = Stopwatch();
  Timer? _tickerTimer;

  late ClockState _state;
  
  OnClockTickCallback? onTick;
  OnTimeFlaggedCallback? onTimeFlagged;

  int _lastTickElapsedMs = 0;
  int _turnDelayRemainingMs = 0;

  ClockState get state => _state;

  void initialize(TimeControl timeControl) {
    stop();
    _state = ClockState(
      whiteRemainingMs: timeControl.initialSeconds * 1000,
      blackRemainingMs: timeControl.initialSeconds * 1000,
      activeTurn: 'w',
      isRunning: false,
      isPaused: false,
      activeDelayMs: timeControl.delaySeconds * 1000,
      timeControl: timeControl,
    );
    _turnDelayRemainingMs = timeControl.delaySeconds * 1000;
  }

  void start() {
    if (_state.isRunning) return;
    _stopwatch.reset();
    _stopwatch.start();
    _lastTickElapsedMs = 0;
    _state = _state.copyWith(isRunning: true, isPaused: false);
    _startTicker();
  }

  void pause() {
    _stopwatch.stop();
    _tickerTimer?.cancel();
    _state = _state.copyWith(isRunning: false, isPaused: true);
    onTick?.call(_state);
  }

  void resume() {
    if (!_state.isPaused) return;
    _stopwatch.start();
    _lastTickElapsedMs = _stopwatch.elapsedMilliseconds;
    _state = _state.copyWith(isRunning: true, isPaused: false);
    _startTicker();
  }

  void stop() {
    _stopwatch.stop();
    _stopwatch.reset();
    _tickerTimer?.cancel();
    _tickerTimer = null;
  }

  void _startTicker() {
    _tickerTimer?.cancel();
    // 16ms interval (~60 FPS) for buttery smooth UI countdown
    _tickerTimer = Timer.periodic(const Duration(milliseconds: 16), (_) {
      _processTick();
    });
  }

  void _processTick() {
    if (!_state.isRunning || _state.isPaused) return;

    final currentElapsedMs = _stopwatch.elapsedMilliseconds;
    final deltaMs = currentElapsedMs - _lastTickElapsedMs;
    _lastTickElapsedMs = currentElapsedMs;

    if (deltaMs <= 0) return;

    int remainingDelta = deltaMs;

    // Handle Delay if active
    if (_turnDelayRemainingMs > 0) {
      if (_turnDelayRemainingMs >= remainingDelta) {
        _turnDelayRemainingMs -= remainingDelta;
        remainingDelta = 0;
      } else {
        remainingDelta -= _turnDelayRemainingMs;
        _turnDelayRemainingMs = 0;
      }
    }

    if (remainingDelta > 0) {
      if (_state.activeTurn == 'w') {
        int newWhiteMs = _state.whiteRemainingMs - remainingDelta;
        if (newWhiteMs <= 0) {
          newWhiteMs = 0;
          stop();
          _state = _state.copyWith(whiteRemainingMs: 0, isRunning: false);
          onTick?.call(_state);
          onTimeFlagged?.call('w');
          return;
        }
        _state = _state.copyWith(
          whiteRemainingMs: newWhiteMs,
          activeDelayMs: _turnDelayRemainingMs,
        );
      } else {
        int newBlackMs = _state.blackRemainingMs - remainingDelta;
        if (newBlackMs <= 0) {
          newBlackMs = 0;
          stop();
          _state = _state.copyWith(blackRemainingMs: 0, isRunning: false);
          onTick?.call(_state);
          onTimeFlagged?.call('b');
          return;
        }
        _state = _state.copyWith(
          blackRemainingMs: newBlackMs,
          activeDelayMs: _turnDelayRemainingMs,
        );
      }
    } else {
      _state = _state.copyWith(activeDelayMs: _turnDelayRemainingMs);
    }

    onTick?.call(_state);
  }

  /// Switch turn & apply increment/delay on move completion
  void switchTurn({required String nextTurn}) {
    // Apply Increment to previous turn player
    final incMs = _state.timeControl.incrementSeconds * 1000;
    int updatedWhiteMs = _state.whiteRemainingMs;
    int updatedBlackMs = _state.blackRemainingMs;

    if (_state.activeTurn == 'w' && incMs > 0) {
      updatedWhiteMs += incMs;
    } else if (_state.activeTurn == 'b' && incMs > 0) {
      updatedBlackMs += incMs;
    }

    _turnDelayRemainingMs = _state.timeControl.delaySeconds * 1000;
    _stopwatch.reset();
    _lastTickElapsedMs = 0;

    _state = _state.copyWith(
      whiteRemainingMs: updatedWhiteMs,
      blackRemainingMs: updatedBlackMs,
      activeTurn: nextTurn,
      activeDelayMs: _turnDelayRemainingMs,
    );

    if (_state.isRunning) {
      _stopwatch.start();
    }
    onTick?.call(_state);
  }

  /// Sync Host authoritative time into Client clock
  void syncState({
    required int whiteRemainingMs,
    required int blackRemainingMs,
    required String activeTurn,
    required bool isRunning,
    int latencyMs = 0,
  }) {
    // Latency compensation
    int latencyComp = (latencyMs > 20) ? (latencyMs ~/ 2) : 0;

    int compensatedWhite = whiteRemainingMs;
    int compensatedBlack = blackRemainingMs;

    if (isRunning && latencyComp > 0) {
      if (activeTurn == 'w') {
        compensatedWhite = (whiteRemainingMs - latencyComp).clamp(0, 9999999);
      } else {
        compensatedBlack = (blackRemainingMs - latencyComp).clamp(0, 9999999);
      }
    }

    _turnDelayRemainingMs = _state.timeControl.delaySeconds * 1000;
    _stopwatch.reset();
    _lastTickElapsedMs = 0;

    _state = _state.copyWith(
      whiteRemainingMs: compensatedWhite,
      blackRemainingMs: compensatedBlack,
      activeTurn: activeTurn,
      isRunning: isRunning,
      activeDelayMs: _turnDelayRemainingMs,
    );

    if (isRunning) {
      _stopwatch.start();
      _startTicker();
    } else {
      _stopwatch.stop();
      _tickerTimer?.cancel();
    }

    onTick?.call(_state);
  }

  void dispose() {
    stop();
  }
}
