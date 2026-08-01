import 'dart:convert';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/checksum_calculator.dart';

class SyncPacket {
  final int packetId;
  final String type;
  final int version;
  final String? boardFen;
  final String? moveSan;
  final String? moveUci;
  final int moveNumber;
  final int whiteRemainingMs;
  final int blackRemainingMs;
  final String currentTurn; // 'w' or 'b'
  final int incrementMs;
  final int delayMs;
  final int hostTimestamp;
  final String gameStatus;
  final Map<String, dynamic> extraData;
  final String? checksum;

  SyncPacket({
    required this.packetId,
    required this.type,
    this.version = AppConstants.protocolVersion,
    this.boardFen,
    this.moveSan,
    this.moveUci,
    this.moveNumber = 1,
    this.whiteRemainingMs = 300000,
    this.blackRemainingMs = 300000,
    this.currentTurn = 'w',
    this.incrementMs = 0,
    this.delayMs = 0,
    required this.hostTimestamp,
    this.gameStatus = 'active',
    this.extraData = const {},
    this.checksum,
  });

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'packetId': packetId,
      'type': type,
      'version': version,
      'boardFen': boardFen,
      'moveSan': moveSan,
      'moveUci': moveUci,
      'moveNumber': moveNumber,
      'whiteRemainingMs': whiteRemainingMs,
      'blackRemainingMs': blackRemainingMs,
      'currentTurn': currentTurn,
      'incrementMs': incrementMs,
      'delayMs': delayMs,
      'hostTimestamp': hostTimestamp,
      'gameStatus': gameStatus,
      'extraData': extraData,
    };
    map['checksum'] = ChecksumCalculator.calculate(map);
    return map;
  }

  String toJson() => jsonEncode(toMap());

  factory SyncPacket.fromMap(Map<String, dynamic> map) {
    return SyncPacket(
      packetId: map['packetId'] ?? 0,
      type: map['type'] ?? '',
      version: map['version'] ?? AppConstants.protocolVersion,
      boardFen: map['boardFen'],
      moveSan: map['moveSan'],
      moveUci: map['moveUci'],
      moveNumber: map['moveNumber'] ?? 1,
      whiteRemainingMs: map['whiteRemainingMs'] ?? 0,
      blackRemainingMs: map['blackRemainingMs'] ?? 0,
      currentTurn: map['currentTurn'] ?? 'w',
      incrementMs: map['incrementMs'] ?? 0,
      delayMs: map['delayMs'] ?? 0,
      hostTimestamp: map['hostTimestamp'] ?? 0,
      gameStatus: map['gameStatus'] ?? 'active',
      extraData: map['extraData'] != null
          ? Map<String, dynamic>.from(map['extraData'])
          : {},
      checksum: map['checksum'],
    );
  }

  factory SyncPacket.fromJson(String source) =>
      SyncPacket.fromMap(jsonDecode(source));
}
