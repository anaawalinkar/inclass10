import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'card_organizer.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _createTables,
    );
  }

  Future<void> _createTables(Database db, int version) async {
    // Create folders table
    await db.execute('''
      CREATE TABLE folders(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');

    // Create cards table
    await db.execute('''
      CREATE TABLE cards(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        suit TEXT NOT NULL,
        image_url TEXT,
        folder_id INTEGER,
        created_at TEXT NOT NULL,
        FOREIGN KEY (folder_id) REFERENCES folders (id)
      )
    ''');

    // Prepopulate folders
    await _prepopulateFolders(db);
    // Prepopulate cards
    await _prepopulateCards(db);
  }

  Future<void> _prepopulateFolders(Database db) async {
    final folders = [
      {'name': 'Hearts', 'created_at': DateTime.now().toIso8601String()},
      {'name': 'Spades', 'created_at': DateTime.now().toIso8601String()},
      {'name': 'Diamonds', 'created_at': DateTime.now().toIso8601String()},
      {'name': 'Clubs', 'created_at': DateTime.now().toIso8601String()},
    ];

    for (final folder in folders) {
      await db.insert('folders', folder);
    }
  }

  Future<void> _prepopulateCards(Database db) async {
    final suits = ['Hearts', 'Spades', 'Diamonds', 'Clubs'];
    final cardNames = [
      'Ace', '2', '3', '4', '5', '6', '7', '8', '9', '10', 'Jack', 'Queen', 'King'
    ];

    for (final suit in suits) {
      for (int i = 0; i < cardNames.length; i++) {
        final card = {
          'name': cardNames[i],
          'suit': suit,
          'image_url': 'assets/images/${cardNames[i].toLowerCase()}_of_${suit.toLowerCase()}.png',
          'folder_id': null,
          'created_at': DateTime.now().toIso8601String(),
        };
        await db.insert('cards', card);
      }
    }
  }

  // Folder operations
  Future<List<Map<String, dynamic>>> getFolders() async {
    final db = await database;
    return await db.query('folders');
  }

  Future<int> updateFolder(int id, String name) async {
    final db = await database;
    return await db.update(
      'folders',
      {'name': name},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteFolder(int id) async {
    final db = await database;
    // First, remove folder association from cards
    await db.update(
      'cards',
      {'folder_id': null},
      where: 'folder_id = ?',
      whereArgs: [id],
    );
    // Then delete the folder
    return await db.delete(
      'folders',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Card operations
  Future<List<Map<String, dynamic>>> getCardsByFolder(int? folderId) async {
    final db = await database;
    if (folderId == null) {
      return await db.query('cards', where: 'folder_id IS NULL');
    }
    return await db.query(
      'cards',
      where: 'folder_id = ?',
      whereArgs: [folderId],
    );
  }

  Future<List<Map<String, dynamic>>> getAllCards() async {
    final db = await database;
    return await db.query('cards');
  }

  Future<int> updateCardFolder(int cardId, int? folderId) async {
    final db = await database;
    return await db.update(
      'cards',
      {'folder_id': folderId},
      where: 'id = ?',
      whereArgs: [cardId],
    );
  }

  Future<int> getCardCountInFolder(int folderId) async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM cards WHERE folder_id = ?',
      [folderId],
    );
    return result.first['count'] as int;
  }

  Future<int> deleteCard(int id) async {
    final db = await database;
    return await db.delete(
      'cards',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}