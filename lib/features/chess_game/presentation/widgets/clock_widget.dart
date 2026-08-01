import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class ClockWidget extends StatelessWidget {
  final int remainingMs;
  final bool isActive;
  final String playerName;
  final String playerColor;
  final int delayMs;

  const ClockWidget({
    super.key,
    required this.remainingMs,
    required this.isActive,
    required this.playerName,
    required this.playerColor,
    this.delayMs = 0,
  });

  String _formatTime(int ms) {
    if (ms <= 0) return '00:00';
    int totalSeconds = ms ~/ 1000;
    int minutes = totalSeconds ~/ 60;
    int seconds = totalSeconds % 60;
    int tenths = (ms % 1000) ~/ 100;

    if (totalSeconds < 10) {
      // Under 10s format: ss.t (tenths of a second precision)
      return '$seconds.$tenths';
    } else {
      String minStr = minutes.toString().padLeft(2, '0');
      String secStr = seconds.toString().padLeft(2, '0');
      return '$minStr:$secStr';
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isLowTime = remainingMs < 10000;

    return Card(
      color: isActive
          ? (isLowTime ? Colors.red.shade900 : const Color(0xFF33333E))
          : const Color(0xFF1E1E24),
      elevation: isActive ? 6 : 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: isActive
            ? BorderSide(
                color: isLowTime ? Colors.redAccent : const Color(0xFF81B64C),
                width: 2,
              )
            : BorderSide.none,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    color: playerColor == 'w' ? Colors.white : Colors.black,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.grey.shade400, width: 1.5),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  playerName,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isActive ? Colors.white : Colors.grey.shade400,
                  ),
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (delayMs > 0 && isActive)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 2.0),
                    child: Text(
                      'Delay: ${(delayMs / 1000).toStringAsFixed(1)}s',
                      style: const TextStyle(
                        fontSize: 11,
                        color: Colors.amberAccent,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                Text(
                  _formatTime(remainingMs),
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: isLowTime
                        ? Colors.redAccent
                        : (isActive ? Colors.white : Colors.grey.shade400),
                  ),
                ).animate(target: isLowTime && isActive ? 1 : 0).shake(
                      duration: 400.ms,
                      hz: 2,
                    ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
