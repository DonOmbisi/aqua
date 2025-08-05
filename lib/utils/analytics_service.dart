
import './supabase_service.dart';

class AnalyticsService {
  final SupabaseService _supabaseService = SupabaseService();

  // Get dashboard analytics
  Future<Map<String, dynamic>> getDashboardAnalytics({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final client = await _supabaseService.client;

      // Set default date range if not provided
      final end = endDate ?? DateTime.now();
      final start = startDate ?? end.subtract(const Duration(days: 30));

      // Get water data count
      final waterDataResponse = await client
          .from('water_data')
          .select('id')
          .gte('created_at', start.toIso8601String())
          .lte('created_at', end.toIso8601String())
          .count();

      // Get issue reports count
      final issueReportsResponse = await client
          .from('issue_reports')
          .select('id, status')
          .gte('created_at', start.toIso8601String())
          .lte('created_at', end.toIso8601String());

      // Get active users count
      final activeUsersResponse = await client
          .from('user_profiles')
          .select('id')
          .gte('created_at', start.toIso8601String())
          .lte('created_at', end.toIso8601String())
          .count();

      // Get water quality trends
      final waterQualityResponse = await client
          .from('water_analytics')
          .select('*')
          .gte('date_recorded', start.toIso8601String().split('T')[0])
          .lte('date_recorded', end.toIso8601String().split('T')[0])
          .order('date_recorded', ascending: true);

      final issueReports =
          List<Map<String, dynamic>>.from(issueReportsResponse);
      final resolvedIssues = issueReports
          .where((issue) =>
              issue['status'] == 'resolved' || issue['status'] == 'closed')
          .length;

      return {
        'water_samples': waterDataResponse.count,
        'issue_reports': issueReports.length,
        'resolved_issues': resolvedIssues,
        'active_users': activeUsersResponse.count,
        'resolution_rate': issueReports.isNotEmpty
            ? (resolvedIssues / issueReports.length * 100)
            : 0.0,
        'water_quality_trends': waterQualityResponse,
      };
    } catch (error) {
      throw Exception('Failed to get dashboard analytics: $error');
    }
  }

  // Get water quality trends
  Future<List<Map<String, dynamic>>> getWaterQualityTrends({
    DateTime? startDate,
    DateTime? endDate,
    String? parameter,
  }) async {
    try {
      final client = await _supabaseService.client;

      final end = endDate ?? DateTime.now();
      final start = startDate ?? end.subtract(const Duration(days: 30));

      String selectFields = '*';
      if (parameter != null) {
        selectFields = 'date_recorded, location_coordinates, $parameter';
      }

      final response = await client
          .from('water_analytics')
          .select(selectFields)
          .gte('date_recorded', start.toIso8601String().split('T')[0])
          .lte('date_recorded', end.toIso8601String().split('T')[0])
          .order('date_recorded', ascending: true);

      return List<Map<String, dynamic>>.from(response);
    } catch (error) {
      throw Exception('Failed to get water quality trends: $error');
    }
  }

  // Get issue categories breakdown
  Future<Map<String, dynamic>> getIssueCategoriesBreakdown({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final client = await _supabaseService.client;

      final end = endDate ?? DateTime.now();
      final start = startDate ?? end.subtract(const Duration(days: 30));

      final response = await client
          .from('issue_reports')
          .select('category, status')
          .gte('created_at', start.toIso8601String())
          .lte('created_at', end.toIso8601String());

      final data = List<Map<String, dynamic>>.from(response);

      // Count by category
      final categoryCounts = <String, Map<String, int>>{};

      for (final issue in data) {
        final category = issue['category'] as String;
        final status = issue['status'] as String;

        if (!categoryCounts.containsKey(category)) {
          categoryCounts[category] = {
            'total': 0,
            'resolved': 0,
            'in_progress': 0,
            'reported': 0,
          };
        }

        categoryCounts[category]!['total'] =
            categoryCounts[category]!['total']! + 1;

        if (status == 'resolved' || status == 'closed') {
          categoryCounts[category]!['resolved'] =
              categoryCounts[category]!['resolved']! + 1;
        } else if (status == 'in_progress' || status == 'investigating') {
          categoryCounts[category]!['in_progress'] =
              categoryCounts[category]!['in_progress']! + 1;
        } else {
          categoryCounts[category]!['reported'] =
              categoryCounts[category]!['reported']! + 1;
        }
      }

      return {
        'total_issues': data.length,
        'categories': categoryCounts,
      };
    } catch (error) {
      throw Exception('Failed to get issue categories breakdown: $error');
    }
  }

