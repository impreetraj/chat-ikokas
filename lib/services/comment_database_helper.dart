import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/comment_model.dart';

class CommentDatabaseHelper {
  static final CommentDatabaseHelper instance = CommentDatabaseHelper._init();
  static Database? _database;

  CommentDatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('comments.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    const idType = 'TEXT PRIMARY KEY';
    const textType = 'TEXT NOT NULL';

    await db.execute('''
CREATE TABLE comments (
  id $idType,
  postId $textType,
  authorName $textType,
  content $textType,
  timestamp $textType,
  reaction TEXT,
  likeCount INTEGER DEFAULT 0
  )
''');
  }

  Future<int> updateReaction(String id, String reaction, int likeCount) async {
    final db = await instance.database;
    return await db.update(
      'comments',
      {'reaction': reaction, 'likeCount': likeCount},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<CommentModel> create(CommentModel comment) async {
    final db = await instance.database;
    await db.insert('comments', comment.toMap());
    return comment;
  }

  Future<List<CommentModel>> readCommentsForPost(String postId) async {
    final db = await instance.database;
    const orderBy = 'timestamp ASC';
    final result = await db.query(
      'comments',
      where: 'postId = ?',
      whereArgs: [postId],
      orderBy: orderBy,
    );
    return result.map((json) => CommentModel.fromMap(json)).toList();
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
