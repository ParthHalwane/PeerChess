import 'package:flutter_test/flutter_test.dart';
import 'package:peer_chess/features/chess_game/domain/chess_game_state.dart';
import 'package:peer_chess/features/chess_game/engine/chess_engine_wrapper.dart';

void main() {
  group('ChessEngineWrapper Tests', () {
    late ChessEngineWrapper engine;

    setUp(() {
      engine = ChessEngineWrapper();
    });

    test('Initializes with standard starting FEN', () {
      expect(engine.turn, equals('w'));
      expect(engine.inCheck, isFalse);
      expect(engine.isGameOver, isFalse);
      expect(engine.sanHistory, isEmpty);
    });

    test('Validates e2-e4 legal move', () {
      final legalMoves = engine.getLegalMovesForSquare('e2');
      expect(legalMoves, contains('e4'));
      expect(legalMoves, contains('e3'));

      final san = engine.makeMove('e2', 'e4');
      expect(san, equals('e2e4'));
      expect(engine.turn, equals('b'));
      expect(engine.sanHistory.length, equals(1));
    });

    test('Detects Scholar\'s Mate checkmate sequence', () {
      engine.makeMove('e2', 'e4');
      engine.makeMove('e7', 'e5');
      engine.makeMove('f1', 'c4');
      engine.makeMove('b8', 'c6');
      engine.makeMove('d1', 'h5');
      engine.makeMove('g8', 'f6'); // Knight to f6
      final lastSan = engine.makeMove('h5', 'f7');

      expect(lastSan, equals('h5f7'));
      expect(engine.inCheckmate, isTrue);
      expect(engine.isGameOver, isTrue);
      expect(engine.getResultStatus(), equals(GameResultStatus.checkmate));
    });
  });
}
