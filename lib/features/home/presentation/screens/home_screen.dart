import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../clock/domain/time_control.dart';
import '../../../chess_game/presentation/providers/game_notifier.dart';
import '../../../chess_game/presentation/screens/game_screen.dart';
import '../../../history/presentation/screens/history_screen.dart';
import '../../../p2p/presentation/screens/lobby_screen.dart';
import '../../../settings/presentation/screens/settings_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  void _startOfflineAiGame(BuildContext context, WidgetRef ref) {
    final gameNotifier = ref.read(gameNotifierProvider.notifier);
    gameNotifier.startNewGame(
      timeControl: TimeControl.blitz5m,
      isHost: true,
      playerColor: 'w',
      isOfflineAi: true,
    );

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const GameScreen(
          playerColor: 'w',
          isHost: true,
          isOfflineAi: true,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
          child: Column(
            children: [
              const SizedBox(height: 20),
              // App Logo / Title Banner
              const Icon(
                Icons.grid_on,
                size: 80,
                color: Color(0xFF81B64C),
              ),
              const SizedBox(height: 16),
              const Text(
                'PEER CHESS',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2.0,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Offline P2P Android Chess',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey.shade400,
                  letterSpacing: 0.5,
                ),
              ),

              const Spacer(),

              // Action Buttons
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const LobbyScreen(isHost: true),
                        ),
                      );
                    },
                    icon: const Icon(Icons.wifi_tethering, size: 24),
                    label: const Text('Host Game'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      backgroundColor: const Color(0xFF81B64C),
                      foregroundColor: Colors.black,
                    ),
                  ),

                  const SizedBox(height: 16),

                  OutlinedButton.icon(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const LobbyScreen(isHost: false),
                        ),
                      );
                    },
                    icon: const Icon(Icons.search, size: 24),
                    label: const Text('Join Game'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 18),
                    ),
                  ),

                  const SizedBox(height: 16),

                  OutlinedButton.icon(
                    onPressed: () => _startOfflineAiGame(context, ref),
                    icon: const Icon(Icons.smart_toy_outlined, size: 24),
                    label: const Text('Play vs AI (Offline)'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      foregroundColor: Colors.grey.shade300,
                      side: BorderSide(color: Colors.grey.shade700),
                    ),
                  ),
                ],
              ),

              const Spacer(),

              // Bottom Settings & History Bar
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton.filledTonal(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const HistoryScreen()),
                      );
                    },
                    icon: const Icon(Icons.history),
                    tooltip: 'Game History',
                  ),
                  IconButton.filledTonal(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const SettingsScreen()),
                      );
                    },
                    icon: const Icon(Icons.settings),
                    tooltip: 'Settings',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
