import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Platform-aware storage service that works on both web and mobile
class PlatformDatabaseService {
  static final PlatformDatabaseService _instance = PlatformDatabaseService._internal();
  factory PlatformDatabaseService() => _instance;
  PlatformDatabaseService._internal();

  SharedPreferences? _prefs;

  Future<void> initialize() async {
    if (kIsWeb) {
      _prefs = await SharedPreferences.getInstance();
    }
    // For mobile platforms, we would use SQLite, but for now we'll use SharedPreferences for simplicity
    _prefs ??= await SharedPreferences.getInstance();
  }

  // Generic data storage methods
  Future<void> saveData(String key, Map<String, dynamic> data) async {
    await _ensureInitialized();
    await _prefs!.setString(key, json.encode(data));
  }

  Future<Map<String, dynamic>?> getData(String key) async {
    await _ensureInitialized();
    final String? dataString = _prefs!.getString(key);
    if (dataString != null) {
      return json.decode(dataString);
    }
    return null;
  }

  Future<void> saveList(String key, List<Map<String, dynamic>> data) async {
    await _ensureInitialized();
    await _prefs!.setString(key, json.encode(data));
  }

  Future<List<Map<String, dynamic>>> getList(String key) async {
    await _ensureInitialized();
    final String? dataString = _prefs!.getString(key);
    if (dataString != null) {
      final List<dynamic> decoded = json.decode(dataString);
      return decoded.cast<Map<String, dynamic>>();
    }
    return [];
  }

  Future<void> removeData(String key) async {
    await _ensureInitialized();
    await _prefs!.remove(key);
  }

  Future<void> clear() async {
    await _ensureInitialized();
    await _prefs!.clear();
  }

  // Water Data Operations
  Future<void> insertWaterData(Map<String, dynamic> data) async {
    final List<Map<String, dynamic>> waterDataList = await getList('water_data');
    waterDataList.add(data);
    await saveList('water_data', waterDataList);
  }

  Future<List<Map<String, dynamic>>> getWaterData({int? limit}) async {
    final List<Map<String, dynamic>> waterDataList = await getList('water_data');
    if (limit != null && waterDataList.length > limit) {
      return waterDataList.take(limit).toList();
    }
    return waterDataList;
  }

  Future<List<Map<String, dynamic>>> getPendingWaterData() async {
    final List<Map<String, dynamic>> waterDataList = await getList('water_data');
    return waterDataList.where((item) => item['sync_status'] == 'pending').toList();
  }

  // Issue Reports Operations
  Future<void> insertIssueReport(Map<String, dynamic> data) async {
    final List<Map<String, dynamic>> issuesList = await getList('issue_reports');
    issuesList.add(data);
    await saveList('issue_reports', issuesList);
  }

  Future<List<Map<String, dynamic>>> getIssueReports({int? limit}) async {
    final List<Map<String, dynamic>> issuesList = await getList('issue_reports');
    if (limit != null && issuesList.length > limit) {
      return issuesList.take(limit).toList();
    }
    return issuesList;
  }

  Future<List<Map<String, dynamic>>> getPendingIssueReports() async {
    final List<Map<String, dynamic>> issuesList = await getList('issue_reports');
    return issuesList.where((item) => item['sync_status'] == 'pending').toList();
  }

  // Discussions Operations
  Future<void> insertDiscussion(Map<String, dynamic> data) async {
    final List<Map<String, dynamic>> discussionsList = await getList('discussions');
    discussionsList.add(data);
    await saveList('discussions', discussionsList);
  }

  Future<List<Map<String, dynamic>>> getDiscussions({int? limit}) async {
    final List<Map<String, dynamic>> discussionsList = await getList('discussions');
    if (limit != null && discussionsList.length > limit) {
      return discussionsList.take(limit).toList();
    }
    return discussionsList;
  }

  // Sync Queue Operations
  Future<void> addToSyncQueue(String tableName, String recordId, String operation, Map<String, dynamic> data) async {
    final List<Map<String, dynamic>> syncQueue = await getList('sync_queue');
    syncQueue.add({
      'id': DateTime.now().millisecondsSinceEpoch,
      'table_name': tableName,
      'record_id': recordId,
      'operation': operation,
      'data': data,
      'created_at': DateTime.now().toIso8601String(),
      'retry_count': 0,
    });
    await saveList('sync_queue', syncQueue);
  }

  Future<List<Map<String, dynamic>>> getPendingSyncItems() async {
    return await getList('sync_queue');
  }

  Future<void> removeSyncItem(int syncId) async {
    final List<Map<String, dynamic>> syncQueue = await getList('sync_queue');
    syncQueue.removeWhere((item) => item['id'] == syncId);
    await saveList('sync_queue', syncQueue);
  }

  Future<void> updateSyncStatus(String tableName, String recordId, String status) async {
    // Update the specific record's sync status
    if (tableName == 'water_data') {
      final List<Map<String, dynamic>> dataList = await getList('water_data');
      for (int i = 0; i < dataList.length; i++) {
        if (dataList[i]['id'] == recordId) {
          dataList[i]['sync_status'] = status;
          break;
        }
      }
      await saveList('water_data', dataList);
    } else if (tableName == 'issue_reports') {
      final List<Map<String, dynamic>> dataList = await getList('issue_reports');
      for (int i = 0; i < dataList.length; i++) {
        if (dataList[i]['id'] == recordId) {
          dataList[i]['sync_status'] = status;
          break;
        }
      }
      await saveList('issue_reports', dataList);
    }
    // Add more table types as needed
  }

  // Cache Supabase data locally
  Future<void> cacheSupabaseData(String tableName, List<Map<String, dynamic>> data) async {
    for (final item in data) {
      item['sync_status'] = 'synced';
    }
    await saveList(tableName, data);
  }

  Future<void> _ensureInitialized() async {
    if (_prefs == null) {
      await initialize();
    }
  }
}
