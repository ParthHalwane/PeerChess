import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/nearby_p2p_service.dart';
import '../../domain/p2p_connection_state.dart';
import '../../domain/peer_device.dart';

class P2pStateNotifier extends StateNotifier<P2pConnectionStatus> {
  final NearbyP2pService _service;
  List<PeerDevice> discoveredPeers = [];

  P2pStateNotifier(this._service) : super(const P2pConnectionStatus()) {
    _service.onStatusChanged = (status) {
      state = status;
    };
    _service.onDiscoveredPeers = (peers) {
      discoveredPeers = peers;
    };
  }

  NearbyP2pService get service => _service;

  void setPlayerName(String name) {
    _service.setUserName(name);
  }

  Future<bool> startHostLobby() async {
    return await _service.startAdvertising();
  }

  Future<bool> startJoinLobby() async {
    return await _service.startDiscovery();
  }

  Future<bool> connectToPeer(PeerDevice peer) async {
    return await _service.requestConnection(peer);
  }

  Future<void> disconnect() async {
    await _service.disconnect();
  }
}

final p2pServiceProvider = Provider<NearbyP2pService>((ref) {
  final service = NearbyP2pService();
  ref.onDispose(() {
    service.disconnect();
  });
  return service;
});

final p2pStateProvider =
    StateNotifierProvider<P2pStateNotifier, P2pConnectionStatus>((ref) {
  final service = ref.watch(p2pServiceProvider);
  return P2pStateNotifier(service);
});
