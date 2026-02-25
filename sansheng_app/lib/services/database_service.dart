import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/daily_record.dart';

class DatabaseService {
  static final DatabaseService instance = DatabaseService._init();
  static Database? _database;

  DatabaseService._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('sansheng.db');
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

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE daily_records (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        date TEXT NOT NULL,
        reminderIndex INTEGER NOT NULL,
        time TEXT NOT NULL,
        status TEXT NOT NULL,
        note TEXT
      )
    ''');
  }

  // 插入记录
  Future<int> insertRecord(DailyRecord record) async {
    final db = await database;
    return await db.insert('daily_records', record.toMap());
  }

  // 获取某天的所有记录
  Future<List<DailyRecord>> getRecordsByDate(String date) async {
    final db = await database;
    final result = await db.query(
      'daily_records',
      where: 'date = ?',
      whereArgs: [date],
      orderBy: 'id DESC', // 按ID降序，最新的在前
    );
    return result.map((map) => DailyRecord.fromMap(map)).toList();
  }

  // 获取某天某次提醒的记录
  Future<DailyRecord?> getRecord(String date, int reminderIndex) async {
    final db = await database;
    final result = await db.query(
      'daily_records',
      where: 'date = ? AND reminderIndex = ?',
      whereArgs: [date, reminderIndex],
      limit: 1,
    );

    if (result.isEmpty) return null;
    return DailyRecord.fromMap(result.first);
  }

  // 获取所有日期（用于日历标记）
  Future<List<String>> getAllRecordedDates() async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT DISTINCT date FROM daily_records ORDER BY date DESC',
    );
    return result.map((map) => map['date'] as String).toList();
  }

  // 获取日期范围内的记录
  Future<List<DailyRecord>> getRecordsInRange(DateTime start, DateTime end) async {
    final db = await database;
    final startDate = _formatDate(start);
    final endDate = _formatDate(end);

    final result = await db.query(
      'daily_records',
      where: 'date BETWEEN ? AND ?',
      whereArgs: [startDate, endDate],
      orderBy: 'date DESC, reminderIndex ASC',
    );
    return result.map((map) => DailyRecord.fromMap(map)).toList();
  }

  // 删除某天的所有记录
  Future<int> deleteRecordsByDate(String date) async {
    final db = await database;
    return await db.delete(
      'daily_records',
      where: 'date = ?',
      whereArgs: [date],
    );
  }

  // 关闭数据库
  Future<void> close() async {
    final db = await database;
    await db.close();
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