  // Get geographic distribution of data points
  Future<List<Map<String, dynamic>>> getGeographicDistribution({
    String? dataType = 'water_data', // 'water_data' or 'issue_reports'
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final client = await _supabaseService.client;

      final end = endDate ?? DateTime.now();
      final start = startDate ?? end.subtract(const Duration(days: 30));

      late List<dynamic> response;

      if (dataType == 'water_data') {
        response = await client
            .from('water_data')
            .select(
                'location_coordinates, location_name, ph_level, turbidity, verification_status')
            .gte('created_at', start.toIso8601String())
            .lte('created_at', end.toIso8601String());
      } else {
        response = await client
            .from('issue_reports')
            .select(
                'location_coordinates, location_name, category, status, priority')
            .gte('created_at', start.toIso8601String())
            .lte('created_at', end.toIso8601String());
      }

      return List<Map<String, dynamic>>.from(response);
    } catch (error) {
      throw Exception('Failed to get geographic distribution: $error');
    }
  }

  // Get user engagement metrics
  Future<Map<String, dynamic>> getUserEngagementMetrics({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final client = await _supabaseService.client;

      final end = endDate ?? DateTime.now();
      final start = startDate ?? end.subtract(const Duration(days: 30));

      // Get water data submissions by user
      final waterDataSubmissions = await client
          .from('water_data')
          .select('user_id')
          .gte('created_at', start.toIso8601String())
          .lte('created_at', end.toIso8601String());

      // Get issue reports by user
      final issueReports = await client
          .from('issue_reports')
          .select('reporter_id')
          .gte('created_at', start.toIso8601String())
          .lte('created_at', end.toIso8601String());

      // Get discussions by user
      final discussions = await client
          .from('discussions')
          .select('author_id')
          .gte('created_at', start.toIso8601String())
          .lte('created_at', end.toIso8601String());

      // Calculate engagement metrics
      final waterDataUsers =
          List<Map<String, dynamic>>.from(waterDataSubmissions)
              .map((d) => d['user_id'])
              .toSet();

      final issueReportUsers = List<Map<String, dynamic>>.from(issueReports)
          .map((d) => d['reporter_id'])
          .toSet();

      final discussionUsers = List<Map<String, dynamic>>.from(discussions)
          .map((d) => d['author_id'])
          .toSet();

      final allActiveUsers = {
        ...waterDataUsers,
        ...issueReportUsers,
        ...discussionUsers
      };

      return {
        'active_contributors': allActiveUsers.length,
        'water_data_contributors': waterDataUsers.length,
        'issue_reporters': issueReportUsers.length,
        'discussion_participants': discussionUsers.length,
        'total_water_submissions': waterDataSubmissions.length,
        'total_issue_reports': issueReports.length,
        'total_discussions': discussions.length,
      };
    } catch (error) {
      throw Exception('Failed to get user engagement metrics: $error');
    }
  }

