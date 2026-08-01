import 'peer_device.dart';

enum P2pState {
  idle,
  advertising,
  searching,
  connecting,
  connected,
  reconnecting,
  disconnected,
}

class P2pConnectionStatus {
  final P2pState state;
  final String? connectedPeerId;
  final String? connectedPeerName;
  final bool isHost;
  final int latencyMs;
  final String? errorMessage;
  final List<PeerDevice> discoveredPeers;

  const P2pConnectionStatus({
    this.state = P2pState.idle,
    this.connectedPeerId,
    this.connectedPeerName,
    this.isHost = false,
    this.latencyMs = 0,
    this.errorMessage,
    this.discoveredPeers = const [],
  });

  P2pConnectionStatus copyWith({
    P2pState? state,
    String? connectedPeerId,
    String? connectedPeerName,
    bool? isHost,
    int? latencyMs,
    String? errorMessage,
    List<PeerDevice>? discoveredPeers,
  }) {
    return P2pConnectionStatus(
      state: state ?? this.state,
      connectedPeerId: connectedPeerId ?? this.connectedPeerId,
      connectedPeerName: connectedPeerName ?? this.connectedPeerName,
      isHost: isHost ?? this.isHost,
      latencyMs: latencyMs ?? this.latencyMs,
      errorMessage: errorMessage ?? this.errorMessage,
      discoveredPeers: discoveredPeers ?? this.discoveredPeers,
    );
  }
}
