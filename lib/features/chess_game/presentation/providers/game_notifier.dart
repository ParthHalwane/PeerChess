import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/sound_manager.dart';
import '../../../clock/domain/clock_state.dart';
import '../../../clock/domain/time_control.dart';
import '../../../clock/engine/high_precision_clock_engine.dart';
import '../../../p2p/data/nearby_p2p_service.dart';
import '../../../p2p/domain/sync_packet.dart';
import '../../../p2p/presentation/providers/p2p_provider.dart';

import '../../domain/chess_game_state.dart';
import '../../engine/chess_engine_wrapper.dart';

class GameNotifier extends StateNotifier<ChessGameState> {
  final ChessEngineWrapper _engine = ChessEngineWrapper();
  final HighPrecisionClockEngine _clockEngine = HighPrecisionClockEngine();
  final NearbyP2pService _p2pService;

  TimeControl _timeControl = TimeControl.blitz5m;
  bool _isHost = true;
  bool _isOfflineAi = false;

  ClockState get clockState => _clockEngine.state;

  GameNotifier(this._p2pService) : super(const ChessGameState()) {
    _clockEngine.onTick = (cState) {
      // Re-trigger Riverpod state refresh for clock UI rebuild
      state = state.copyWith();
    };

    _clockEngine.onTimeFlagged = (flaggedColor) {
      _handleTimeFlagged(flaggedColor);
    };

    _p2pService.onPacketReceived = _handleIncomingPacket;
  }

  void startNewGame({
    required TimeControl timeControl,
    required bool isHost,
    required String playerColor,
    bool isOfflineAi = false,
  }) {
    _timeControl = timeControl;
    _isHost = isHost;
    _isOfflineAi = isOfflineAi;

    _engine.reset();
    _clockEngine.initialize(timeControl);

    state = ChessGameState(
      fen: _engine.fen,
      turn: _engine.turn,
      localPlayerColor: playerColor,
      sanMoves: [],
      uciMoves: [],
      capturedByWhite: [],
      capturedByBlack: [],
      inCheck: false,
      resultStatus: GameResultStatus.active,
      statusMessage: 'Game active',
    );

    if (_isHost && !_isOfflineAi) {
      _sendFullStatePacket();
    }

    _clockEngine.start();
  }

  void selectSquare(String square) {
    if (state.resultStatus != GameResultStatus.active) return;
    if (state.turn != state.localPlayerColor) return;

    final tappedPieceColor = _engine.getPieceColor(square);

    // If user tapped a piece of their OWN color, select it immediately
    if (tappedPieceColor == state.localPlayerColor) {
      if (state.selectedSquare == square) return;
      final legalDests = _engine.getLegalMovesForSquare(square);
      state = state.copyWith(
        selectedSquare: square,
        legalDestinationSquares: legalDests,
      );
      return;
    }

    // If user has a piece selected and taps a valid destination square
    if (state.selectedSquare != null &&
        state.legalDestinationSquares.contains(square)) {
      onAttemptMove(state.selectedSquare!, square);
      return;
    }

    // Tapping elsewhere clears selection
    state = state.copyWith(
      selectedSquare: null,
      legalDestinationSquares: [],
    );
  }

  bool isPromotionMove(String from, String to) {
    return _engine.isPromotionMove(from, to);
  }

  void onAttemptMove(String from, String to, {String? promotion}) {
    if (state.resultStatus != GameResultStatus.active) return;

    // Check turn
    if (state.turn != state.localPlayerColor) return;

    if (_isHost || _isOfflineAi) {
      _executeMoveHost(from, to, promotion: promotion);
    } else {
      // Client sends move proposal to Host
      final packet = SyncPacket(
        packetId: _p2pService.getNextSequenceId(),
        type: AppConstants.packetTypeMove,
        moveSan: null,
        moveUci: '$from$to${promotion ?? ''}',
        hostTimestamp: DateTime.now().millisecondsSinceEpoch,
        extraData: {
          'from': from,
          'to': to,
          'promotion': ?promotion,
        },
      );
      _p2pService.sendPacket(packet);
      state = state.copyWith(
        selectedSquare: null,
        legalDestinationSquares: [],
      );
    }
  }

