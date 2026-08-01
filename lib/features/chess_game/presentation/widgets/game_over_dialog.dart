import 'package:flutter/material.dart';

class GameOverDialog extends StatelessWidget {
  final String title;
  final String statusMessage;
  final VoidCallback onSaveAndExit;
  final VoidCallback? onPlayAgain;

  const GameOverDialog({
    super.key,
    required this.title,
    required this.statusMessage,
    required this.onSaveAndExit,
    this.onPlayAgain,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF1E1E24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Column(
        children: [
          const Icon(
            Icons.emoji_events,
            color: Color(0xFFF7C04A),
            size: 48,
          ),
          const SizedBox(height: 10),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 22,
            ),
          ),
        ],
      ),
      content: Text(
        statusMessage,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Colors.grey.shade300,
          fontSize: 16,
        ),
      ),
      actionsAlignment: MainAxisAlignment.spaceEvenly,
      actions: [
        if (onPlayAgain != null)
          ElevatedButton.icon(
            onPressed: onPlayAgain,
            icon: const Icon(Icons.replay),
            label: const Text('Play Again'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF81B64C),
              foregroundColor: Colors.black,
            ),
          ),
        OutlinedButton.icon(
          onPressed: onSaveAndExit,
          icon: const Icon(Icons.exit_to_app),
          label: const Text('Save & Exit'),
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.white,
          ),
        ),
      ],
    );
  }
}
