import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:nearby_connections/nearby_connections.dart';
import '../../../core/constants/app_constants.dart';
import '../domain/p2p_connection_state.dart';
import '../domain/peer_device.dart';
import '../domain/sync_packet.dart';

typedef OnPacketReceivedCallback = void Function(SyncPacket packet);
typedef OnDiscoveredPeersCallback = void Function(List<PeerDevice> peers);
typedef OnConnectionStatusCallback = void Function(P2pConnectionStatus status);

class NearbyP2pService {
  final Strategy strategy = Strategy.P2P_STAR;

  P2pConnectionStatus _status = const P2pConnectionStatus();
  final List<PeerDevice> _discoveredPeers = [];

  OnPacketReceivedCallback? onPacketReceived;
  OnDiscoveredPeersCallback? onDiscoveredPeers;
  OnConnectionStatusCallback? onStatusChanged;

  int _sequenceId = 0;
  String _userName = 'Player';

  P2pConnectionStatus get status => _status;
  List<PeerDevice> get discoveredPeers => List.unmodifiable(_discoveredPeers);

  void setUserName(String name) {
    _userName = name;
  }

  void _updateStatus(P2pConnectionStatus newStatus) {
    _status = newStatus;
    onStatusChanged?.call(_status);
  }

  Future<bool> startAdvertising() async {
    try {
      await Nearby().stopAllEndpoints();
      await Nearby().stopAdvertising();
      await Nearby().stopDiscovery();

      _discoveredPeers.clear();
      onDiscoveredPeers?.call(_discoveredPeers);

      _updateStatus(
        _status.copyWith(
          state: P2pState.advertising,
          isHost: true,
          errorMessage: null,
        ),
      );

      debugPrint('====================================================');
      debugPrint('📡 [BROADCAST ACTIVE] Host "$_userName" is broadcasting!');
      debugPrint('   Service ID: ${AppConstants.serviceId}');
      debugPrint('   Waiting for joiner to open "Join Game"...');
      debugPrint('====================================================');

      final success = await Nearby().startAdvertising(
        _userName,
        strategy,
        onConnectionInitiated: _onConnectionInitiated,
        onConnectionResult: _onConnectionResult,
        onDisconnected: _onDisconnected,
        serviceId: AppConstants.serviceId,
      );
      
      if (success) {
        debugPrint('✅ [BROADCAST CONFIRMED] Native Android Nearby Service is LIVE!');
      } else {
        debugPrint('⚠️ [BROADCAST WARNING] Native Android service returned false.');
        _updateStatus(
          _status.copyWith(
            state: P2pState.idle,
            errorMessage:
                'Broadcast failed to start. Ensure GPS Location & Bluetooth are ON.',
          ),
        );
      }
      return success;
    } catch (e) {
      debugPrint('❌ [BROADCAST ERROR] $e');
      _updateStatus(
        _status.copyWith(
          state: P2pState.idle,
          errorMessage: 'Advertising error: $e',
        ),
      );
      return false;
    }
  }

  Future<bool> startDiscovery() async {
    try {
      await Nearby().stopAllEndpoints();
      await Nearby().stopAdvertising();
      await Nearby().stopDiscovery();

      _discoveredPeers.clear();
      onDiscoveredPeers?.call(_discoveredPeers);

      _updateStatus(
        _status.copyWith(
          state: P2pState.searching,
          isHost: false,
          errorMessage: null,
        ),
      );

      debugPrint('====================================================');
      debugPrint('🔍 [SEARCH ACTIVE] Device "$_userName" is scanning for hosts...');
      debugPrint('   Service ID: ${AppConstants.serviceId}');
      debugPrint('====================================================');

      final success = await Nearby().startDiscovery(
        _userName,
        strategy,
        onEndpointFound: (String id, String name, String serviceId) {
          debugPrint('----------------------------------------------------');
          debugPrint('🎯 [HOST IDENTIFIED!] Found host: "$name" (ID: $id)');
          debugPrint('   Appearing in "Discovered Host Players" list!');
          debugPrint('----------------------------------------------------');
          final device = PeerDevice(id: id, name: name);
          if (!_discoveredPeers.contains(device)) {
            _discoveredPeers.add(device);
            onDiscoveredPeers?.call(_discoveredPeers);
            _updateStatus(_status.copyWith(discoveredPeers: List.from(_discoveredPeers)));
          }
        },
        onEndpointLost: (String? id) {
          debugPrint('ℹ️ [SIGNAL FLICKER] Endpoint $id signal flickered (retaining card on screen).');
        },
        serviceId: AppConstants.serviceId,
      );
      
      if (success) {
        debugPrint('✅ [SEARCH CONFIRMED] Native Android Scanner is LIVE!');
      } else {
        debugPrint('⚠️ [SEARCH WARNING] Native Android scanner returned false.');
        _updateStatus(
          _status.copyWith(
            state: P2pState.idle,
            errorMessage:
                'Discovery failed to start. Ensure GPS Location & Bluetooth are ON.',
          ),
        );
      }
      return success;
    } catch (e) {
      debugPrint('❌ [SEARCH ERROR] $e');
      _updateStatus(
        _status.copyWith(
          state: P2pState.idle,
          errorMessage: 'Discovery error: $e',
        ),
      );
      return false;
    }
  }

