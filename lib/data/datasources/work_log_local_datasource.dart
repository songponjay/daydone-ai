import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/work_log_model.dart';

class WorkLogLocalDatasource {
  static Database? _db;

  Future<Database> get db async {
    _db ??= await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    final path = join(await getDatabasesPath(), 'work_log.db');
    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE work_logs (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            date TEXT NOT NULL,
            content TEXT NOT NULL,
            tags TEXT NOT NULL
          )
        ''');
      },
    );
  }

  Future<List<WorkLogModel>> getAll() async {
    final database = await db;
    final maps = await database.query('work_logs', orderBy: 'date DESC');
    return maps.map((m) => WorkLogModel.fromMap(m)).toList();
  }

  Future<void> save(WorkLogModel model) async {
    final database = await db;
    await database.insert('work_logs', model.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> delete(int id) async {
    final database = await db;
    await database.delete('work_logs', where: 'id = ?', whereArgs: [id]);
  }
}