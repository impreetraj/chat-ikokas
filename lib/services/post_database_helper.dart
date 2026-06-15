import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/post_model.dart';

class PostDatabaseHelper {
  static final PostDatabaseHelper instance = PostDatabaseHelper._init();
  static Database? _database;

  PostDatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('posts.db');
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
CREATE TABLE posts (
  id $idType,
  imagePath $textType,
  caption $textType,
  timestamp $textType,
  reaction TEXT,
  likeCount INTEGER DEFAULT 0
  )
''');
  }

  Future<PostModel> create(PostModel post) async {
    final db = await instance.database;
    await db.insert('posts', post.toMap());
    return post;
  }


  Future<List<PostModel>> readAllPosts() async {
    final db = await instance.database;
    const orderBy = 'timestamp DESC';
    final result = await db.query('posts', orderBy: orderBy);
    return result.map((json) => PostModel.fromMap(json)).toList();
  }

  Future<int> delete(String id) async {
    final db = await instance.database;
    return await db.delete(
      'posts',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> updateReaction(String id, String reaction, int likeCount) async {
    final db = await instance.database;
    return await db.update(
      'posts',
      {'reaction': reaction, 'likeCount': likeCount},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
