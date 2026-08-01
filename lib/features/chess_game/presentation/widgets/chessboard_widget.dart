import 'package:flutter/material.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/chess_game_state.dart';
import 'chess_piece_widget.dart';

class ChessboardWidget extends StatelessWidget {
  final ChessGameState state;
  final BoardThemeOption boardTheme;
  final Function(String square) onSquareTap;
  final bool flipBoard;

  const ChessboardWidget({
    super.key,
    required this.state,
    required this.boardTheme,
    required this.onSquareTap,
    this.flipBoard = false,
  });

  static const Map<String, String> pieceUnicodeMap = {
    'K': '♔', 'Q': '♕', 'R': '♖', 'B': '♗', 'N': '♘', 'P': '♙',
    'k': '♚', 'q': '♛', 'r': '♜', 'b': '♝', 'n': '♞', 'p': '♟',
  };

  /// Parse FEN into a 2D matrix (8x8) of piece characters or empty string
  List<List<String>> _parseFen(String fen) {
    List<List<String>> board = List.generate(8, (_) => List.filled(8, ''));
    String boardPart = fen.split(' ')[0];
    List<String> ranks = boardPart.split('/');

    for (int r = 0; r < 8; r++) {
      int col = 0;
      for (int i = 0; i < ranks[r].length; i++) {
        String char = ranks[r][i];
        if (RegExp(r'[1-8]').hasMatch(char)) {
          col += int.parse(char);
        } else {
          board[r][col] = char;
          col++;
        }
      }
    }
    return board;
  }

  String _coordsToAlgebraic(int rankIdx, int fileIdx) {
    int file = fileIdx;
    int rank = 8 - rankIdx;
    String fileChar = String.fromCharCode('a'.codeUnitAt(0) + file);
    return '$fileChar$rank';
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.getBoardColors(boardTheme);
    final boardMatrix = _parseFen(state.fen);

    return AspectRatio(
      aspectRatio: 1.0,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.5),
              blurRadius: 10,
              spreadRadius: 2,
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          itemCount: 64,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 8,
          ),
          itemBuilder: (context, index) {
            int displayRank = index ~/ 8;
            int displayFile = index % 8;

            int actualRank = flipBoard ? 7 - displayRank : displayRank;
            int actualFile = flipBoard ? 7 - displayFile : displayFile;

            bool isLightSquare = (actualRank + actualFile) % 2 == 0;
            String squareName = _coordsToAlgebraic(actualRank, actualFile);
            String piece = boardMatrix[actualRank][actualFile];

            bool isSelected = state.selectedSquare == squareName;
            bool isLegalDest = state.legalDestinationSquares.contains(squareName);
            bool isLastMoveFrom = state.lastMoveFrom == squareName;
            bool isLastMoveTo = state.lastMoveTo == squareName;

            bool isKingInCheck = false;
            if (state.inCheck && piece.toUpperCase() == 'K') {
              if ((state.turn == 'w' && piece == 'K') ||
                  (state.turn == 'b' && piece == 'k')) {
                isKingInCheck = true;
              }
            }

            Color squareColor = isLightSquare ? colors.lightSquare : colors.darkSquare;
            if (isLastMoveFrom || isLastMoveTo) {
              squareColor = isLightSquare ? colors.lastMoveLight : colors.lastMoveDark;
            }
            if (isSelected) {
              squareColor = colors.selectedSquare;
            }
            if (isKingInCheck) {
              squareColor = Colors.red.shade700;
            }

            return GestureDetector(
              onTap: () => onSquareTap(squareName),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                curve: Curves.easeOutCubic,
                color: squareColor,
                child: Stack(
                  children: [
                    // File/Rank labels on board edges
                    if (actualFile == 0)
                      Positioned(
                        top: 2,
                        left: 2,
                        child: Text(
                          '${8 - actualRank}',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: isLightSquare ? colors.darkSquare : colors.lightSquare,
                          ),
                        ),
                      ),
                    if (actualRank == 7)
                      Positioned(
                        bottom: 2,
                        right: 2,
                        child: Text(
                          String.fromCharCode('a'.codeUnitAt(0) + actualFile),
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: isLightSquare ? colors.darkSquare : colors.lightSquare,
                          ),
                        ),
                      ),
                    // Vector SVG Piece Rendering
                    if (piece.isNotEmpty)
                      Center(
                        child: AnimatedScale(
                          duration: const Duration(milliseconds: 120),
                          scale: isSelected ? 1.12 : 1.0,
                          curve: Curves.easeOutBack,
                          child: ChessPieceWidget(
                            piece: piece,
                          ),
                        ),
                      ),
                    // Legal Move Dot or Ring
                    if (isLegalDest)
                      Center(
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 120),
                          width: piece.isEmpty ? 14 : 34,
                          height: piece.isEmpty ? 14 : 34,
                          decoration: BoxDecoration(
                            color: piece.isEmpty
                                ? const Color(0x5581B64C)
                                : Colors.transparent,
                            shape: BoxShape.circle,
                            border: piece.isNotEmpty
                                ? Border.all(
                                    color: const Color(0xAA81B64C),
                                    width: 3.5,
                                  )
                                : null,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
