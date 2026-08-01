import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../history/presentation/providers/history_provider.dart';
import '../../../p2p/domain/p2p_connection_state.dart';
import '../../../p2p/presentation/providers/p2p_provider.dart';
import '../../../settings/presentation/providers/settings_provider.dart';
import '../../domain/chess_game_state.dart';
import '../../domain/game_history_item.dart';
import '../providers/game_notifier.dart';
import '../widgets/captured_pieces_widget.dart';
import '../widgets/chessboard_widget.dart';
import '../widgets/clock_widget.dart';
import '../widgets/game_over_dialog.dart';
import '../widgets/promotion_dialog.dart';
import '../widgets/reconnecting_overlay.dart';

class GameScreen extends ConsumerStatefulWidget {
  final String playerColor; // 'w' or 'b'
  final bool isHost;
  final bool isOfflineAi;

  const GameScreen({
    super.key,
    required this.playerColor,
    required this.isHost,
    this.isOfflineAi = false,
  });

  @override
  ConsumerState<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends ConsumerState<GameScreen> {
  bool _manualFlipBoard = false;
  bool _isDialogOpen = false;

  @override
  void initState() {
    super.initState();
    // Default orientation: Black player sees black at bottom
    _manualFlipBoard = widget.playerColor == 'b';
  }

  void _dismissOpenDialog() {
    if (_isDialogOpen && Navigator.of(context).canPop()) {
      _isDialogOpen = false;
      Navigator.of(context).pop();
    }
  }

  void _handleSquareTap(String square) async {
    final gameNotifier = ref.read(gameNotifierProvider.notifier);
    final gameState = ref.read(gameNotifierProvider);

    if (gameState.selectedSquare != null &&
        gameNotifier.isPromotionMove(gameState.selectedSquare!, square)) {
      _isDialogOpen = true;
      final promotionChoice = await showDialog<String>(
        context: context,
        barrierDismissible: false,
        builder: (_) => PromotionDialog(playerColor: gameState.localPlayerColor),
      );
      _isDialogOpen = false;
      if (promotionChoice != null) {
        gameNotifier.onAttemptMove(gameState.selectedSquare!, square, promotion: promotionChoice);
      }
    } else {
      gameNotifier.selectSquare(square);
    }
  }

  void _showGameOverDialog(ChessGameState gameState) {
    _isDialogOpen = true;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => GameOverDialog(
        title: gameState.winner == 'draw'
            ? 'Game Draw'
            : (gameState.winner == gameState.localPlayerColor ? 'You Won!' : 'You Lost'),
        statusMessage: gameState.statusMessage,
        onPlayAgain: () {
          _dismissOpenDialog();
          ref.read(gameNotifierProvider.notifier).offerRematch();
        },
        onSaveAndExit: () async {
          try {
            final gameNotifier = ref.read(gameNotifierProvider.notifier);
            final historyNotifier = ref.read(historyProvider.notifier);

            final historyItem = GameHistoryItem(
              id: DateTime.now().millisecondsSinceEpoch.toString(),
              whitePlayer: widget.isHost ? 'Host (White)' : 'Peer (White)',
              blackPlayer: widget.isHost ? 'Peer (Black)' : 'Host (Black)',
              pgn: gameNotifier.getPgn(),
              finalFen: gameState.fen,
              winner: gameState.winner == 'w'
                  ? 'White'
                  : (gameState.winner == 'b' ? 'Black' : 'Draw'),
              timeControl: '5 min Blitz',
              movesCount: gameState.sanMoves.length,
              durationSeconds: 300,
              dateIso: DateTime.now().toIso8601String(),
            );

            await historyNotifier.saveGame(historyItem);
          } catch (e) {
            debugPrint('Error saving game history: $e');
          } finally {
            if (mounted) {
              _isDialogOpen = false;
              Navigator.of(context).popUntil((route) => route.isFirst);
            }
          }
        },
      ),
    );
  }