  Future<bool> requestConnection(PeerDevice peer) async {
    try {
      _updateStatus(
        _status.copyWith(
          state: P2pState.connecting,
          connectedPeerId: peer.id,
          connectedPeerName: peer.name,
        ),
      );

      debugPrint('🤝 [PAIRING REQUESTED] Sending request to host: "${peer.name}" (ID: ${peer.id})');

      return await Nearby().requestConnection(
        _userName,
        peer.id,
        onConnectionInitiated: _onConnectionInitiated,
        onConnectionResult: _onConnectionResult,
        onDisconnected: _onDisconnected,
      );
    } catch (e) {
      debugPrint('❌ [PAIRING ERROR] $e');
      _updateStatus(
        _status.copyWith(
          state: P2pState.idle,
          errorMessage: 'Request connection failed: $e',
        ),
      );
      return false;
    }
  }

  void _onConnectionInitiated(String id, ConnectionInfo info) {
    debugPrint('🔔 [PAIRING INITIATED] Connection request from "${info.endpointName}" (ID: $id). Accepting...');
    Nearby().acceptConnection(
      id,
      onPayLoadRecieved: (String endpointId, Payload payload) {
        if (payload.type == PayloadType.BYTES && payload.bytes != null) {
          try {
            String jsonStr = utf8.decode(payload.bytes!);
            SyncPacket packet = SyncPacket.fromJson(jsonStr);
            onPacketReceived?.call(packet);
          } catch (e) {
            debugPrint('⚠️ [PACKET PARSE ERROR] $e');
          }
        }
      },
    );
  }

  void _onConnectionResult(String id, Status status) {
    if (status == Status.CONNECTED) {
      debugPrint('====================================================');
      debugPrint('🎉 [CONNECTED SUCCESS!] Paired with endpoint: $id');
      debugPrint('   Stopping discovery/advertising. Launching Chess Game!');
      debugPrint('====================================================');

      Nearby().stopAdvertising();
      Nearby().stopDiscovery();

      _updateStatus(
        _status.copyWith(
          state: P2pState.connected,
          connectedPeerId: id,
          errorMessage: null,
        ),
      );
    } else {
      debugPrint('❌ [CONNECTION FAILED] Status: $status for endpoint $id');
      _updateStatus(
        _status.copyWith(
          state: P2pState.idle,
          connectedPeerId: null,
          errorMessage: 'Connection rejected or failed',
        ),
      );
    }
  }

  void _onDisconnected(String id) {
    debugPrint('Disconnected from endpoint: $id');
    _updateStatus(
      _status.copyWith(
        state: P2pState.reconnecting,
        errorMessage: 'Connection lost. Attempting to reconnect...',
      ),
    );

    // Attempt automatic reconnect
    _attemptAutoReconnect(id);
  }

  Future<void> _attemptAutoReconnect(String endpointId) async {
    await Future.delayed(const Duration(seconds: 2));
    if (_status.state != P2pState.reconnecting) return;

    if (_status.isHost) {
      startAdvertising();
    } else {
      startDiscovery();
    }
  }

  Future<void> sendPacket(SyncPacket packet) async {
    if (_status.state != P2pState.connected ||
        _status.connectedPeerId == null) {
      return;
    }

    try {
      String jsonStr = packet.toJson();
      Uint8List bytes = Uint8List.fromList(utf8.encode(jsonStr));
      await Nearby().sendBytesPayload(_status.connectedPeerId!, bytes);
    } catch (e) {
      debugPrint('Failed to send bytes payload: $e');
    }
  }

  int getNextSequenceId() {
    _sequenceId++;
    return _sequenceId;
  }

  Future<void> disconnect() async {
    try {
      await Nearby().stopAdvertising();
      await Nearby().stopDiscovery();
      await Nearby().stopAllEndpoints();
    } catch (e) {
      debugPrint('Error disconnecting Nearby Connections: $e');
    } finally {
      _updateStatus(const P2pConnectionStatus(state: P2pState.disconnected));
    }
  }
}
