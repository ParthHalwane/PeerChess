import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/history_provider.dart';
import 'pgn_viewer_screen.dart';

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(historyProvider);
    final notifier = ref.read(historyProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Game History'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep),
            tooltip: 'Clear History',
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (_) => AlertDialog(
                  backgroundColor: const Color(0xFF1E1E24),
                  title: const Text('Clear All History?',
                      style: TextStyle(color: Colors.white)),
                  content: const Text(
                      'Are you sure you want to delete all saved games?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancel'),
                    ),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context, true),
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red),
                      child: const Text('Clear'),
                    ),
                  ],
                ),
              );

              if (confirm == true) {
                await notifier.clearAll();
              }
            },
          ),
        ],
      ),
      body: historyAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: Color(0xFF81B64C)),
        ),
        error: (err, st) => Center(
          child: Text('Failed to load history: $err',
              style: const TextStyle(color: Colors.red)),
        ),
        data: (games) {
          if (games.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(Icons.history, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('No local games played yet',
                      style: TextStyle(fontSize: 16, color: Colors.grey)),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: games.length,
            itemBuilder: (context, index) {
              final game = games[index];
              final isWin = game.winner == 'White';

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor:
                        isWin ? const Color(0xFF81B64C) : Colors.grey.shade700,
                    child: Icon(
                      isWin ? Icons.emoji_events : Icons.remove,
                      color: isWin ? Colors.black : Colors.white,
                    ),
                  ),
                  title: Text(
                    '${game.whitePlayer} vs ${game.blackPlayer}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    'Result: ${game.winner} • Moves: ${game.movesCount} • ${game.timeControl}',
                    style: TextStyle(color: Colors.grey.shade400, fontSize: 12),
                  ),
                  trailing: const Icon(Icons.chevron_right, color: Colors.grey),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => PgnViewerScreen(game: game),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