  void _showResignConfirmationDialog() {
    _isDialogOpen = true;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Confirm Resignation', style: TextStyle(color: Colors.white)),
        content: const Text(
          'Are you sure you want to resign this game?',
          style: TextStyle(color: Colors.grey),
        ),
        actions: [
          TextButton(
            onPressed: () {
              _dismissOpenDialog();
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              _dismissOpenDialog();
              ref.read(gameNotifierProvider.notifier).resign();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade800),
            child: const Text('Resign', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final gameState = ref.watch(gameNotifierProvider);
    final gameNotifier = ref.read(gameNotifierProvider.notifier);
    final clockState = gameNotifier.clockState;
    final p2pStatus = ref.watch(p2pStateProvider);
    final settings = ref.watch(settingsProvider);

    // Listen for Game Over trigger or Rematch Offer
    ref.listen<ChessGameState>(gameNotifierProvider, (prev, next) {
      if (prev?.resultStatus == GameResultStatus.active &&
          next.resultStatus != GameResultStatus.active) {
        _showGameOverDialog(next);
      } else if (prev?.resultStatus != GameResultStatus.active &&
          next.resultStatus == GameResultStatus.active) {
        // Rematch started: safely dismiss any open modal dialog
        _dismissOpenDialog();
      } else if ((prev?.hasPendingRematchOffer != true) && next.hasPendingRematchOffer) {
        // Rematch offer received: safely dismiss modal dialog so top banner is 100% clickable!
        _dismissOpenDialog();
      }
    });

    final String localColor = gameState.localPlayerColor;
    final bool isOpponentTurn = gameState.turn != localColor;
    final String opponentColor = localColor == 'w' ? 'b' : 'w';
    final bool autoFlip = localColor == 'b';

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isOfflineAi ? 'Play vs AI' : 'Offline Peer Game'),
        actions: [
          IconButton(
            icon: const Icon(Icons.flip_camera_android),
            tooltip: 'Flip Board',
            onPressed: () {
              setState(() {
                _manualFlipBoard = !_manualFlipBoard;
              });
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Column(
                children: [
                  // Top Opponent Clock & Captured Pieces
                  Column(
                    children: [
                      ClockWidget(
                        playerName: widget.isOfflineAi
                            ? 'AI Engine'
                            : (p2pStatus.connectedPeerName ?? 'Opponent'),
                        playerColor: opponentColor,
                        remainingMs: opponentColor == 'w'
                            ? clockState.whiteRemainingMs
                            : clockState.blackRemainingMs,
                        isActive: isOpponentTurn && clockState.isRunning,
                        delayMs: isOpponentTurn ? clockState.activeDelayMs : 0,
                      ),
                      CapturedPiecesWidget(
                        capturedPieces: opponentColor == 'w'
                            ? gameState.capturedByWhite
                            : gameState.capturedByBlack,
                        isWhite: opponentColor == 'w',
                      ),
                    ],
                  ),

                  const Spacer(),

                  // Interactive Chessboard
                  ChessboardWidget(
                    state: gameState,
                    boardTheme: settings.boardTheme,
                    onSquareTap: _handleSquareTap,
                    flipBoard: _manualFlipBoard || autoFlip,
                  ),

                  const Spacer(),

                  // Bottom Player Clock & Captured Pieces
                  Column(
                    children: [
                      CapturedPiecesWidget(
                        capturedPieces: localColor == 'w'
                            ? gameState.capturedByWhite
                            : gameState.capturedByBlack,
                        isWhite: localColor == 'w',
                      ),
                      ClockWidget(
                        playerName: 'You (${localColor == 'w' ? 'White' : 'Black'})',
                        playerColor: localColor,
                        remainingMs: localColor == 'w'
                            ? clockState.whiteRemainingMs
                            : clockState.blackRemainingMs,
                        isActive: !isOpponentTurn && clockState.isRunning,
                        delayMs: !isOpponentTurn ? clockState.activeDelayMs : 0,
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Action Controls Bar
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      OutlinedButton.icon(
                        onPressed: gameState.resultStatus == GameResultStatus.active
                            ? () => gameNotifier.offerDraw()
                            : null,
                        icon: const Icon(Icons.handshake_outlined),
                        label: const Text('Draw'),
                      ),
                      ElevatedButton.icon(
                        onPressed: gameState.resultStatus == GameResultStatus.active
                            ? () => _showResignConfirmationDialog()
                            : null,
                        icon: const Icon(Icons.flag_outlined),
                        label: const Text('Resign'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red.shade900,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Top Notification Banner for Draw Offer
          if (gameState.hasPendingDrawOffer)
            Positioned(
              top: 10,
              left: 16,
              right: 16,
              child: Material(
                elevation: 8,
                borderRadius: BorderRadius.circular(12),
                color: const Color(0xFF2A2B32),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF81B64C), width: 1.5),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.handshake, color: Color(0xFF81B64C)),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'Opponent offered a draw',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.redAccent),
                        onPressed: () => gameNotifier.respondDrawOffer(false),
                      ),
                      IconButton(
                        icon: const Icon(Icons.check, color: Color(0xFF81B64C)),
                        onPressed: () => gameNotifier.respondDrawOffer(true),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // Top Notification Banner for Rematch Request
          if (gameState.hasPendingRematchOffer)
            Positioned(
              top: 10,
              left: 16,
              right: 16,
              child: Material(
                elevation: 8,
                borderRadius: BorderRadius.circular(12),
                color: const Color(0xFF2A2B32),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF81B64C), width: 1.5),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.replay, color: Color(0xFF81B64C)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          '${gameState.rematchOfferPlayerName ?? "Opponent"} wants to play again!',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.redAccent),
                        onPressed: () => gameNotifier.respondRematchOffer(false),
                      ),
                      IconButton(
                        icon: const Icon(Icons.check, color: Color(0xFF81B64C)),
                        onPressed: () => gameNotifier.respondRematchOffer(true),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // Reconnection Overlay
          ReconnectingOverlay(
            isVisible: p2pStatus.state == P2pState.reconnecting,
          ),
        ],
      ),
    );
  }
}