  void _executeMoveHost(String from, String to, {String? promotion}) {
    final String? san = _engine.makeMove(from, to, promotion: promotion);
    if (san == null) return; // Illegal move

    // Play move or capture audio
    if (_engine.capturedByWhite.isNotEmpty || _engine.capturedByBlack.isNotEmpty) {
      SoundManager().playCaptureSound();
    } else {
      SoundManager().playMoveSound();
    }

    if (_engine.inCheck) {
      SoundManager().playCheckSound();
    }

    final String nextTurn = _engine.turn;
    _clockEngine.switchTurn(nextTurn: nextTurn);

    final result = _engine.getResultStatus();
    String? winner;
    if (result == GameResultStatus.checkmate) {
      winner = state.turn; // previous turn player won
      _clockEngine.stop();
      SoundManager().playGameEndSound();
    } else if (result != GameResultStatus.active) {
      winner = 'draw';
      _clockEngine.stop();
      SoundManager().playGameEndSound();
    }

    state = state.copyWith(
      fen: _engine.fen,
      sanMoves: List.from(_engine.sanHistory),
      uciMoves: List.from(_engine.uciHistory),
      capturedByWhite: List.from(_engine.capturedByWhite),
      capturedByBlack: List.from(_engine.capturedByBlack),
      turn: nextTurn,
      inCheck: _engine.inCheck,
      resultStatus: result,
      winner: winner,
      lastMoveFrom: from,
      lastMoveTo: to,
      selectedSquare: null,
      legalDestinationSquares: [],
      statusMessage: _getStatusMessage(result, winner),
    );

    if (!_isOfflineAi) {
      _sendMovePacket(from, to, san, promotion);
    } else if (_isOfflineAi && result == GameResultStatus.active && nextTurn != state.localPlayerColor) {
      // AI response after brief delay
      Timer(const Duration(milliseconds: 500), () {
        final botMove = _engine.generateBotMove();
        if (botMove != null) {
          _executeMoveHost(
            botMove['from']!,
            botMove['to']!,
            promotion: botMove['promotion'],
          );
        }
      });
    }
  }

  void _sendMovePacket(String from, String to, String san, String? promotion) {
    final packet = SyncPacket(
      packetId: _p2pService.getNextSequenceId(),
      type: AppConstants.packetTypeMove,
      boardFen: _engine.fen,
      moveSan: san,
      moveUci: '$from$to${promotion ?? ''}',
      moveNumber: state.sanMoves.length,
      whiteRemainingMs: _clockEngine.state.whiteRemainingMs,
      blackRemainingMs: _clockEngine.state.blackRemainingMs,
      currentTurn: state.turn,
      incrementMs: _timeControl.incrementSeconds * 1000,
      delayMs: _timeControl.delaySeconds * 1000,
      hostTimestamp: DateTime.now().millisecondsSinceEpoch,
      gameStatus: state.resultStatus.name,
      extraData: {
        'from': from,
        'to': to,
        'promotion': ?promotion,
      },
    );
    _p2pService.sendPacket(packet);
  }

  void _sendFullStatePacket() {
    final packet = SyncPacket(
      packetId: _p2pService.getNextSequenceId(),
      type: AppConstants.packetTypeFullState,
      boardFen: _engine.fen,
      moveNumber: state.sanMoves.length,
      whiteRemainingMs: _clockEngine.state.whiteRemainingMs,
      blackRemainingMs: _clockEngine.state.blackRemainingMs,
      currentTurn: state.turn,
      incrementMs: _timeControl.incrementSeconds * 1000,
      delayMs: _timeControl.delaySeconds * 1000,
      hostTimestamp: DateTime.now().millisecondsSinceEpoch,
      gameStatus: state.resultStatus.name,
      extraData: {
        'sanMoves': state.sanMoves,
        'uciMoves': state.uciMoves,
        'capturedByWhite': state.capturedByWhite,
        'capturedByBlack': state.capturedByBlack,
      },
    );
    _p2pService.sendPacket(packet);
  }

