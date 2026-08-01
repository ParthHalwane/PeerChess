import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/database/database_helper.dart';
import '../../../chess_game/domain/game_history_item.dart';

class HistoryNotifier extends StateNotifier<AsyncValue<List<GameHistoryItem>>> {
  HistoryNotifier() : super(const AsyncValue.loading()) {
    loadHistory();
  }

  Future<void> loadHistory() async {
    try {
      state = const AsyncValue.loading();
      final games = await DatabaseHelper.instance.getAllGamesHistory();
      state = AsyncValue.data(games);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> saveGame(GameHistoryItem game) async {
    await DatabaseHelper.instance.insertGameHistory(game);
    await loadHistory();
  }

  Future<void> deleteGame(String id) async {
    await DatabaseHelper.instance.deleteGameHistory(id);
    await loadHistory();
  }

  Future<void> clearAll() async {
    await DatabaseHelper.instance.clearAllHistory();
    await loadHistory();
  }
}

final historyProvider =
    StateNotifierProvider<HistoryNotifier, AsyncValue<List<GameHistoryItem>>>((ref) {
  return HistoryNotifier();
});
