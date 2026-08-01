import 'package:chess/chess.dart' as chess_lib;
import '../domain/chess_game_state.dart';

class ChessEngineWrapper {
  chess_lib.Chess _chess = chess_lib.Chess();
  
  final List<String> _sanHistory = [];
  final List<String> _uciHistory = [];
  final List<String> _capturedByWhite = [];
  final List<String> _capturedByBlack = [];

  String get fen => _chess.fen;
  String get turn => _chess.turn == chess_lib.Color.WHITE ? 'w' : 'b';
  bool get inCheck => _chess.in_check;
  bool get inCheckmate => _chess.in_checkmate;
  bool get inStalemate => _chess.in_stalemate;
  bool get inThreefoldRepetition => _chess.in_threefold_repetition;
  bool get insufficientMaterial => _chess.insufficient_material;
  bool get inDraw => _chess.in_draw;
  bool get isGameOver => _chess.game_over;
  List<String> get sanHistory => List.unmodifiable(_sanHistory);
  List<String> get uciHistory => List.unmodifiable(_uciHistory);
  List<String> get capturedByWhite => List.unmodifiable(_capturedByWhite);
  List<String> get capturedByBlack => List.unmodifiable(_capturedByBlack);

  void reset() {
    _chess = chess_lib.Chess();
    _sanHistory.clear();
    _uciHistory.clear();
    _capturedByWhite.clear();
    _capturedByBlack.clear();
  }

  void loadFen(String fen) {
    _chess = chess_lib.Chess.fromFEN(fen);
  }

  String? getPieceColor(String square) {
    try {
      final piece = _chess.get(square);
      if (piece == null) return null;
      return piece.color == chess_lib.Color.WHITE ? 'w' : 'b';
    } catch (_) {
      return null;
    }
  }

  List<String> getLegalMovesForSquare(String square) {
    final moves = _chess.moves({'square': square, 'verbose': true});
    List<String> dests = [];
    for (var m in moves) {
      if (m is Map) {
        dests.add(m['to'].toString());
      } else if (m is chess_lib.Move) {
        dests.add(m.toAlgebraic);
      }
    }
    return dests.toSet().toList();
  }

  bool isPromotionMove(String from, String to) {
    final piece = _chess.get(from);
    if (piece == null || piece.type != chess_lib.PieceType.PAWN) {
      return false;
    }
    if (piece.color == chess_lib.Color.WHITE && to.endsWith('8')) {
      return true;
    }
    if (piece.color == chess_lib.Color.BLACK && to.endsWith('1')) {
      return true;
    }
    return false;
  }

  /// Make move from UCI / square strings. Returns executed Move SAN or null if illegal.
  String? makeMove(String from, String to, {String? promotion}) {
    chess_lib.Piece? capturedPiece;
    try {
      capturedPiece = _chess.get(to);
    } catch (_) {}
    
    final moveResult = _chess.move({
      'from': from,
      'to': to,
      'promotion': ?promotion,
    });

    if (moveResult == false) {
      return null;
    }

    String uci = '$from$to${promotion ?? ''}';
    String san = uci;

    _sanHistory.add(san);
    _uciHistory.add(uci);

    if (capturedPiece != null) {
      String pieceChar = capturedPiece.type.name.toUpperCase();
      if (_chess.turn == chess_lib.Color.BLACK) {
        // White just moved and captured Black piece
        _capturedByWhite.add(pieceChar);
      } else {
        // Black just moved and captured White piece
        _capturedByBlack.add(pieceChar);
      }
    }

    return san;
  }

  GameResultStatus get resultStatus => getResultStatus();

  String? get winnerColor {
    if (inCheckmate) {
      // If white to move and in checkmate, black wins; and vice versa
      return turn == 'w' ? 'b' : 'w';
    }
    return null;
  }

  GameResultStatus getResultStatus() {
    if (inCheckmate) return GameResultStatus.checkmate;
    if (inStalemate) return GameResultStatus.stalemate;
    if (inThreefoldRepetition) return GameResultStatus.threefoldRepetition;
    if (insufficientMaterial) return GameResultStatus.insufficientMaterial;
    if (inDraw) return GameResultStatus.fiftyMoveRule;
    return GameResultStatus.active;
  }

  String getPgn() {
    return _chess.pgn();
  }

  /// Generate a bot move for Play vs AI offline mode
  Map<String, String>? generateBotMove() {
    final legalMoves = _chess.moves({'verbose': true});
    if (legalMoves.isEmpty) return null;

    // Prioritize captures and checks, otherwise select first legal move
    dynamic chosenMove = legalMoves.first;
    for (var m in legalMoves) {
      if (m is Map && (m['captured'] != null || m['san'].toString().contains('+'))) {
        chosenMove = m;
        break;
      }
    }

    String from = chosenMove['from'].toString();
    String to = chosenMove['to'].toString();
    String? promotion = chosenMove['promotion']?.toString();

    return {
      'from': from,
      'to': to,
      'promotion': ?promotion,
    };
  }
}