  void _handleIncomingPacket(SyncPacket packet) {
    switch (packet.type) {
      case AppConstants.packetTypeMove:
        if (_isHost) {
          // Host receives move request from client
          final from = packet.extraData['from'];
          final to = packet.extraData['to'];
          final promotion = packet.extraData['promotion'];
          if (from != null && to != null) {
            _executeMoveHost(from.toString(), to.toString(), promotion: promotion?.toString());
          }
        } else {
          // Client receives official move update from Host
          final from = packet.extraData['from']?.toString();
          final to = packet.extraData['to']?.toString();
          final promotion = packet.extraData['promotion']?.toString();

          if (from != null && to != null) {
            _engine.makeMove(from, to, promotion: promotion);
          } else if (packet.boardFen != null) {
            _engine.loadFen(packet.boardFen!);
          }

          final isGameOver = _engine.resultStatus != GameResultStatus.active;
          if (isGameOver) {
            _clockEngine.stop();
            SoundManager().playGameEndSound();
          } else {
            _clockEngine.syncState(
              whiteRemainingMs: packet.whiteRemainingMs,
              blackRemainingMs: packet.blackRemainingMs,
              activeTurn: packet.currentTurn,
              isRunning: true,
              latencyMs: DateTime.now().millisecondsSinceEpoch - packet.hostTimestamp,
            );
          }

          state = state.copyWith(
            fen: _engine.fen,
            sanMoves: List.from(_engine.sanHistory),
            uciMoves: List.from(_engine.uciHistory),
            turn: packet.currentTurn,
            inCheck: _engine.inCheck,
            lastMoveFrom: from,
            lastMoveTo: to,
            selectedSquare: null,
            legalDestinationSquares: [],
            resultStatus: _engine.resultStatus,
            winner: _engine.winnerColor,
            statusMessage: _getStatusMessage(_engine.resultStatus, _engine.winnerColor),
          );
        }
        break;

      case AppConstants.packetTypeFullState:
        if (!_isHost) {
          if (packet.boardFen != null) {
            _engine.loadFen(packet.boardFen!);
          }
          final isGameOver = _engine.resultStatus != GameResultStatus.active;
          if (isGameOver) {
            _clockEngine.stop();
          } else {
            _clockEngine.syncState(
              whiteRemainingMs: packet.whiteRemainingMs,
              blackRemainingMs: packet.blackRemainingMs,
              activeTurn: packet.currentTurn,
              isRunning: true,
            );
          }
          state = state.copyWith(
            fen: _engine.fen,
            turn: packet.currentTurn,
            inCheck: _engine.inCheck,
            resultStatus: _engine.resultStatus,
            winner: _engine.winnerColor,
            statusMessage: _getStatusMessage(_engine.resultStatus, _engine.winnerColor),
          );
        }
        break;

      case AppConstants.packetTypeDrawOffer:
        state = state.copyWith(hasPendingDrawOffer: true);
        break;

      case AppConstants.packetTypeDrawResponse:
        bool accepted = packet.extraData['accepted'] == true;
        if (accepted) {
          _clockEngine.stop();
          SoundManager().playGameEndSound();
          state = state.copyWith(
            resultStatus: GameResultStatus.drawAgreed,
            winner: 'draw',
            hasPendingDrawOffer: false,
            statusMessage: 'Draw agreed by mutual consent',
          );
        } else {
          state = state.copyWith(hasPendingDrawOffer: false);
        }
        break;

      case AppConstants.packetTypeRematchRequest:
        state = state.copyWith(
          hasPendingRematchOffer: true,
          rematchOfferPlayerName: packet.extraData['senderName']?.toString() ?? 'Opponent',
        );
        break;

      case AppConstants.packetTypeRematchResponse:
        bool accepted = packet.extraData['accepted'] == true;
        if (accepted) {
          final newColor = state.localPlayerColor == 'w' ? 'b' : 'w';
          startNewGame(
            timeControl: _timeControl,
            isHost: _isHost,
            playerColor: newColor,
            isOfflineAi: _isOfflineAi,
          );
        } else {
          state = state.copyWith(hasPendingRematchOffer: false);
        }
        break;

      case AppConstants.packetTypeResign:
        String resigningPlayer = packet.extraData['playerColor'] ?? 'w';
        String winner = resigningPlayer == 'w' ? 'b' : 'w';
        _clockEngine.stop();
        SoundManager().playGameEndSound();
        state = state.copyWith(
          resultStatus: GameResultStatus.resignation,
          winner: winner,
          statusMessage: '${resigningPlayer == 'w' ? 'White' : 'Black'} resigned',
        );
        break;
    }
  }

  void _handleTimeFlagged(String color) {
    String winner = color == 'w' ? 'b' : 'w';
    SoundManager().playGameEndSound();
    state = state.copyWith(
      resultStatus: GameResultStatus.timeOut,
      winner: winner,
      statusMessage: '${color == 'w' ? 'White' : 'Black'} ran out of time',
    );
  }

