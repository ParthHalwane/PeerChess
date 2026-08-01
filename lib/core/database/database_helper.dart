import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../constants/app_constants.dart';
import '../../features/chess_game/domain/game_history_item.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;
  final List<GameHistoryItem> _memoryFallback = [];

  DatabaseHelper._init();

  Future<Database?> get database async {
    if (kIsWeb) return null; // Web platform fallback
    try {
      if (_database != null) return _database!;
      _database = await _initDB(AppConstants.dbName);
      return _database!;
    } catch (e) {
      debugPrint('Database connection failed: $e');
      return null;
    }
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: AppConstants.dbVersion,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE ${AppConstants.tableHistory} (
        id TEXT PRIMARY KEY,
        whitePlayer TEXT NOT NULL,
        blackPlayer TEXT NOT NULL,
        pgn TEXT NOT NULL,
        finalFen TEXT NOT NULL,
        winner TEXT NOT NULL,
        timeControl TEXT NOT NULL,
        movesCount INTEGER NOT NULL,
        durationSeconds INTEGER NOT NULL,
        dateIso TEXT NOT NULL
      )
    ''');
  }

  Future<int> insertGameHistory(GameHistoryItem game) async {
    try {
      final db = await instance.database;
      if (db != null) {
        return await db.insert(
          AppConstants.tableHistory,
          game.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    } catch (e) {
      debugPrint('SQLite insert failed, fallback to memory: $e');
    }
    _memoryFallback.insert(0, game);
    return 1;
  }

  Future<List<GameHistoryItem>> getAllGamesHistory() async {
    try {
      final db = await instance.database;
      if (db != null) {
        final result = await db.query(
          AppConstants.tableHistory,
          orderBy: 'dateIso DESC',
        );
        return result.map((json) => GameHistoryItem.fromMap(json)).toList();
      }
    } catch (e) {
      debugPrint('SQLite query failed, fallback to memory: $e');
    }
    return List.from(_memoryFallback);
  }

  Future<int> deleteGameHistory(String id) async {
    try {
      final db = await instance.database;
      if (db != null) {
        return await db.delete(
          AppConstants.tableHistory,
          where: 'id = ?',
          whereArgs: [id],
        );
      }
    } catch (e) {
      debugPrint('SQLite delete failed: $e');
    }
    _memoryFallback.removeWhere((item) => item.id == id);
    return 1;
  }

  Future<void> clearAllHistory() async {
    try {
      final db = await instance.database;
      if (db != null) {
        await db.delete(AppConstants.tableHistory);
      }
    } catch (e) {
      debugPrint('SQLite clear failed: $e');
    }
    _memoryFallback.clear();
  }
}
