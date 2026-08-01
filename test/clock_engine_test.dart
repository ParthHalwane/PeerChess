import 'package:flutter_test/flutter_test.dart';
import 'package:peer_chess/features/clock/domain/time_control.dart';
import 'package:peer_chess/features/clock/engine/high_precision_clock_engine.dart';

void main() {
  group('HighPrecisionClockEngine Tests', () {
    late HighPrecisionClockEngine clockEngine;

    setUp(() {
      clockEngine = HighPrecisionClockEngine();
    });

    tearDown(() {
      clockEngine.dispose();
    });

    test('Initializes with exact preset times', () {
      clockEngine.initialize(TimeControl.blitz5m);
      expect(clockEngine.state.whiteRemainingMs, equals(300000));
      expect(clockEngine.state.blackRemainingMs, equals(300000));
      expect(clockEngine.state.activeTurn, equals('w'));
      expect(clockEngine.state.isRunning, isFalse);
    });

    test('Switch turn applies increment correctly', () {
      clockEngine.initialize(const TimeControl(
        name: 'Custom Blitz',
        initialSeconds: 180,
        incrementSeconds: 3,
      ));

      clockEngine.switchTurn(nextTurn: 'b');
      // White gets +3000ms increment
      expect(clockEngine.state.whiteRemainingMs, equals(183000));
      expect(clockEngine.state.activeTurn, equals('b'));
    });

    test('Host authoritative state sync compensates latency', () {
      clockEngine.initialize(TimeControl.blitz5m);
      clockEngine.syncState(
        whiteRemainingMs: 290000,
        blackRemainingMs: 295000,
        activeTurn: 'b',
        isRunning: true,
        latencyMs: 100, // 100ms RTT latency
      );

      expect(clockEngine.state.activeTurn, equals('b'));
      // Black should have ~50ms latency compensation subtracted
      expect(clockEngine.state.blackRemainingMs, equals(294950));
      expect(clockEngine.state.whiteRemainingMs, equals(290000));
    });
  });
}
