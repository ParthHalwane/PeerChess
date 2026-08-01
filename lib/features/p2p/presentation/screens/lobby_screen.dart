import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../clock/domain/time_control.dart';
import '../../domain/p2p_connection_state.dart';
import '../providers/p2p_provider.dart';
import '../../../chess_game/presentation/providers/game_notifier.dart';
import '../../../chess_game/presentation/screens/game_screen.dart';

class LobbyScreen extends ConsumerStatefulWidget {
  final bool isHost;

  const LobbyScreen({super.key, required this.isHost});

  @override
  ConsumerState<LobbyScreen> createState() => _LobbyScreenState();
}

class _LobbyScreenState extends ConsumerState<LobbyScreen> {
  TimeControl _selectedTimeControl = TimeControl.blitz5m;
  final TextEditingController _nameController = TextEditingController(
    text: 'Chess Player',
  );

  @override
  void initState() {
    super.initState();
    _requestPermissionsAndStart();
  }

  Future<void> _requestPermissionsAndStart() async {
    if (Platform.isAndroid) {
      Map<Permission, PermissionStatus> statuses = await [
        Permission.location,
        Permission.locationWhenInUse,
        Permission.bluetoothScan,
        Permission.bluetoothAdvertise,
        Permission.bluetoothConnect,
        Permission.nearbyWifiDevices,
      ].request();

      debugPrint('Permissions status: $statuses');

      final wifiDenied =
          statuses[Permission.nearbyWifiDevices]?.isDenied ?? false;
      final wifiPermanentlyDenied =
          statuses[Permission.nearbyWifiDevices]?.isPermanentlyDenied ?? false;
      final locationDenied = statuses[Permission.location]?.isDenied ?? false;

      if ((wifiDenied || wifiPermanentlyDenied || locationDenied) && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              'Nearby Devices & Location permissions are required to discover peers.',
            ),
            action: SnackBarAction(
              label: 'Settings',
              onPressed: () => openAppSettings(),
            ),
            duration: const Duration(seconds: 8),
          ),
        );
      }
    }

    final p2pNotifier = ref.read(p2pStateProvider.notifier);
    p2pNotifier.setPlayerName(_nameController.text.trim());

    if (widget.isHost) {
      await p2pNotifier.startHostLobby();
    } else {
      await p2pNotifier.startJoinLobby();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _navigateToGame(String playerColor) {
    final gameNotifier = ref.read(gameNotifierProvider.notifier);
    gameNotifier.startNewGame(
      timeControl: _selectedTimeControl,
      isHost: widget.isHost,
      playerColor: playerColor,
    );

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) =>
            GameScreen(playerColor: playerColor, isHost: widget.isHost),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final p2pStatus = ref.watch(p2pStateProvider);
    final p2pNotifier = ref.watch(p2pStateProvider.notifier);

    // Auto navigate when connected
    ref.listen<P2pConnectionStatus>(p2pStateProvider, (prev, next) {
      if (prev?.state != P2pState.connected &&
          next.state == P2pState.connected) {
        String playerColor = widget.isHost ? 'w' : 'b';
        _navigateToGame(playerColor);
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isHost ? 'Host Game Lobby' : 'Join Nearby Game'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Player Name Input
              TextField(
                controller: _nameController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Your Display Name',
                  prefixIcon: const Icon(Icons.person),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onChanged: (val) {
                  p2pNotifier.setPlayerName(val);
                },
              ),

              const SizedBox(height: 24),

              if (widget.isHost) ...[
                const Text(
                  'Time Control Presets',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 60,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: TimeControl.defaultPresets.length,
                    separatorBuilder: (_, _) => const SizedBox(width: 10),
                    itemBuilder: (context, idx) {
                      final tc = TimeControl.defaultPresets[idx];
                      final isSelected = tc.name == _selectedTimeControl.name;
                      return ChoiceChip(
                        label: Text(tc.name),
                        selected: isSelected,
                        selectedColor: const Color(0xFF81B64C),
                        onSelected: (selected) {
                          if (selected) {
                            setState(() {
                              _selectedTimeControl = tc;
                            });
                          }
                        },
                      );
                    },
                  ),
                ),
                const SizedBox(height: 24),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const CircularProgressIndicator(
                              color: Color(0xFF81B64C),
                            ),
                            const SizedBox(width: 20),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: const [
                                  Text(
                                    'Broadcasting via Nearby Connections...',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    'Tell your opponent to open "Join Game"',
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        if (p2pStatus.errorMessage != null) ...[
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.amber.shade900.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.amber.shade700, width: 1),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.info_outline, color: Colors.amber.shade400, size: 18),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    _formatUserFriendlyError(p2pStatus.errorMessage!),
                                    style: TextStyle(
                                      color: Colors.amber.shade200,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            icon: const Icon(Icons.refresh, size: 18),
                            label: const Text('Restart Broadcasting'),
                            onPressed: () {
                              _requestPermissionsAndStart();
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ] else ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Discovered Host Players',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.refresh, color: Color(0xFF81B64C)),
                      tooltip: 'Refresh Search',
                      onPressed: () {
                        _requestPermissionsAndStart();
                      },
                    ),
                  ],
                ),
                if (p2pStatus.errorMessage != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    p2pStatus.errorMessage!,
                    style: const TextStyle(
                      color: Colors.redAccent,
                      fontSize: 13,
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                Expanded(
                  child: p2pStatus.discoveredPeers.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const CircularProgressIndicator(
                                color: Color(0xFF81B64C),
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'Searching for nearby hosts (Bluetooth/Wi-Fi)...',
                                style: TextStyle(color: Colors.grey),
                              ),
                              const SizedBox(height: 16),
                              OutlinedButton.icon(
                                icon: const Icon(Icons.refresh, size: 18),
                                label: const Text('Restart Search'),
                                onPressed: () {
                                  _requestPermissionsAndStart();
                                },
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          itemCount: p2pStatus.discoveredPeers.length,
                          itemBuilder: (context, index) {
                            final peer = p2pStatus.discoveredPeers[index];
                            final isConnecting =
                                p2pStatus.state == P2pState.connecting &&
                                p2pStatus.connectedPeerId == peer.id;

                            return Card(
                              margin: const EdgeInsets.only(bottom: 10),
                              child: ListTile(
                                leading: const Icon(
                                  Icons.phonelink,
                                  color: Color(0xFF81B64C),
                                ),
                                title: Text(
                                  peer.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                subtitle: Text(
                                  'ID: ${peer.id.length > 4 ? peer.id.substring(0, 4) : peer.id}...',
                                ),
                                trailing: isConnecting
                                    ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Color(0xFF81B64C),
                                        ),
                                      )
                                    : ElevatedButton(
                                        onPressed: () =>
                                            p2pNotifier.connectToPeer(peer),
                                        child: const Text('Join'),
                                      ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _formatUserFriendlyError(String rawError) {
    if (rawError.contains('Advertising error') || rawError.contains('Broadcast failed')) {
      return 'Broadcast paused. Please ensure Bluetooth and Location (GPS) are turned ON.';
    } else if (rawError.contains('Discovery error') || rawError.contains('Discovery failed')) {
      return 'Search paused. Please ensure Bluetooth and Location (GPS) are turned ON.';
    } else if (rawError.contains('rejected') || rawError.contains('failed')) {
      return 'Connection request could not complete. Tap Refresh to try again.';
    }
    return 'Connection status notice: Please tap Refresh to restart search.';
  }
}
