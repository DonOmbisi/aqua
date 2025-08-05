import 'package:supabase_flutter/supabase_flutter.dart';

import './supabase_service.dart';

class WaterDataService {
  final SupabaseService _supabaseService = SupabaseService();

  // Create new water data entry
  Future<Map<String, dynamic>> createWaterData({
    required double latitude,
    required double longitude,
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
    try {
      final client = await _supabaseService.client;
      final user = client.auth.currentUser;

      if (user == null) throw Exception('User not authenticated');

      final response = await client
          .from('water_data')
          .insert({
            'user_id': user.id,
            'location_coordinates': 'POINT($longitude $latitude)',
            'location_name': locationName,
            'ph_level': phLevel,
            'turbidity': turbidity,
            'temperature': temperature,
            'dissolved_oxygen': dissolvedOxygen,
            'water_level': waterLevel,
            'flow_rate': flowRate,
            'photos': photos ?? [],
            'notes': notes,
          })
          .select()
          .single();

      return response;
    } catch (error) {
      throw Exception('Failed to create water data: $error');
    }
  }

  // Get water data with optional filtering
  Future<List<Map<String, dynamic>>> getWaterData({
    String? userId,
    String? verificationStatus,
    int? limit,
    int? offset,
  }) async {
    try {
      final client = await _supabaseService.client;

      var queryBuilder = client.from('water_data').select('''
            *,
            user_profiles!water_data_user_id_fkey(username, full_name)
          ''');

      if (userId != null) {
        queryBuilder = queryBuilder.eq('user_id', userId);
      }

      if (verificationStatus != null) {
        queryBuilder = queryBuilder.eq('verification_status', verificationStatus);
      }

      // Apply ordering first, then pagination
      var orderedQuery = queryBuilder.order('created_at', ascending: false);

      if (limit != null) {
        orderedQuery = orderedQuery.limit(limit);
      }

      if (offset != null) {
        orderedQuery = orderedQuery.range(offset, offset + (limit ?? 50) - 1);
      }

      final response = await orderedQuery;
      return List<Map<String, dynamic>>.from(response);
    } catch (error) {
      throw Exception('Failed to get water data: $error');
    }
  }

  // Get water data by location (within radius)
  Future<List<Map<String, dynamic>>> getWaterDataByLocation({
    required double latitude,
    required double longitude,
    double radiusKm = 10.0,
    int? limit,
  }) async {
    try {
      final client = await _supabaseService.client;

      // Using PostGIS for spatial queries
      final response =
          await client.rpc('get_water_data_within_radius', params: {
        'center_lat': latitude,
        'center_lng': longitude,
        'radius_km': radiusKm,
        'max_results': limit ?? 100,
      });

      return List<Map<String, dynamic>>.from(response);
    } catch (error) {
      // Fallback to basic query if spatial function not available
      return await getWaterData(limit: limit);
    }
  }

  // Update water data
  Future<Map<String, dynamic>> updateWaterData({
    required String id,
    required Map<String, dynamic> updates,
  }) async {
    try {
      final client = await _supabaseService.client;

      final response = await client
          .from('water_data')
          .update(updates)
          .eq('id', id)
          .select()
          .single();

      return response;
    } catch (error) {
      throw Exception('Failed to update water data: $error');
    }
  }

  // Delete water data
  Future<void> deleteWaterData({required String id}) async {
    try {
      final client = await _supabaseService.client;

      await client.from('water_data').delete().eq('id', id);
    } catch (error) {
      throw Exception('Failed to delete water data: $error');
    }
  }

  // Get water quality statistics
  Future<Map<String, dynamic>> getWaterQualityStats({
    String? userId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final client = await _supabaseService.client;

      var query = client.from('water_data').select(
          'ph_level, turbidity, temperature, dissolved_oxygen, verification_status');

      if (userId != null) {
        query = query.eq('user_id', userId);
      }

      if (startDate != null) {
        query = query.gte('created_at', startDate.toIso8601String());
      }

      if (endDate != null) {
        query = query.lte('created_at', endDate.toIso8601String());
      }

      final response = await query;
      final data = List<Map<String, dynamic>>.from(response);

      // Calculate statistics
      if (data.isEmpty) {
        return {
          'total_samples': 0,
          'verified_samples': 0,
          'avg_ph': null,
          'avg_turbidity': null,
          'avg_temperature': null,
          'avg_dissolved_oxygen': null,
        };
      }

      final verifiedSamples =
          data.where((d) => d['verification_status'] == 'verified').length;

      double? avgPh, avgTurbidity, avgTemp, avgDO;

      final phValues = data
          .where((d) => d['ph_level'] != null)
          .map((d) => d['ph_level'] as double)
          .toList();
      final turbidityValues = data
          .where((d) => d['turbidity'] != null)
          .map((d) => d['turbidity'] as double)
          .toList();
      final tempValues = data
          .where((d) => d['temperature'] != null)
          .map((d) => d['temperature'] as double)
          .toList();
      final doValues = data
          .where((d) => d['dissolved_oxygen'] != null)
          .map((d) => d['dissolved_oxygen'] as double)
          .toList();

      if (phValues.isNotEmpty)
        avgPh = phValues.reduce((a, b) => a + b) / phValues.length;
      if (turbidityValues.isNotEmpty)
        avgTurbidity =
            turbidityValues.reduce((a, b) => a + b) / turbidityValues.length;
      if (tempValues.isNotEmpty)
        avgTemp = tempValues.reduce((a, b) => a + b) / tempValues.length;
      if (doValues.isNotEmpty)
        avgDO = doValues.reduce((a, b) => a + b) / doValues.length;

      return {
        'total_samples': data.length,
        'verified_samples': verifiedSamples,
        'avg_ph': avgPh,
        'avg_turbidity': avgTurbidity,
        'avg_temperature': avgTemp,
        'avg_dissolved_oxygen': avgDO,
      };
    } catch (error) {
      throw Exception('Failed to get water quality statistics: $error');
    }
  }

  // Subscribe to real-time water data changes
  Future<RealtimeChannel> subscribeToWaterData({
    required Function(Map<String, dynamic>) onInsert,
    required Function(Map<String, dynamic>) onUpdate,
    required Function(Map<String, dynamic>) onDelete,
  }) async {
    final client = await _supabaseService.client;

    return client
        .channel('water_data_changes')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'water_data',
          callback: (payload) => onInsert(payload.newRecord),
        )
        .onPostgresChanges(
          event: PostgresChangeEvent.update,
          schema: 'public',
          table: 'water_data',
          callback: (payload) => onUpdate(payload.newRecord),
        )
        .onPostgresChanges(
          event: PostgresChangeEvent.delete,
          schema: 'public',
          table: 'water_data',
          callback: (payload) => onDelete(payload.oldRecord),
        )
        .subscribe();
  }
}