import 'package:flutter/material.dart';

class CapturedPiecesWidget extends StatelessWidget {
  final List<String> capturedPieces; // e.g. ['P', 'P', 'N', 'R']
  final bool isWhite;

  const CapturedPiecesWidget({
    super.key,
    required this.capturedPieces,
    required this.isWhite,
  });

  static const Map<String, int> pieceValues = {
    'P': 1,
    'N': 3,
    'B': 3,
    'R': 5,
    'Q': 9,
  };

  static const Map<String, String> pieceSymbolsWhite = {
    'P': '♙',
    'N': '♘',
    'B': '♗',
    'R': '♖',
    'Q': '♕',
  };

  static const Map<String, String> pieceSymbolsBlack = {
    'P': '♟',
    'N': '♞',
    'B': '♝',
    'R': '♜',
    'Q': '♛',
  };

  int get totalMaterialValue => capturedPieces.fold(
        0,
        (sum, p) => sum + (pieceValues[p.toUpperCase()] ?? 0),
      );

  @override
  Widget build(BuildContext context) {
    if (capturedPieces.isEmpty) {
      return const SizedBox(height: 20);
    }

    final symbols = isWhite ? pieceSymbolsWhite : pieceSymbolsBlack;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      child: Row(
        children: [
          Wrap(
            spacing: 2,
            children: capturedPieces.map((piece) {
              return Text(
                symbols[piece.toUpperCase()] ?? piece,
                style: TextStyle(
                  fontSize: 18,
                  color: isWhite ? Colors.grey.shade300 : Colors.grey.shade700,
                ),
              );
            }).toList(),
          ),
          const SizedBox(width: 6),
          if (totalMaterialValue > 0)
            Text(
              '+$totalMaterialValue',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade400,
              ),
            ),
        ],
      ),
    );
  }
}
