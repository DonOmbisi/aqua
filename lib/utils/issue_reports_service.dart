import 'package:supabase_flutter/supabase_flutter.dart';

import './supabase_service.dart';

class IssueReportsService {
  final SupabaseService _supabaseService = SupabaseService();

  // Create new issue report
  Future<Map<String, dynamic>> createIssueReport({
    required String title,
    required String description,
    required String category,
    required double latitude,
    required double longitude,
    String? locationName,
    List<String>? photos,
    int priority = 1,
  }) async {
    try {
      final client = await _supabaseService.client;
      final user = client.auth.currentUser;

      if (user == null) throw Exception('User not authenticated');

      final response = await client.from('issue_reports').insert({
        'reporter_id': user.id,
        'title': title,
        'description': description,
        'category': category,
        'location_coordinates': 'POINT($longitude $latitude)',
        'location_name': locationName,
        'photos': photos ?? [],
        'priority': priority,
      }).select('''
            *,
            user_profiles!issue_reports_reporter_id_fkey(username, full_name)
          ''').single();

      return response;
    } catch (error) {
      throw Exception('Failed to create issue report: $error');
    }
  }

  // Get issue reports with optional filtering
  Future<List<Map<String, dynamic>>> getIssueReports({
    String? status,
    String? category,
    String? reporterId,
    int? limit,
    int? offset,
  }) async {
    try {
      final client = await _supabaseService.client;

      var queryBuilder = client.from('issue_reports').select('''
            *,
            user_profiles!issue_reports_reporter_id_fkey(username, full_name),
            assigned_user:user_profiles!issue_reports_assigned_to_fkey(username, full_name)
          ''');

      if (status != null) {
        queryBuilder = queryBuilder.eq('status', status);
      }

      if (category != null) {
        queryBuilder = queryBuilder.eq('category', category);
      }

      if (reporterId != null) {
        queryBuilder = queryBuilder.eq('reporter_id', reporterId);
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
      throw Exception('Failed to get issue reports: $error');
    }
  }

  // Get issue reports by location
  Future<List<Map<String, dynamic>>> getIssueReportsByLocation({
    required double latitude,
    required double longitude,
    double radiusKm = 10.0,
    int? limit,
  }) async {
    try {
      final client = await _supabaseService.client;

      // Using PostGIS for spatial queries
      final response =
          await client.rpc('get_issue_reports_within_radius', params: {
        'center_lat': latitude,
        'center_lng': longitude,
        'radius_km': radiusKm,
        'max_results': limit ?? 100,
      });

      return List<Map<String, dynamic>>.from(response);
    } catch (error) {
      // Fallback to basic query if spatial function not available
      return await getIssueReports(limit: limit);
    }
  }

  // Update issue report
  Future<Map<String, dynamic>> updateIssueReport({
    required String id,
    required Map<String, dynamic> updates,
  }) async {
    try {
      final client = await _supabaseService.client;

      final response = await client
          .from('issue_reports')
          .update(updates)
          .eq('id', id)
          .select('''
            *,
            user_profiles!issue_reports_reporter_id_fkey(username, full_name),
            assigned_user:user_profiles!issue_reports_assigned_to_fkey(username, full_name)
          ''').single();

      return response;
    } catch (error) {
      throw Exception('Failed to update issue report: $error');
    }
  }

  // Assign issue to user
  Future<Map<String, dynamic>> assignIssue({
    required String issueId,
    required String assigneeId,
  }) async {
    try {
      return await updateIssueReport(
        id: issueId,
        updates: {
          'assigned_to': assigneeId,
          'status': 'in_progress',
        },
      );
    } catch (error) {
      throw Exception('Failed to assign issue: $error');
    }
  }

  // Resolve issue
  Future<Map<String, dynamic>> resolveIssue({
    required String issueId,
  }) async {
    try {
      return await updateIssueReport(
        id: issueId,
        updates: {
          'status': 'resolved',
          'resolved_at': DateTime.now().toIso8601String(),
        },
      );
    } catch (error) {
      throw Exception('Failed to resolve issue: $error');
    }
  }

  // Get issue statistics
  Future<Map<String, dynamic>> getIssueStatistics({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final client = await _supabaseService.client;

      var query = client
          .from('issue_reports')
          .select('status, category, priority, created_at');

      if (startDate != null) {
        query = query.gte('created_at', startDate.toIso8601String());
      }

      if (endDate != null) {
        query = query.lte('created_at', endDate.toIso8601String());
      }

      final response = await query;
      final data = List<Map<String, dynamic>>.from(response);

      // Calculate statistics
      final statusCounts = <String, int>{};
      final categoryCounts = <String, int>{};
      int totalIssues = data.length;
      int resolvedIssues = 0;
      double avgPriority = 0;

      for (final issue in data) {
        final status = issue['status'] as String;
        final category = issue['category'] as String;
        final priority = issue['priority'] as int;

        statusCounts[status] = (statusCounts[status] ?? 0) + 1;
        categoryCounts[category] = (categoryCounts[category] ?? 0) + 1;

        if (status == 'resolved' || status == 'closed') {
          resolvedIssues++;
        }

        avgPriority += priority;
      }

      if (totalIssues > 0) {
        avgPriority = avgPriority / totalIssues;
      }

      return {
        'total_issues': totalIssues,
        'resolved_issues': resolvedIssues,
        'resolution_rate':
            totalIssues > 0 ? (resolvedIssues / totalIssues * 100) : 0,
        'avg_priority': avgPriority,
        'status_breakdown': statusCounts,
        'category_breakdown': categoryCounts,
      };
    } catch (error) {
      throw Exception('Failed to get issue statistics: $error');
    }
  }

  // Subscribe to real-time issue reports changes
  Future<RealtimeChannel> subscribeToIssueReports({
    required Function(Map<String, dynamic>) onInsert,
    required Function(Map<String, dynamic>) onUpdate,
    required Function(Map<String, dynamic>) onDelete,
  }) async {
    final client = await _supabaseService.client;

    return client
        .channel('issue_reports_changes')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'issue_reports',
          callback: (payload) => onInsert(payload.newRecord),
        )
        .onPostgresChanges(
          event: PostgresChangeEvent.update,
          schema: 'public',
          table: 'issue_reports',
          callback: (payload) => onUpdate(payload.newRecord),
        )
        .onPostgresChanges(
          event: PostgresChangeEvent.delete,
          schema: 'public',
          table: 'issue_reports',
          callback: (payload) => onDelete(payload.oldRecord),
        )
        .subscribe();
  }
}