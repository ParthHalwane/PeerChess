import 'package:flutter/material.dart';
import 'package:chess_vectors_flutter/chess_vectors_flutter.dart';

class ChessPieceWidget extends StatelessWidget {
  final String piece; // 'K', 'Q', 'R', 'B', 'N', 'P' or 'k', 'q', 'r', 'b', 'n', 'p'
  final double size;

  const ChessPieceWidget({
    super.key,
    required this.piece,
    this.size = 40,
  });

  @override
  Widget build(BuildContext context) {
    Widget pieceWidget;

    switch (piece) {
      case 'K':
        pieceWidget = WhiteKing(size: size);
        break;
      case 'Q':
        pieceWidget = WhiteQueen(size: size);
        break;
      case 'R':
        pieceWidget = WhiteRook(size: size);
        break;
      case 'B':
        pieceWidget = WhiteBishop(size: size);
        break;
      case 'N':
        pieceWidget = WhiteKnight(size: size);
        break;
      case 'P':
        pieceWidget = WhitePawn(size: size);
        break;
      case 'k':
        pieceWidget = BlackKing(size: size);
        break;
      case 'q':
        pieceWidget = BlackQueen(size: size);
        break;
      case 'r':
        pieceWidget = BlackRook(size: size);
        break;
      case 'b':
        pieceWidget = BlackBishop(size: size);
        break;
      case 'n':
        pieceWidget = BlackKnight(size: size);
        break;
      case 'p':
        pieceWidget = BlackPawn(size: size);
        break;
      default:
        return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.all(3.0),
      child: pieceWidget,
    );
  }
}
