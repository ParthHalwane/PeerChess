enum GameResultStatus {
  active,
  checkmate,
  stalemate,
  threefoldRepetition,
  fiftyMoveRule,
  insufficientMaterial,
  timeOut,
  resignation,
  drawAgreed,
}

class ChessGameState {
  final String fen;
  final List<String> sanMoves;
  final List<String> uciMoves;
  final List<String> capturedByWhite; // Black pieces captured
  final List<String> capturedByBlack; // White pieces captured
  final String turn; // 'w' or 'b'
  final bool inCheck;
  final GameResultStatus resultStatus;
  final String? winner; // 'w', 'b', or 'draw'
  final String? selectedSquare; // e.g. 'e2'
  final List<String> legalDestinationSquares;
  final String? lastMoveFrom;
  final String? lastMoveTo;
  final String localPlayerColor; // 'w' or 'b' or 'spectator'
  final bool hasPendingDrawOffer;
  final bool hasPendingUndoRequest;
  final bool hasPendingRematchOffer;
  final String? rematchOfferPlayerName;
  final String statusMessage;

  const ChessGameState({
    this.fen = 'rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1',
    this.sanMoves = const [],
    this.uciMoves = const [],
    this.capturedByWhite = const [],
    this.capturedByBlack = const [],
    this.turn = 'w',
    this.inCheck = false,
    this.resultStatus = GameResultStatus.active,
    this.winner,
    this.selectedSquare,
    this.legalDestinationSquares = const [],
    this.lastMoveFrom,
    this.lastMoveTo,
    this.localPlayerColor = 'w',
    this.hasPendingDrawOffer = false,
    this.hasPendingUndoRequest = false,
    this.hasPendingRematchOffer = false,
    this.rematchOfferPlayerName,
    this.statusMessage = 'Game in progress',
  });

  ChessGameState copyWith({
    String? fen,
    List<String>? sanMoves,
    List<String>? uciMoves,
    List<String>? capturedByWhite,
    List<String>? capturedByBlack,
    String? turn,
    bool? inCheck,
    GameResultStatus? resultStatus,
    String? winner,
    String? selectedSquare,
    List<String>? legalDestinationSquares,
    String? lastMoveFrom,
    String? lastMoveTo,
    String? localPlayerColor,
    bool? hasPendingDrawOffer,
    bool? hasPendingUndoRequest,
    bool? hasPendingRematchOffer,
    String? rematchOfferPlayerName,
    String? statusMessage,
  }) {
    return ChessGameState(
      fen: fen ?? this.fen,
      sanMoves: sanMoves ?? this.sanMoves,
      uciMoves: uciMoves ?? this.uciMoves,
      capturedByWhite: capturedByWhite ?? this.capturedByWhite,
      capturedByBlack: capturedByBlack ?? this.capturedByBlack,
      turn: turn ?? this.turn,
      inCheck: inCheck ?? this.inCheck,
      resultStatus: resultStatus ?? this.resultStatus,
      winner: winner ?? this.winner,
      selectedSquare: selectedSquare ?? this.selectedSquare,
      legalDestinationSquares: legalDestinationSquares ?? this.legalDestinationSquares,
      lastMoveFrom: lastMoveFrom ?? this.lastMoveFrom,
      lastMoveTo: lastMoveTo ?? this.lastMoveTo,
      localPlayerColor: localPlayerColor ?? this.localPlayerColor,
      hasPendingDrawOffer: hasPendingDrawOffer ?? this.hasPendingDrawOffer,
      hasPendingUndoRequest: hasPendingUndoRequest ?? this.hasPendingUndoRequest,
      hasPendingRematchOffer: hasPendingRematchOffer ?? this.hasPendingRematchOffer,
      rematchOfferPlayerName: rematchOfferPlayerName ?? this.rematchOfferPlayerName,
      statusMessage: statusMessage ?? this.statusMessage,
    );
  }
}