  // Export data to CSV format
  Future<String> exportDataToCsv({
    required String dataType, // 'water_data', 'issue_reports', 'discussions'
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final client = await _supabaseService.client;

      final end = endDate ?? DateTime.now();
      final start = startDate ?? end.subtract(const Duration(days: 30));

      late List<dynamic> response;
      late List<String> headers;

      switch (dataType) {
        case 'water_data':
          response = await client
              .from('water_data')
              .select('''
                id, user_id, location_name, ph_level, turbidity, temperature,
                dissolved_oxygen, water_level, flow_rate, notes, verification_status,
                created_at, user_profiles!water_data_user_id_fkey(username, full_name)
              ''')
              .gte('created_at', start.toIso8601String())
              .lte('created_at', end.toIso8601String())
              .order('created_at', ascending: true);

          headers = [
            'ID',
            'User',
            'Location',
            'pH Level',
            'Turbidity',
            'Temperature',
            'Dissolved Oxygen',
            'Water Level',
            'Flow Rate',
            'Notes',
            'Verification Status',
            'Created At'
          ];
          break;

        case 'issue_reports':
          response = await client
              .from('issue_reports')
              .select('''
                id, title, description, category, location_name, status, priority,
                created_at, resolved_at, user_profiles!issue_reports_reporter_id_fkey(username, full_name)
              ''')
              .gte('created_at', start.toIso8601String())
              .lte('created_at', end.toIso8601String())
              .order('created_at', ascending: true);

          headers = [
            'ID',
            'Title',
            'Description',
            'Category',
            'Location',
            'Status',
            'Priority',
            'Reporter',
            'Created At',
            'Resolved At'
          ];
          break;

        case 'discussions':
          response = await client
              .from('discussions')
              .select('''
                id, title, content, is_pinned, created_at,
                user_profiles!discussions_author_id_fkey(username, full_name),
                issue_reports!discussions_issue_id_fkey(title)
              ''')
              .gte('created_at', start.toIso8601String())
              .lte('created_at', end.toIso8601String())
              .order('created_at', ascending: true);

          headers = [
            'ID',
            'Title',
            'Content',
            'Author',
            'Related Issue',
            'Is Pinned',
            'Created At'
          ];
          break;

        default:
          throw Exception('Invalid data type for export');
      }

      // Convert to CSV format
      final csvRows = <String>[];
      csvRows.add(headers.join(','));

      final data = List<Map<String, dynamic>>.from(response);

      for (final item in data) {
        final row = <String>[];

        switch (dataType) {
          case 'water_data':
            row.addAll([
              item['id']?.toString() ?? '',
              item['user_profiles']?['full_name']?.toString() ?? '',
              item['location_name']?.toString() ?? '',
              item['ph_level']?.toString() ?? '',
              item['turbidity']?.toString() ?? '',
              item['temperature']?.toString() ?? '',
              item['dissolved_oxygen']?.toString() ?? '',
              item['water_level']?.toString() ?? '',
              item['flow_rate']?.toString() ?? '',
              item['notes']?.toString() ?? '',
              item['verification_status']?.toString() ?? '',
              item['created_at']?.toString() ?? '',
            ]);
            break;

          case 'issue_reports':
            row.addAll([
              item['id']?.toString() ?? '',
              item['title']?.toString() ?? '',
              item['description']?.toString() ?? '',
              item['category']?.toString() ?? '',
              item['location_name']?.toString() ?? '',
              item['status']?.toString() ?? '',
              item['priority']?.toString() ?? '',
              item['user_profiles']?['full_name']?.toString() ?? '',
              item['created_at']?.toString() ?? '',
              item['resolved_at']?.toString() ?? '',
            ]);
            break;

          case 'discussions':
            row.addAll([
              item['id']?.toString() ?? '',
              item['title']?.toString() ?? '',
              item['content']?.toString() ?? '',
              item['user_profiles']?['full_name']?.toString() ?? '',
              item['issue_reports']?['title']?.toString() ?? '',
              item['is_pinned']?.toString() ?? '',
              item['created_at']?.toString() ?? '',
            ]);
            break;
        }

        // Escape commas and quotes in CSV data
        final escapedRow = row.map((field) {
          if (field.contains(',') ||
              field.contains('"') ||
              field.contains('\n')) {
            return '"${field.replaceAll('"', '""')}"';
          }
          return field;
        }).toList();

        csvRows.add(escapedRow.join(','));
      }

      return csvRows.join('\n');
    } catch (error) {
      throw Exception('Failed to export data to CSV: $error');
    }
  }

  // Generate summary report
  Future<Map<String, dynamic>> generateSummaryReport({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final end = endDate ?? DateTime.now();
      final start = startDate ?? end.subtract(const Duration(days: 30));

      // Run multiple analytics queries in parallel
      final results = await Future.wait([
        getDashboardAnalytics(startDate: start, endDate: end),
        getIssueCategoriesBreakdown(startDate: start, endDate: end),
        getUserEngagementMetrics(startDate: start, endDate: end),
      ]);

      return {
        'report_period': {
          'start_date': start.toIso8601String(),
          'end_date': end.toIso8601String(),
        },
        'dashboard_metrics': results[0],
        'issue_categories': results[1],
        'user_engagement': results[2],
        'generated_at': DateTime.now().toIso8601String(),
      };
    } catch (error) {
      throw Exception('Failed to generate summary report: $error');
    }
  }
}
