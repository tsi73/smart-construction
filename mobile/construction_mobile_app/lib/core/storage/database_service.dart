import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DatabaseService {
  static Database? _database;

  Future<Database> get database async {
    if (kIsWeb) {
      throw UnsupportedError(
          'SQLite is not supported on Web. Use limited offline behavior.');
    }
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'constructpro.db');

    return await openDatabase(
      path,
      version: 6,
      onCreate: _createDB,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Add user_id column to projects_cache
      await db.execute('ALTER TABLE projects_cache ADD COLUMN user_id TEXT');
      // Clear existing cache since we can't determine the user_id
      await db.delete('projects_cache');
    }
    if (oldVersion < 3) {
      // Rename budget_total to total_budget
      // SQLite doesn't support ALTER TABLE RENAME COLUMN directly, so we need to recreate the table
      await db.execute('''
        CREATE TABLE projects_cache_new (
          id TEXT PRIMARY KEY,
          name TEXT NOT NULL,
          description TEXT,
          client_name TEXT,
          location TEXT,
          total_budget REAL,
          budget_spent REAL,
          progress_percentage REAL,
          status TEXT,
          role TEXT,
          user_id TEXT NOT NULL,
          cached_at TEXT NOT NULL
        )
      ''');
      
      // Copy data from old table to new table (mapping budget_total to total_budget)
      await db.execute('''
        INSERT INTO projects_cache_new (
          id, name, description, client_name, location, total_budget,
          budget_spent, progress_percentage, status, role, user_id, cached_at
        )
        SELECT 
          id, name, description, client_name, location, budget_total,
          budget_spent, progress_percentage, status, role, user_id, cached_at
        FROM projects_cache
      ''');
      
      // Drop old table
      await db.execute('DROP TABLE projects_cache');

      // Rename new table to original name
      await db.execute('ALTER TABLE projects_cache_new RENAME TO projects_cache');
    }
    if (oldVersion < 4) {
      // Add planned_start_date and planned_end_date columns
      await db.execute('ALTER TABLE projects_cache ADD COLUMN planned_start_date TEXT');
      await db.execute('ALTER TABLE projects_cache ADD COLUMN planned_end_date TEXT');
      // Clear cache to ensure fresh data with new columns
      await db.delete('projects_cache');
    }
    if (oldVersion < 5) {
      // Add missing columns to projects_cache
      await db.execute('ALTER TABLE projects_cache ADD COLUMN owner_id TEXT');
      await db.execute('ALTER TABLE projects_cache ADD COLUMN client_email TEXT');
      await db.execute('ALTER TABLE projects_cache ADD COLUMN created_at TEXT');
      await db.execute('ALTER TABLE projects_cache ADD COLUMN updated_at TEXT');
      
      // Add missing columns to tasks_cache
      await db.execute('ALTER TABLE tasks_cache ADD COLUMN description TEXT');
      await db.execute('ALTER TABLE tasks_cache ADD COLUMN planned_duration_days INTEGER');
      await db.execute('ALTER TABLE tasks_cache ADD COLUMN actual_cost REAL');
      await db.execute('ALTER TABLE tasks_cache ADD COLUMN planned_cost REAL');
      await db.execute('ALTER TABLE tasks_cache ADD COLUMN dependencies_json TEXT');
      await db.execute('ALTER TABLE tasks_cache ADD COLUMN created_at TEXT');
      await db.execute('ALTER TABLE tasks_cache ADD COLUMN updated_at TEXT');
      
      // Clear caches to ensure fresh data with new columns
      await db.delete('projects_cache');
      await db.delete('tasks_cache');
    }
    if (oldVersion < 6) {
      // Add client_id field that backend might return
      await db.execute('ALTER TABLE projects_cache ADD COLUMN client_id TEXT');
      // Clear cache to handle the new field properly
      await db.delete('projects_cache');
    }
  }

  Future<void> _createDB(Database db, int version) async {
    // Sync Queue Table
    await db.execute('''
      CREATE TABLE sync_queue (
        local_id INTEGER PRIMARY KEY AUTOINCREMENT,
        server_id TEXT,
        entity_type TEXT NOT NULL,
        operation_type TEXT NOT NULL,
        project_id TEXT,
        task_id TEXT,
        payload_json TEXT NOT NULL,
        status TEXT NOT NULL,
        attempt_count INTEGER DEFAULT 0,
        last_attempt_at TEXT,
        last_error TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    // Daily Log Drafts table (Legacy/Direct)
    await db.execute('''
      CREATE TABLE daily_log_drafts (
        local_id INTEGER PRIMARY KEY AUTOINCREMENT,
        server_id TEXT,
        project_id TEXT NOT NULL,
        task_id TEXT,
        date TEXT NOT NULL,
        weather TEXT,
        notes TEXT NOT NULL,
        status TEXT NOT NULL,
        labor_json TEXT,
        materials_json TEXT,
        equipment_json TEXT,
        shifts_json TEXT,
        sync_status TEXT NOT NULL,
        last_error TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    // Tasks Cache table
    await db.execute('''
      CREATE TABLE tasks_cache (
        id TEXT PRIMARY KEY,
        project_id TEXT NOT NULL,
        name TEXT NOT NULL,
        description TEXT,
        status TEXT NOT NULL,
        progress_percentage REAL NOT NULL,
        start_date TEXT,
        end_date TEXT,
        assigned_to TEXT,
        planned_duration_days INTEGER,
        actual_cost REAL,
        planned_cost REAL,
        dependencies_json TEXT,
        created_at TEXT,
        updated_at TEXT,
        cached_at TEXT NOT NULL
      )
    ''');

    // Projects Cache table
    await db.execute('''
      CREATE TABLE projects_cache (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        description TEXT,
        client_name TEXT,
        client_email TEXT,
        client_id TEXT,
        location TEXT,
        total_budget REAL,
        budget_spent REAL,
        progress_percentage REAL,
        status TEXT,
        role TEXT,
        owner_id TEXT,
        user_id TEXT NOT NULL,
        cached_at TEXT NOT NULL,
        planned_start_date TEXT,
        planned_end_date TEXT,
        created_at TEXT,
        updated_at TEXT
      )
    ''');
  }

  Future<void> close() async {
    final db = await database;
    db.close();
  }
}

final databaseServiceProvider = Provider<DatabaseService>((ref) {
  return DatabaseService();
});
