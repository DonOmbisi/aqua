import 'package:supabase_flutter/supabase_flutter.dart';

import './supabase_service.dart';

class DiscussionsService {
  final SupabaseService _supabaseService = SupabaseService();

  // Create new discussion
  Future<Map<String, dynamic>> createDiscussion({
    required String title,
    required String content,
    String? issueId,
    String? parentId,
    bool isPinned = false,
  }) async {
    try {
      final client = await _supabaseService.client;
      final user = client.auth.currentUser;

      if (user == null) throw Exception('User not authenticated');

      final response = await client.from('discussions').insert({
        'author_id': user.id,
        'title': title,
        'content': content,
        'issue_id': issueId,
        'parent_id': parentId,
        'is_pinned': isPinned,
      }).select('''
            *,
            user_profiles!discussions_author_id_fkey(username, full_name, role),
            issue_reports!discussions_issue_id_fkey(title, status),
            parent_discussion:discussions!discussions_parent_id_fkey(title, author_id)
          ''').single();

      return response;
    } catch (error) {
      throw Exception('Failed to create discussion: $error');
    }
  }

  // Get discussions with optional filtering
  Future<List<Map<String, dynamic>>> getDiscussions({
    String? issueId,
    String? parentId,
    bool? isPinned,
    int? limit,
    int? offset,
  }) async {
    try {
      final client = await _supabaseService.client;

      var queryBuilder = client
          .from('discussions')
          .select('''
            *,
            user_profiles!discussions_author_id_fkey(username, full_name, role),
            issue_reports!discussions_issue_id_fkey(title, status),
            parent_discussion:discussions!discussions_parent_id_fkey(title, author_id),
            replies:discussions!discussions_parent_id_fkey(count)
          ''');

      if (issueId != null) {
        queryBuilder = queryBuilder.eq('issue_id', issueId);
      }

      if (parentId != null) {
        queryBuilder = queryBuilder.eq('parent_id', parentId);
      } else {
        // Only get top-level discussions if no parent specified
        queryBuilder = queryBuilder.isFilter('parent_id', null);
      }

      if (isPinned != null) {
        queryBuilder = queryBuilder.eq('is_pinned', isPinned);
      }

      // Apply ordering first, then pagination
      var orderedQuery = queryBuilder
          .order('is_pinned', ascending: false)
          .order('created_at', ascending: false);

      if (limit != null) {
        orderedQuery = orderedQuery.limit(limit);
      }

      if (offset != null) {
        orderedQuery = orderedQuery.range(offset, offset + (limit ?? 50) - 1);
      }

      final response = await orderedQuery;
      return List<Map<String, dynamic>>.from(response);
    } catch (error) {
      throw Exception('Failed to get discussions: $error');
    }
  }

  // Get discussion replies
  Future<List<Map<String, dynamic>>> getDiscussionReplies({
    required String parentId,
    int? limit,
    int? offset,
  }) async {
    try {
      return await getDiscussions(
        parentId: parentId,
        limit: limit,
        offset: offset,
      );
    } catch (error) {
      throw Exception('Failed to get discussion replies: $error');
    }
  }

  // Get single discussion with full details
  Future<Map<String, dynamic>> getDiscussion({required String id}) async {
    try {
      final client = await _supabaseService.client;

      final response = await client.from('discussions').select('''
            *,
            user_profiles!discussions_author_id_fkey(username, full_name, role),
            issue_reports!discussions_issue_id_fkey(title, status, category),
            parent_discussion:discussions!discussions_parent_id_fkey(title, author_id)
          ''').eq('id', id).single();

      return response;
    } catch (error) {
      throw Exception('Failed to get discussion: $error');
    }
  }

  // Update discussion
  Future<Map<String, dynamic>> updateDiscussion({
    required String id,
    required Map<String, dynamic> updates,
  }) async {
    try {
      final client = await _supabaseService.client;

      final response = await client
          .from('discussions')
          .update(updates)
          .eq('id', id)
          .select('''
            *,
            user_profiles!discussions_author_id_fkey(username, full_name, role),
            issue_reports!discussions_issue_id_fkey(title, status),
            parent_discussion:discussions!discussions_parent_id_fkey(title, author_id)
          ''').single();

      return response;
    } catch (error) {
      throw Exception('Failed to update discussion: $error');
    }
  }

