import 'package:flutter_test/flutter_test.dart';
import 'package:peer_chess/core/constants/app_constants.dart';
import 'package:peer_chess/core/utils/checksum_calculator.dart';
import 'package:peer_chess/features/p2p/domain/sync_packet.dart';

void main() {
  group('SyncPacket Tests', () {
    test('Serializes to JSON and deserializes back faithfully', () {
      final originalPacket = SyncPacket(
        packetId: 42,
        type: AppConstants.packetTypeMove,
        boardFen: 'rnbqkbnr/pppp1ppp/8/4p3/4P3/8/PPPP1PPP/RNBQKBNR w KQkq e6 0 2',
        moveSan: 'e5',
        moveUci: 'e7e5',
        moveNumber: 2,
        whiteRemainingMs: 295000,
        blackRemainingMs: 298000,
        currentTurn: 'w',
        hostTimestamp: 1700000000000,
      );

      final jsonStr = originalPacket.toJson();
      final parsedPacket = SyncPacket.fromJson(jsonStr);

      expect(parsedPacket.packetId, equals(42));
      expect(parsedPacket.type, equals(AppConstants.packetTypeMove));
      expect(parsedPacket.moveSan, equals('e5'));
      expect(parsedPacket.whiteRemainingMs, equals(295000));
      expect(parsedPacket.blackRemainingMs, equals(298000));
      expect(parsedPacket.currentTurn, equals('w'));
    });

    test('Checksum verification works', () {
      final packetMap = {
        'packetId': 1,
        'type': AppConstants.packetTypeMove,
        'version': 1,
        'hostTimestamp': 123456,
      };

      final checksum = ChecksumCalculator.calculate(packetMap);
      packetMap['checksum'] = checksum;

      expect(ChecksumCalculator.verify(packetMap), isTrue);

      // Tamper with packet
      packetMap['type'] = AppConstants.packetTypeResign;
      expect(ChecksumCalculator.verify(packetMap), isFalse);
    });
  });
}
