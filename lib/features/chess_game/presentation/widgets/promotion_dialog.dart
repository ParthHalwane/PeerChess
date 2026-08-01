import 'package:flutter/material.dart';

class PromotionDialog extends StatelessWidget {
  final String playerColor; // 'w' or 'b'

  const PromotionDialog({
    super.key,
    required this.playerColor,
  });

  @override
  Widget build(BuildContext context) {
    final bool isWhite = playerColor == 'w';

    final choices = [
      {'code': 'q', 'symbol': isWhite ? '♕' : '♛', 'name': 'Queen'},
      {'code': 'r', 'symbol': isWhite ? '♖' : '♜', 'name': 'Rook'},
      {'code': 'b', 'symbol': isWhite ? '♗' : '♝', 'name': 'Bishop'},
      {'code': 'n', 'symbol': isWhite ? '♘' : '♞', 'name': 'Knight'},
    ];

    return AlertDialog(
      backgroundColor: const Color(0xFF1E1E24),
      title: const Text(
        'Promote Pawn',
        textAlign: TextAlign.center,
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
      content: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: choices.map((item) {
          return InkWell(
            onTap: () => Navigator.of(context).pop(item['code']),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF26262E),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF81B64C), width: 1.5),
              ),
              child: Text(
                item['symbol']!,
                style: const TextStyle(fontSize: 36),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