  // Pin/unpin discussion (moderators only)
  Future<Map<String, dynamic>> togglePinDiscussion({
    required String id,
    required bool isPinned,
  }) async {
    try {
      return await updateDiscussion(
        id: id,
        updates: {'is_pinned': isPinned},
      );
    } catch (error) {
      throw Exception('Failed to toggle pin discussion: $error');
    }
  }

  // Delete discussion
  Future<void> deleteDiscussion({required String id}) async {
    try {
      final client = await _supabaseService.client;

      await client.from('discussions').delete().eq('id', id);
    } catch (error) {
      throw Exception('Failed to delete discussion: $error');
    }
  }

  // Search discussions
  Future<List<Map<String, dynamic>>> searchDiscussions({
    required String searchTerm,
    int? limit,
  }) async {
    try {
      final client = await _supabaseService.client;

      final response = await client
          .from('discussions')
          .select('''
            *,
            user_profiles!discussions_author_id_fkey(username, full_name, role),
            issue_reports!discussions_issue_id_fkey(title, status)
          ''')
          .or('title.ilike.%$searchTerm%,content.ilike.%$searchTerm%')
          .order('created_at', ascending: false)
          .limit(limit ?? 50);

      return List<Map<String, dynamic>>.from(response);
    } catch (error) {
      throw Exception('Failed to search discussions: $error');
    }
  }

  // Get discussion statistics
  Future<Map<String, dynamic>> getDiscussionStatistics({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final client = await _supabaseService.client;

      var query = client
          .from('discussions')
          .select('author_id, parent_id, issue_id, created_at');

      if (startDate != null) {
        query = query.gte('created_at', startDate.toIso8601String());
      }

      if (endDate != null) {
        query = query.lte('created_at', endDate.toIso8601String());
      }

      final response = await query;
      final data = List<Map<String, dynamic>>.from(response);

      // Calculate statistics
      int totalDiscussions = data.length;
      int topLevelDiscussions =
          data.where((d) => d['parent_id'] == null).length;
      int replies = totalDiscussions - topLevelDiscussions;
      int issueRelatedDiscussions =
          data.where((d) => d['issue_id'] != null).length;

      // Get unique contributors
      final uniqueAuthors = data.map((d) => d['author_id']).toSet().length;

      return {
        'total_discussions': totalDiscussions,
        'top_level_discussions': topLevelDiscussions,
        'total_replies': replies,
        'issue_related_discussions': issueRelatedDiscussions,
        'unique_contributors': uniqueAuthors,
        'avg_replies_per_discussion':
            topLevelDiscussions > 0 ? (replies / topLevelDiscussions) : 0,
      };
    } catch (error) {
      throw Exception('Failed to get discussion statistics: $error');
    }
  }

  // Subscribe to real-time discussion changes
  Future<RealtimeChannel> subscribeToDiscussions({
    String? issueId,
    required Function(Map<String, dynamic>) onInsert,
    required Function(Map<String, dynamic>) onUpdate,
    required Function(Map<String, dynamic>) onDelete,
  }) async {
    final client = await _supabaseService.client;

    var channel = client
        .channel('discussions_changes')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'discussions',
          callback: (payload) => onInsert(payload.newRecord),
        )
        .onPostgresChanges(
          event: PostgresChangeEvent.update,
          schema: 'public',
          table: 'discussions',
          callback: (payload) => onUpdate(payload.newRecord),
        )
        .onPostgresChanges(
          event: PostgresChangeEvent.delete,
          schema: 'public',
          table: 'discussions',
          callback: (payload) => onDelete(payload.oldRecord),
        );

    // Add filter for specific issue if provided
    if (issueId != null) {
      channel = channel.onPostgresChanges(
        event: PostgresChangeEvent.all,
        schema: 'public',
        table: 'discussions',
        filter: PostgresChangeFilter(
          type: PostgresChangeFilterType.eq,
          column: 'issue_id',
          value: issueId,
        ),
        callback: (payload) {
          // Handle filtered changes
        },
      );
    }

    return channel.subscribe();
  }
}