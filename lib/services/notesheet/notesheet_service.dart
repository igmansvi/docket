import 'package:supabase_flutter/supabase_flutter.dart';

class NotesheetService {
  final SupabaseClient _client = Supabase.instance.client;

  Future<void> createNotesheet({
    required String title,
    required DateTime eventDate,
    required String venue,
    String? venueDetails,
    String? guests,
    required String clubName,
    String? clubDetails,
    double? estimatedBudget,
    int? expectedGathering,
    String? requirements,
    required List<String> reviewerIds,
    List<String>? attachmentUrls,
  }) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) {
      throw Exception('User not logged in.');
    }
    await _client.from('notesheets').insert({
      'title': title,
      'event_date': eventDate.toIso8601String(),
      'venue': venue,
      'venue_details': venueDetails,
      'guests': guests,
      'club_name': clubName,
      'club_details': clubDetails,
      'estimated_budget': estimatedBudget,
      'expected_gathering': expectedGathering,
      'requirements': requirements,
      'reviewer_ids': reviewerIds,
      'attachment_urls': attachmentUrls,
      'created_by': userId,
    });
  }

  Future<List<Map<String, dynamic>>> getNotesheetsForUser(String userId) async {
    final response = await _client
        .from('notesheets')
        .select('*')
        .eq('created_by', userId);
    return List<Map<String, dynamic>>.from(response);
  }

  Future<List<Map<String, dynamic>>> getNotesheetsForReviewer(
    String reviewerId,
  ) async {
    final response = await _client
        .from('notesheets')
        .select('*')
        .or('current_reviewer_id.eq.$reviewerId,reviewer_ids.cs.{$reviewerId}');
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

  Future<void> addAttachment({
    required String notesheetId,
    required List<String> attachmentUrls,
  }) async {
    await _client
        .from('notesheets')
        .update({
          'attachment_urls': attachmentUrls,
          'last_updated_at': DateTime.now().toIso8601String(),
        })
        .eq('id', notesheetId);
  }

  Future<void> updateNotesheet({
    required String notesheetId,
    required Map<String, dynamic> data,
  }) async {
    data['last_updated_at'] = DateTime.now().toIso8601String();
    await _client.from('notesheets').update(data).eq('id', notesheetId);
  }
}
