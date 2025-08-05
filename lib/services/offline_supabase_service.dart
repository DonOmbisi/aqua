import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import 'platform_database_service.dart';
import 'network_service.dart';
import 'sync_service.dart';

class OfflineSupabaseService {
  static final OfflineSupabaseService _instance = OfflineSupabaseService._internal();
  factory OfflineSupabaseService() => _instance;
  OfflineSupabaseService._internal();

  final PlatformDatabaseService _localDb = PlatformDatabaseService();
  final NetworkService _networkService = NetworkService();
  final SyncService _syncService = SyncService();
  SupabaseClient get _supabase => Supabase.instance.client;
  final Uuid _uuid = const Uuid();

  Future<void> initialize() async {
    try {
      // Initialize platform database service first
      await _localDb.initialize();
      
      await _networkService.initialize();
      
      // Listen to network changes and sync when online
      _networkService.connectionChange.listen((isOnline) {
        if (isOnline) {
          _syncService.syncData().catchError((e) {
            print('Sync error: $e');
          });
        }
      });
      
      // Skip initial sync to avoid database errors for now
      // if (_networkService.isOnline) {
      //   await _syncService.cacheInitialData();
      // }
    } catch (e) {
      print('Error during offline service initialization: $e');
      rethrow;
    }
  }

  // Auth methods (unchanged, still need internet)
  User? get currentUser => _supabase.auth.currentUser;
  bool get isAuthenticated => _supabase.auth.currentUser != null;
  Stream<AuthState> get authStateChanges => _supabase.auth.onAuthStateChange;

  // Water Data Methods
  Future<String> insertWaterData({
    required String locationCoordinates,
    String? locationName,
    double? phLevel,
    double? turbidity,
    double? temperature,
    double? dissolvedOxygen,
    double? waterLevel,
    double? flowRate,
    List<String>? photos,
    String? notes,
  }) async {
    final String id = _uuid.v4();
    final String userId = currentUser?.id ?? '';
    final DateTime now = DateTime.now();

    final Map<String, dynamic> data = {
      'id': id,
      'user_id': userId,
      'location_coordinates': locationCoordinates,
      'location_name': locationName,
      'ph_level': phLevel,
      'turbidity': turbidity,
      'temperature': temperature,
      'dissolved_oxygen': dissolvedOxygen,
      'water_level': waterLevel,
      'flow_rate': flowRate,
      'photos': photos ?? [],
      'notes': notes,
      'verification_status': 'pending',
      'created_at': now.toIso8601String(),
      'updated_at': now.toIso8601String(),
    };

    // Always save to local database first
    await _localDb.insertWaterData(data);

    // Try to sync immediately if online
    if (_networkService.isOnline) {
      try {
        await _supabase.from('water_data').insert(data);
        await _localDb.updateSyncStatus('water_data', id, 'synced');
      } catch (e) {
        print('Failed to sync water data immediately: $e');
        // Data is already in local db with pending status
      }
    }

    return id;
  }

  Future<List<Map<String, dynamic>>> getWaterData({int? limit}) async {
    // Always get from local database first
    List<Map<String, dynamic>> localData = await _localDb.getWaterData(limit: limit);

    // If online, try to get fresh data and cache it
    if (_networkService.isOnline && localData.isEmpty) {
      try {
        final response = await _supabase
            .from('water_data')
            .select('*')
            .order('created_at', ascending: false)
            .limit(limit ?? 100);
        
        if (response.isNotEmpty) {
          await _localDb.cacheSupabaseData('water_data', response);
          return response;
        }
      } catch (e) {
        print('Failed to fetch fresh water data: $e');
      }
    }

    return localData;
  }

