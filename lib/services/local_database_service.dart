import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalDatabaseService {
  static final LocalDatabaseService _instance = LocalDatabaseService._internal();
  factory LocalDatabaseService() => _instance;
  LocalDatabaseService._internal();

  static Database? _database;
  
  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'aqua_horizon_offline.db');
    
    return await openDatabase(
      path,
      version: 1,
      onCreate: (Database db, int version) async {
        await _createTables(db);
      },
    );
  }

  Future<void> _createTables(Database db) async {
    // Create tables that mirror your Supabase schema
    
    // User profiles table
    await db.execute('''
      CREATE TABLE user_profiles (
        id TEXT PRIMARY KEY,
        username TEXT NOT NULL,
        email TEXT NOT NULL,
        full_name TEXT NOT NULL,
        role TEXT DEFAULT 'community_user',
        location_coordinates TEXT,
        profile_photo_url TEXT,
        created_at TEXT,
        updated_at TEXT,
        sync_status TEXT DEFAULT 'synced'
      )
    ''');

    // Water data table
    await db.execute('''
      CREATE TABLE water_data (
        id TEXT PRIMARY KEY,
        user_id TEXT,
        location_coordinates TEXT NOT NULL,
        location_name TEXT,
        ph_level REAL,
        turbidity REAL,
        temperature REAL,
        dissolved_oxygen REAL,
        water_level REAL,
        flow_rate REAL,
        photos TEXT,
        notes TEXT,
        verification_status TEXT DEFAULT 'pending',
        created_at TEXT,
        updated_at TEXT,
        sync_status TEXT DEFAULT 'pending'
      )
    ''');

    // Issue reports table
    await db.execute('''
      CREATE TABLE issue_reports (
        id TEXT PRIMARY KEY,
        reporter_id TEXT,
        title TEXT NOT NULL,
        description TEXT NOT NULL,
        category TEXT NOT NULL,
        location_coordinates TEXT NOT NULL,
        location_name TEXT,
        status TEXT DEFAULT 'reported',
        photos TEXT,
        priority INTEGER DEFAULT 1,
        assigned_to TEXT,
        created_at TEXT,
        updated_at TEXT,
        resolved_at TEXT,
        sync_status TEXT DEFAULT 'pending'
      )
    ''');

    // Discussions table
    await db.execute('''
      CREATE TABLE discussions (
        id TEXT PRIMARY KEY,
        author_id TEXT,
        title TEXT NOT NULL,
        content TEXT NOT NULL,
        issue_id TEXT,
        parent_id TEXT,
        is_pinned INTEGER DEFAULT 0,
        created_at TEXT,
        updated_at TEXT,
        sync_status TEXT DEFAULT 'pending'
      )
    ''');

    // Water analytics table
    await db.execute('''
      CREATE TABLE water_analytics (
        id TEXT PRIMARY KEY,
        location_coordinates TEXT NOT NULL,
        date_recorded TEXT NOT NULL,
        avg_ph REAL,
        avg_turbidity REAL,
        avg_temperature REAL,
        avg_dissolved_oxygen REAL,
        sample_count INTEGER DEFAULT 1,
        quality_status TEXT,
        created_at TEXT,
        sync_status TEXT DEFAULT 'synced'
      )
    ''');

    // Sync queue table for tracking pending operations
    await db.execute('''
      CREATE TABLE sync_queue (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        table_name TEXT NOT NULL,
        record_id TEXT NOT NULL,
        operation TEXT NOT NULL,
        data TEXT NOT NULL,
        created_at TEXT,
        retry_count INTEGER DEFAULT 0
      )
    ''');
  }

  // Water Data Operations
  Future<String> insertWaterData(Map<String, dynamic> data) async {
    final db = await database;
    data['sync_status'] = 'pending';
    data['photos'] = json.encode(data['photos'] ?? []);
    
    await db.insert('water_data', data, conflictAlgorithm: ConflictAlgorithm.replace);
    
    // Add to sync queue
    await _addToSyncQueue('water_data', data['id'], 'insert', data);
    
    return data['id'];
  }

  Future<List<Map<String, dynamic>>> getWaterData({int? limit}) async {
    final db = await database;
    final List<Map<String, dynamic>> results = await db.query(
      'water_data',
      orderBy: 'created_at DESC',
      limit: limit,
    );
    
    // Parse photos JSON
    return results.map((item) {
      item['photos'] = json.decode(item['photos'] ?? '[]');
      return item;
    }).toList();
  }

  Future<List<Map<String, dynamic>>> getPendingWaterData() async {
    final db = await database;
    final List<Map<String, dynamic>> results = await db.query(
      'water_data',
      where: 'sync_status = ?',
      whereArgs: ['pending'],
    );
    
    return results.map((item) {
      item['photos'] = json.decode(item['photos'] ?? '[]');
      return item;
    }).toList();
  }

  // Issue Reports Operations
  Future<String> insertIssueReport(Map<String, dynamic> data) async {
    final db = await database;
    data['sync_status'] = 'pending';
    data['photos'] = json.encode(data['photos'] ?? []);
    
    await db.insert('issue_reports', data, conflictAlgorithm: ConflictAlgorithm.replace);
    
    // Add to sync queue
    await _addToSyncQueue('issue_reports', data['id'], 'insert', data);
    
    return data['id'];
  }

  Future<List<Map<String, dynamic>>> getIssueReports({int? limit}) async {
    final db = await database;
    final List<Map<String, dynamic>> results = await db.query(
      'issue_reports',
      orderBy: 'created_at DESC',
      limit: limit,
    );
    
    return results.map((item) {
      item['photos'] = json.decode(item['photos'] ?? '[]');
      return item;
    }).toList();
  }

  Future<List<Map<String, dynamic>>> getPendingIssueReports() async {
    final db = await database;
    final List<Map<String, dynamic>> results = await db.query(
      'issue_reports',
      where: 'sync_status = ?',
      whereArgs: ['pending'],
    );
    
    return results.map((item) {
      item['photos'] = json.decode(item['photos'] ?? '[]');
      return item;
    }).toList();
  }

  // Discussions Operations
  Future<String> insertDiscussion(Map<String, dynamic> data) async {
    final db = await database;
    data['sync_status'] = 'pending';
    
    await db.insert('discussions', data, conflictAlgorithm: ConflictAlgorithm.replace);
    
    // Add to sync queue
    await _addToSyncQueue('discussions', data['id'], 'insert', data);
    
    return data['id'];
  }

  Future<List<Map<String, dynamic>>> getDiscussions({int? limit}) async {
    final db = await database;
    return await db.query(
      'discussions',
      orderBy: 'created_at DESC',
      limit: limit,
    );
  }

  // Sync Queue Operations
  Future<void> _addToSyncQueue(String tableName, String recordId, String operation, Map<String, dynamic> data) async {
    final db = await database;
    await db.insert('sync_queue', {
      'table_name': tableName,
      'record_id': recordId,
      'operation': operation,
      'data': json.encode(data),
      'created_at': DateTime.now().toIso8601String(),
      'retry_count': 0,
    });
  }

  Future<List<Map<String, dynamic>>> getPendingSyncItems() async {
    final db = await database;
    return await db.query('sync_queue', orderBy: 'created_at ASC');
  }

  Future<void> removeSyncItem(int syncId) async {
    final db = await database;
    await db.delete('sync_queue', where: 'id = ?', whereArgs: [syncId]);
  }

  Future<void> updateSyncStatus(String tableName, String recordId, String status) async {
    final db = await database;
    await db.update(
      tableName,
      {'sync_status': status},
      where: 'id = ?',
      whereArgs: [recordId],
    );
  }

  // Cache Supabase data locally
  Future<void> cacheSupabaseData(String tableName, List<Map<String, dynamic>> data) async {
    final db = await database;
    
    for (final item in data) {
      item['sync_status'] = 'synced';
      if (item['photos'] != null && item['photos'] is List) {
        item['photos'] = json.encode(item['photos']);
      }
      
      await db.insert(tableName, item, conflictAlgorithm: ConflictAlgorithm.replace);
    }
  }

  // Clear all data (for testing purposes)
  Future<void> clearAllData() async {
    final db = await database;
    await db.delete('user_profiles');
    await db.delete('water_data');
    await db.delete('issue_reports');
    await db.delete('discussions');
    await db.delete('water_analytics');
    await db.delete('sync_queue');
  }
}
