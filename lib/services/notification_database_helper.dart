import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/notification_model.dart';

class NotificationDatabaseHelper {
  static final NotificationDatabaseHelper instance = NotificationDatabaseHelper._init();
  static Database? _database;

  NotificationDatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('notifications.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textType = 'TEXT NOT NULL';

    await db.execute('''
CREATE TABLE notifications (
  id $idType,
  message $textType,
  timestamp $textType
  )
''');
  }

  Future<NotificationModel> createNotification(NotificationModel notification) async {
    final db = await instance.database;
    final id = await db.insert('notifications', notification.toMap());
    return NotificationModel(
      id: id,
      message: notification.message,
      timestamp: notification.timestamp,
    );
  }

  Future<List<NotificationModel>> readAllNotifications() async {
    final db = await instance.database;
    const orderBy = 'timestamp DESC';
    final result = await db.query('notifications', orderBy: orderBy);
    return result.map((json) => NotificationModel.fromMap(json)).toList();
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
