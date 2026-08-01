import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class ReconnectingOverlay extends StatelessWidget {
  final bool isVisible;

  const ReconnectingOverlay({
    super.key,
    required this.isVisible,
  });

  @override
  Widget build(BuildContext context) {
    if (!isVisible) return const SizedBox.shrink();

    return Container(
      color: Colors.black87,
      child: Center(
        child: Card(
          color: const Color(0xFF26262E),
          margin: const EdgeInsets.all(24),
          elevation: 12,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(
                  color: Color(0xFF81B64C),
                  strokeWidth: 3,
                ).animate().scale(duration: 500.ms),
                const SizedBox(height: 20),
                const Text(
                  'Connection Lost',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Clocks frozen. Reconnecting via Nearby Connections...',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade400,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
