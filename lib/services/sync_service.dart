import 'dart:convert';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'platform_database_service.dart';
import 'network_service.dart';

class SyncService {
  final PlatformDatabaseService _localDb = PlatformDatabaseService();
  final SupabaseClient _supabase = Supabase.instance.client;
  final NetworkService _networkService = NetworkService();

  Future<void> syncData() async {
    if (!await _networkService.checkConnection()) {
      print('No internet connection. Sync postponed.');
      return;
    }

    final pendingItems = await _localDb.getPendingSyncItems();
    for (final item in pendingItems) {
      final tableName = item['table_name'];
      final recordId = item['record_id'];
      final operation = item['operation'];
      final data = item['data'] is String ? json.decode(item['data']) : item['data'];

      try {
        switch (operation) {
          case 'insert':
            await _supabase.from(tableName).insert(data);
            break;
          case 'update':
            await _supabase.from(tableName).update(data).eq('id', recordId);
            break;
          case 'delete':
            await _supabase.from(tableName).delete().eq('id', recordId);
            break;
          default:
            print('Unsupported operation: $operation');
            continue;
        }

        await _localDb.removeSyncItem(item['id']);
        await _localDb.updateSyncStatus(tableName, recordId, 'synced');
        print('Synced $tableName with ID: $recordId');

      } catch (error) {
        print('Error syncing $tableName with ID: $recordId. Error: $error');
      }
    }
  }

  Future<void> cacheInitialData() async {
    if (!await _networkService.checkConnection()) return;

    // Example sync operation for user_profiles
    final userProfiles = await _supabase.from('user_profiles').select('*');
    await _localDb.cacheSupabaseData('user_profiles', userProfiles);

    // Add similar sync operations for other tables
  }
}
