import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static Database? _database;
  static const String _dbName = 'colis_manager.db';
  static const int _dbVersion = 4;

  static Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  static Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = '$dbPath/$_dbName';

    return await openDatabase(
      path,
      version: _dbVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
      onConfigure: _onConfigure,
    );
  }

  static Future<void> _onConfigure(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON');
  }

  static Future<void> _onCreate(Database db, int version) async {
    await _createTables(db);
  }

  static Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await _migrateToV2(db);
    }
    if (oldVersion < 3) {
      await _migrateToV3(db);
    }
    if (oldVersion < 4) {
      await _migrateToV4(db);
    }
  }

  static Future<void> _createTables(Database db) async {
    await db.execute('''
      CREATE TABLE transitaires (
        id TEXT PRIMARY KEY,
        nom TEXT NOT NULL,
        logo_path TEXT,
        created_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE transport_modes (
        id TEXT PRIMARY KEY,
        transitaire_id TEXT NOT NULL,
        type TEXT NOT NULL,
        description TEXT,
        unite TEXT NOT NULL DEFAULT 'kg',
        FOREIGN KEY (transitaire_id) REFERENCES transitaires(id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE colis (
        id TEXT PRIMARY KEY,
        transport_mode_id TEXT NOT NULL,
        tracking_number TEXT NOT NULL,
        poids REAL NOT NULL,
        unite TEXT NOT NULL,
        prix_fret REAL NOT NULL,
        statut TEXT NOT NULL DEFAULT 'non_livre',
        image_path TEXT,
        date_ajout TEXT NOT NULL,
        date_arrivee TEXT,
        nombre INTEGER,
        FOREIGN KEY (transport_mode_id) REFERENCES transport_modes(id) ON DELETE CASCADE
      )
    ''');
  }

  static Future<void> _migrateToV2(Database db) async {
  }

  static Future<void> _migrateToV3(Database db) async {
    await _addColumnIfNotExists(db, 'colis', 'date_arrivee', 'TEXT');
    await db.execute("UPDATE colis SET statut = 'en_transit' WHERE statut IN ('non_livre', 'en_attente', 'arrive')");
  }

  static Future<void> _migrateToV4(Database db) async {
    await _addColumnIfNotExists(db, 'colis', 'nombre', 'INTEGER');
  }

  static Future<void> _addColumnIfNotExists(Database db, String table, String column, String type) async {
    final columns = await db.rawQuery("PRAGMA table_info('$table')");
    final exists = columns.any((row) => row['name'] == column);
    if (!exists) {
      await db.execute('ALTER TABLE $table ADD COLUMN $column $type');
    }
  }

  static Future<void> close() async {
    final db = _database;
    if (db != null) {
      await db.close();
      _database = null;
    }
  }
}