  void offerDraw() {
    if (!_isOfflineAi) {
      final packet = SyncPacket(
        packetId: _p2pService.getNextSequenceId(),
        type: AppConstants.packetTypeDrawOffer,
        hostTimestamp: DateTime.now().millisecondsSinceEpoch,
      );
      _p2pService.sendPacket(packet);
    }
  }

  void respondDrawOffer(bool accept) {
    state = state.copyWith(hasPendingDrawOffer: false);
    if (accept) {
      _clockEngine.stop();
      SoundManager().playGameEndSound();
      state = state.copyWith(
        resultStatus: GameResultStatus.drawAgreed,
        winner: 'draw',
        statusMessage: 'Draw agreed by mutual consent',
      );
    }
    if (!_isOfflineAi) {
      final packet = SyncPacket(
        packetId: _p2pService.getNextSequenceId(),
        type: AppConstants.packetTypeDrawResponse,
        hostTimestamp: DateTime.now().millisecondsSinceEpoch,
        extraData: {'accepted': accept},
      );
      _p2pService.sendPacket(packet);
    }
  }

  void offerRematch() {
    if (!_isOfflineAi) {
      final packet = SyncPacket(
        packetId: _p2pService.getNextSequenceId(),
        type: AppConstants.packetTypeRematchRequest,
        hostTimestamp: DateTime.now().millisecondsSinceEpoch,
        extraData: {'senderName': 'Opponent'},
      );
      _p2pService.sendPacket(packet);
    } else {
      // In offline AI mode, rematch starts immediately
      startNewGame(
        timeControl: _timeControl,
        isHost: _isHost,
        playerColor: state.localPlayerColor == 'w' ? 'b' : 'w',
        isOfflineAi: true,
      );
    }
  }

  void respondRematchOffer(bool accept) {
    state = state.copyWith(hasPendingRematchOffer: false);
    if (!_isOfflineAi) {
      final packet = SyncPacket(
        packetId: _p2pService.getNextSequenceId(),
        type: AppConstants.packetTypeRematchResponse,
        hostTimestamp: DateTime.now().millisecondsSinceEpoch,
        extraData: {'accepted': accept},
      );
      _p2pService.sendPacket(packet);
    }
    if (accept) {
      final newColor = state.localPlayerColor == 'w' ? 'b' : 'w';
      startNewGame(
        timeControl: _timeControl,
        isHost: _isHost,
        playerColor: newColor,
        isOfflineAi: _isOfflineAi,
      );
    }
  }

  void resign() {
    String resigningPlayer = state.localPlayerColor;
    String winner = resigningPlayer == 'w' ? 'b' : 'w';
    _clockEngine.stop();
    SoundManager().playGameEndSound();
    state = state.copyWith(
      resultStatus: GameResultStatus.resignation,
      winner: winner,
      statusMessage: '${resigningPlayer == 'w' ? 'White' : 'Black'} resigned',
    );

    if (!_isOfflineAi) {
      final packet = SyncPacket(
        packetId: _p2pService.getNextSequenceId(),
        type: AppConstants.packetTypeResign,
        hostTimestamp: DateTime.now().millisecondsSinceEpoch,
        extraData: {'playerColor': resigningPlayer},
      );
      _p2pService.sendPacket(packet);
    }
  }

  String getPgn() {
    return _engine.getPgn();
  }

  String _getStatusMessage(GameResultStatus result, String? winner) {
    switch (result) {
      case GameResultStatus.checkmate:
        return 'Checkmate! ${winner == 'w' ? 'White' : 'Black'} wins!';
      case GameResultStatus.stalemate:
        return 'Draw by Stalemate';
      case GameResultStatus.threefoldRepetition:
        return 'Draw by 3-fold Repetition';
      case GameResultStatus.fiftyMoveRule:
        return 'Draw by 50-move Rule';
      case GameResultStatus.insufficientMaterial:
        return 'Draw by Insufficient Material';
      default:
        return 'Game in progress';
    }
  }

  @override
  void dispose() {
    _clockEngine.dispose();
    super.dispose();
  }
}

final gameNotifierProvider =
    StateNotifierProvider<GameNotifier, ChessGameState>((ref) {
  final p2pService = ref.watch(p2pServiceProvider);
  return GameNotifier(p2pService);
});
