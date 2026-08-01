class GameHistoryItem {
  final String id;
  final String whitePlayer;
  final String blackPlayer;
  final String pgn;
  final String finalFen;
  final String winner; // 'White', 'Black', 'Draw'
  final String timeControl;
  final int movesCount;
  final int durationSeconds;
  final String dateIso;

  const GameHistoryItem({
    required this.id,
    required this.whitePlayer,
    required this.blackPlayer,
    required this.pgn,
    required this.finalFen,
    required this.winner,
    required this.timeControl,
    required this.movesCount,
    required this.durationSeconds,
    required this.dateIso,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'whitePlayer': whitePlayer,
      'blackPlayer': blackPlayer,
      'pgn': pgn,
      'finalFen': finalFen,
      'winner': winner,
      'timeControl': timeControl,
      'movesCount': movesCount,
      'durationSeconds': durationSeconds,
      'dateIso': dateIso,
    };
  }

  factory GameHistoryItem.fromMap(Map<String, dynamic> map) {
    return GameHistoryItem(
      id: map['id'] ?? '',
      whitePlayer: map['whitePlayer'] ?? 'White',
      blackPlayer: map['blackPlayer'] ?? 'Black',
      pgn: map['pgn'] ?? '',
      finalFen: map['finalFen'] ?? '',
      winner: map['winner'] ?? 'Draw',
      timeControl: map['timeControl'] ?? 'Standard',
      movesCount: map['movesCount'] ?? 0,
      durationSeconds: map['durationSeconds'] ?? 0,
      dateIso: map['dateIso'] ?? DateTime.now().toIso8601String(),
    );
  }
}
