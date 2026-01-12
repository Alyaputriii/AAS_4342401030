import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/sleep_record.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('sleep_tracker.db');
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
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textType = 'TEXT NOT NULL';

    await db.execute('''
      CREATE TABLE sleep_records (
        id $idType,
        bedTime $textType,
        wakeTime $textType,
        quality $textType,
        notes TEXT
      )
    ''');
  }

  // Tambah record tidur
  Future<SleepRecord> create(SleepRecord record) async {
    final db = await instance.database;
    final id = await db.insert('sleep_records', record.toMap());
    return record.copyWith(id: id);
  }

  // Ambil semua record
  Future<List<SleepRecord>> readAllRecords() async {
    final db = await instance.database;
    const orderBy = 'bedTime DESC';
    final result = await db.query('sleep_records', orderBy: orderBy);
    
    return result.map((json) => SleepRecord.fromMap(json)).toList();
  }

  // Ambil record berdasarkan ID
  Future<SleepRecord?> readRecord(int id) async {
    final db = await instance.database;
    final maps = await db.query(
      'sleep_records',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return SleepRecord.fromMap(maps.first);
    } else {
      return null;
    }
  }

  // Update record
  Future<int> update(SleepRecord record) async {
    final db = await instance.database;
    return db.update(
      'sleep_records',
      record.toMap(),
      where: 'id = ?',
      whereArgs: [record.id],
    );
  }

  // Hapus record
  Future<int> delete(int id) async {
    final db = await instance.database;
    return await db.delete(
      'sleep_records',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Tutup database
  Future close() async {
    final db = await instance.database;
    db.close();
  }
}

// Extension untuk copy with
extension SleepRecordCopy on SleepRecord {
  SleepRecord copyWith({
    int? id,
    DateTime? bedTime,
    DateTime? wakeTime,
    String? quality,
    String? notes,
  }) {
    return SleepRecord(
      id: id ?? this.id,
      bedTime: bedTime ?? this.bedTime,
      wakeTime: wakeTime ?? this.wakeTime,
      quality: quality ?? this.quality,
      notes: notes ?? this.notes,
    );
  }
}