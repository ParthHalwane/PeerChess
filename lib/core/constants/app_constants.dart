class AppConstants {
  static const String appName = 'Peer Chess';
  static const String serviceId = 'com.peerchess.app.peer_chess';

  // Network Packet Types
  static const String packetTypeOfferGame = 'OFFER_GAME';
  static const String packetTypeAcceptGame = 'ACCEPT_GAME';
  static const String packetTypeMove = 'MOVE';
  static const String packetTypeFullState = 'FULL_STATE';
  static const String packetTypeClockSync = 'CLOCK_SYNC';
  static const String packetTypePing = 'PING';
  static const String packetTypePong = 'PONG';
  static const String packetTypeDrawOffer = 'DRAW_OFFER';
  static const String packetTypeDrawResponse = 'DRAW_RESPONSE';
  static const String packetTypeUndoRequest = 'UNDO_REQUEST';
  static const String packetTypeUndoResponse = 'UNDO_RESPONSE';
  static const String packetTypeResign = 'RESIGN';
  static const String packetTypeRematchRequest = 'REMATCH_REQ';
  static const String packetTypeRematchResponse = 'REMATCH_RESP';
  static const String packetTypePause = 'PAUSE';
  static const String packetTypeResume = 'RESUME';

  // Protocol Version
  static const int protocolVersion = 1;

  // Latency Thresholds
  static const int minLatencyThresholdMs = 20;

  // SQLite Database
  static const String dbName = 'peer_chess.db';
  static const int dbVersion = 1;
  static const String tableHistory = 'game_history';
}

enum BoardThemeOption {
  chessCom,
  wood,
  midnight,
  cyberpunk,
}

extension BoardThemeExtension on BoardThemeOption {
  String get displayName {
    switch (this) {
      case BoardThemeOption.chessCom:
        return 'Chess.com Green';
      case BoardThemeOption.wood:
        return 'Classic Wood';
      case BoardThemeOption.midnight:
        return 'Dark Midnight';
      case BoardThemeOption.cyberpunk:
        return 'Neon Cyberpunk';
    }
  }
}
