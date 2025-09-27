// lib/db/session_db.dart
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/session.dart';

class SessionDB {
  static final SessionDB instance = SessionDB._init();
  static Database? _database;

  SessionDB._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('sessions.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE sessions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        startTime TEXT NOT NULL,
        endTime TEXT NOT NULL,
        completed INTEGER NOT NULL
      )
    ''');
  }

  Future<int> insertSession(Session session) async {
    final db = await instance.database;
    return await db.insert('sessions', session.toMap());
  }

  Future<List<Session>> fetchSessions() async {
    final db = await instance.database;
    final maps = await db.query('sessions', orderBy: 'startTime DESC');
    return maps.map((m) => Session.fromMap(m)).toList();
  }

  Future close() async {
    final db = await instance.database;
    await db.close();
    _database = null;
  }
}