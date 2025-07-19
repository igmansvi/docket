import 'package:supabase_flutter/supabase_flutter.dart';

class ReviewService {
  final SupabaseClient _client = Supabase.instance.client;

  Future<void> addComment({
    required String notesheetId,
    required String commentText,
  }) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) {
      throw Exception('User not logged in.');
    }
    await _client.from('comments').insert({
      'notesheet_id': notesheetId,
      'user_id': userId,
      'comment_text': commentText,
    });
  }

  Future<List<Map<String, dynamic>>> getCommentsForNotesheet(String notesheetId) async {
    final response = await _client
        .from('comments')
        .select('*')
        .eq('notesheet_id', notesheetId)
        .order('created_at');
    return List<Map<String, dynamic>>.from(response);
  }

  Future<void> updateNotesheetStatus({
    required String notesheetId,
    required String status,
    String? currentReviewerId,
    String? nextReviewerLevel,
  }) async {
    final data = {
      'status': status,
      'last_updated_at': DateTime.now().toIso8601String(),
      if (currentReviewerId != null) 'current_reviewer_id': currentReviewerId,
      if (nextReviewerLevel != null) 'next_reviewer_level': nextReviewerLevel,
    };
    await _client.from('notesheets').update(data).eq('id', notesheetId);
  }

  Future<List<Map<String, dynamic>>> getNotesheetsToReview() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) {
      throw Exception('User not logged in.');
    }
    final response = await _client
        .from('notesheets')
        .select('*')
        .or('current_reviewer_id.eq.$userId,reviewer_ids.cs.{$userId}') ;
    return List<Map<String, dynamic>>.from(response);
  }

  Future<List<String>> getReviewersForNotesheet(String notesheetId) async {
    final response = await _client
        .from('notesheets')
        .select('reviewer_ids')
        .eq('id', notesheetId)
        .single();
    return List<String>.from(response['reviewer_ids'] ?? []);
  }
}