  // Issue Report Methods
  Future<String> insertIssueReport({
    required String title,
    required String description,
    required String category,
    required String locationCoordinates,
    String? locationName,
    int priority = 1,
    List<String>? photos,
  }) async {
    final String id = _uuid.v4();
    final String reporterId = currentUser?.id ?? '';
    final DateTime now = DateTime.now();

    final Map<String, dynamic> data = {
      'id': id,
      'reporter_id': reporterId,
      'title': title,
      'description': description,
      'category': category,
      'location_coordinates': locationCoordinates,
      'location_name': locationName,
      'status': 'reported',
      'photos': photos ?? [],
      'priority': priority,
      'created_at': now.toIso8601String(),
      'updated_at': now.toIso8601String(),
    };

    // Always save to local database first
    await _localDb.insertIssueReport(data);

    // Try to sync immediately if online
    if (_networkService.isOnline) {
      try {
        await _supabase.from('issue_reports').insert(data);
        await _localDb.updateSyncStatus('issue_reports', id, 'synced');
      } catch (e) {
        print('Failed to sync issue report immediately: $e');
      }
    }

    return id;
  }

  Future<List<Map<String, dynamic>>> getIssueReports({int? limit}) async {
    // Always get from local database first
    List<Map<String, dynamic>> localData = await _localDb.getIssueReports(limit: limit);

    // If online, try to get fresh data and cache it
    if (_networkService.isOnline && localData.isEmpty) {
      try {
        final response = await _supabase
            .from('issue_reports')
            .select('*')
            .order('created_at', ascending: false)
            .limit(limit ?? 100);
        
        if (response.isNotEmpty) {
          await _localDb.cacheSupabaseData('issue_reports', response);
          return response;
        }
      } catch (e) {
        print('Failed to fetch fresh issue reports: $e');
      }
    }

    return localData;
  }

  // Discussion Methods
  Future<String> insertDiscussion({
    required String title,
    required String content,
    String? issueId,
    String? parentId,
    bool isPinned = false,
  }) async {
    final String id = _uuid.v4();
    final String authorId = currentUser?.id ?? '';
    final DateTime now = DateTime.now();

    final Map<String, dynamic> data = {
      'id': id,
      'author_id': authorId,
      'title': title,
      'content': content,
      'issue_id': issueId,
      'parent_id': parentId,
      'is_pinned': isPinned,
      'created_at': now.toIso8601String(),
      'updated_at': now.toIso8601String(),
    };

    // Always save to local database first
    await _localDb.insertDiscussion(data);

    // Try to sync immediately if online
    if (_networkService.isOnline) {
      try {
        await _supabase.from('discussions').insert(data);
        await _localDb.updateSyncStatus('discussions', id, 'synced');
      } catch (e) {
        print('Failed to sync discussion immediately: $e');
      }
    }

    return id;
  }

  Future<List<Map<String, dynamic>>> getDiscussions({int? limit}) async {
    // Always get from local database first
    List<Map<String, dynamic>> localData = await _localDb.getDiscussions(limit: limit);

    // If online, try to get fresh data and cache it
    if (_networkService.isOnline && localData.isEmpty) {
      try {
        final response = await _supabase
            .from('discussions')
            .select('*')
            .order('created_at', ascending: false)
            .limit(limit ?? 100);
        
        if (response.isNotEmpty) {
          await _localDb.cacheSupabaseData('discussions', response);
          return response;
        }
      } catch (e) {
        print('Failed to fetch fresh discussions: $e');
      }
    }

    return localData;
  }

  // Sync Methods
  Future<void> forceSyncAll() async {
    if (_networkService.isOnline) {
      await _syncService.syncData();
    }
  }

  Future<bool> hasPendingData() async {
    final pendingItems = await _localDb.getPendingSyncItems();
    return pendingItems.isNotEmpty;
  }

  Future<int> getPendingItemsCount() async {
    final pendingItems = await _localDb.getPendingSyncItems();
    return pendingItems.length;
  }

  // Network status
  bool get isOnline => _networkService.isOnline;
  Stream<bool> get connectionChanges => _networkService.connectionChange;
}
