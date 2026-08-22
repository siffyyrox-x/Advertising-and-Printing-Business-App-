import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

import '../models/ai_request.dart';
import '../models/quote_request.dart';


class DatabaseHelper {
  DatabaseHelper._internal();

  /// The single shared instance used everywhere in the app.
  static final DatabaseHelper instance = DatabaseHelper._internal();

  static const String _fileName = 'printing_business.db';
  static const int _version = 1;

  static const String tableQuotes = 'quote_requests';
  static const String tableAiRequests = 'ai_requests';

  Database? _database;

  Future<Database> get database async {
    _database ??= await _open();
    return _database!;
  }

  Future<Database> _open() async {
    final String folder = await getDatabasesPath();
    final String path = p.join(folder, _fileName);

    return openDatabase(
      path,
      version: _version,
      onCreate: _createTables,
      onConfigure: (Database db) async {
        // Needed so the ON DELETE rule on ai_requests actually runs.
        await db.execute('PRAGMA foreign_keys = ON');
      },
    );
  }

  Future<void> _createTables(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $tableQuotes (
        quote_id        INTEGER PRIMARY KEY AUTOINCREMENT,
        service_id      INTEGER NOT NULL,
        customer_name   TEXT    NOT NULL,
        phone           TEXT    NOT NULL,
        email           TEXT,
        quantity        TEXT,
        project_details TEXT    NOT NULL,
        status          TEXT    NOT NULL,
        created_at      TEXT    NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE $tableAiRequests (
        ai_request_id   INTEGER PRIMARY KEY AUTOINCREMENT,
        quote_id        INTEGER,
        customer_prompt TEXT    NOT NULL,
        ai_response     TEXT    NOT NULL,
        source          TEXT    NOT NULL,
        created_at      TEXT    NOT NULL,
        FOREIGN KEY (quote_id) REFERENCES $tableQuotes (quote_id)
          ON DELETE SET NULL
      )
    ''');
  }

  // ---------------------------------------------------------------------------
  // QUOTE_REQUEST
  // ---------------------------------------------------------------------------

  /// Saves a quote request and returns the new quote_id.
  Future<int> insertQuote(QuoteRequest quote) async {
    final Database db = await database;
    return db.insert(tableQuotes, quote.toMap());
  }

  /// All saved quotes, newest first.
  Future<List<QuoteRequest>> getQuotes() async {
    final Database db = await database;
    final List<Map<String, Object?>> rows = await db.query(
      tableQuotes,
      orderBy: 'quote_id DESC',
    );
    return rows.map(QuoteRequest.fromMap).toList();
  }

  Future<int> countQuotes() async {
    final Database db = await database;
    final List<Map<String, Object?>> rows =
        await db.rawQuery('SELECT COUNT(*) AS total FROM $tableQuotes');
    return (rows.first['total'] as int?) ?? 0;
  }

  Future<int> updateQuoteStatus(int quoteId, String status) async {
    final Database db = await database;
    return db.update(
      tableQuotes,
      <String, Object?>{'status': status},
      where: 'quote_id = ?',
      whereArgs: <Object?>[quoteId],
    );
  }

  Future<int> deleteQuote(int quoteId) async {
    final Database db = await database;
    return db.delete(
      tableQuotes,
      where: 'quote_id = ?',
      whereArgs: <Object?>[quoteId],
    );
  }

  // ---------------------------------------------------------------------------
  // AI_REQUEST
  // ---------------------------------------------------------------------------

  Future<int> insertAiRequest(AiRequest request) async {
    final Database db = await database;
    return db.insert(tableAiRequests, request.toMap());
  }

  /// The most recent chatbot exchanges, newest first.
  Future<List<AiRequest>> getAiRequests({int limit = 100}) async {
    final Database db = await database;
    final List<Map<String, Object?>> rows = await db.query(
      tableAiRequests,
      orderBy: 'ai_request_id DESC',
      limit: limit,
    );
    return rows.map(AiRequest.fromMap).toList();
  }

  Future<int> clearAiRequests() async {
    final Database db = await database;
    return db.delete(tableAiRequests);
  }

  /// Closes the database. Only used when the app shuts down or in tests.
  Future<void> close() async {
    await _database?.close();
    _database = null;
  }
}
