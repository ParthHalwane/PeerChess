import 'package:flutter/material.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../chess_game/domain/chess_game_state.dart';
import '../../../chess_game/domain/game_history_item.dart';
import '../../../chess_game/presentation/widgets/chessboard_widget.dart';

class PgnViewerScreen extends StatelessWidget {
  final GameHistoryItem game;

  const PgnViewerScreen({
    super.key,
    required this.game,
  });

  @override
  Widget build(BuildContext context) {
    final previewState = ChessGameState(
      fen: game.finalFen.isNotEmpty
          ? game.finalFen
          : 'rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1',
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Game Replay & PGN'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Final position chessboard preview
              ChessboardWidget(
                state: previewState,
                boardTheme: BoardThemeOption.chessCom,
                onSquareTap: (_) {},
              ),

              const SizedBox(height: 20),

              // Game Info Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('White: ${game.whitePlayer}',
                              style: const TextStyle(fontWeight: FontWeight.bold)),
                          Text('Black: ${game.blackPlayer}',
                              style: const TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Result: ${game.winner}',
                              style: const TextStyle(color: Color(0xFF81B64C))),
                          Text('Moves: ${game.movesCount}',
                              style: const TextStyle(color: Colors.grey)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              const Text(
                'PGN Record',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),

              Expanded(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E1E24),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade800),
                  ),
                  child: SingleChildScrollView(
                    child: SelectableText(
                      game.pgn.isNotEmpty ? game.pgn : '[PGN unavailable]',
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 13,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
