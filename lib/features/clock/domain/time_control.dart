enum DelayType {
  none,
  simpleDelay,
  bronstein,
  fisherIncrement,
}

class TimeControl {
  final String name;
  final int initialSeconds;
  final int incrementSeconds;
  final int delaySeconds;
  final DelayType delayType;

  const TimeControl({
    required this.name,
    required this.initialSeconds,
    this.incrementSeconds = 0,
    this.delaySeconds = 0,
    this.delayType = DelayType.none,
  });

  static const TimeControl bullet1m = TimeControl(
    name: '1 min',
    initialSeconds: 60,
  );

  static const TimeControl blitz3m = TimeControl(
    name: '3 min',
    initialSeconds: 180,
  );

  static const TimeControl blitz5m = TimeControl(
    name: '5 min',
    initialSeconds: 300,
  );

  static const TimeControl rapid10m = TimeControl(
    name: '10 min',
    initialSeconds: 600,
  );

  static const TimeControl rapid15m = TimeControl(
    name: '15 min (10s inc)',
    initialSeconds: 900,
    incrementSeconds: 10,
    delayType: DelayType.fisherIncrement,
  );

  static const TimeControl classical30m = TimeControl(
    name: '30 min',
    initialSeconds: 1800,
  );

  static List<TimeControl> get defaultPresets => [
        bullet1m,
        blitz3m,
        blitz5m,
        rapid10m,
        rapid15m,
        classical30m,
      ];
}
