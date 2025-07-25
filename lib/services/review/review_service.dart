import 'package:docket/data/models/review.dart';
import 'package:docket/data/models/notesheet.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ReviewService {
  final SupabaseClient _supabaseClient;

  ReviewService() : _supabaseClient = Supabase.instance.client;

  Future<void> createReview(Review review) async {
    await _supabaseClient.from('reviews').insert({
      'reviewer_id': review.reviewerId,
      'notesheet_id': review.notesheetId,
      'comment': review.comment,
      'status': review.status.toString().split('.').last,
      'created_at': review.createdAt.toIso8601String(),
    });
  }

  Future<List<Review>> getReviewsForNotesheet(String notesheetId) async {
    final List<dynamic> response = await _supabaseClient
        .from('reviews')
        .select('*')
        .eq('notesheet_id', notesheetId);
    return response.map((json) {
      return Review(
        id: json['id'],
        reviewerId: json['reviewer_id'],
        notesheetId: json['notesheet_id'],
        comment: json['comment'],
        status: NotesheetStatus.values.firstWhere(
          (e) => e.toString().split('.').last == json['status'],
        ),
        createdAt: DateTime.parse(json['created_at']),
      );
    }).toList();
  }

  Future<List<Notesheet>> getNotesheetsForReviewer(String reviewerId) async {
    final List<dynamic> response = await _supabaseClient
        .from('notesheets')
        .select('*')
        .eq('status', 'pending')
        .contains('reviewers', [reviewerId]);

    return response.map((json) {
      return Notesheet(
        id: json['id'],
        createdBy: json['created_by'],
        createdAt: DateTime.parse(json['created_at']),
        title: json['title'],
        description: json['description'],
        reviewers: List<String>.from(json['reviewers'] ?? []),
        status: NotesheetStatus.values.firstWhere(
          (e) => e.toString().split('.').last == json['status'],
        ),
        details: NotesheetDetails(
          eventTitle: json['event_title'],
          eventDescription: json['event_description'],
          eventDate: json['event_date'] != null
              ? DateTime.parse(json['event_date'])
              : null,
          eventVenue: json['event_venue'],
          eventOrganiser: json['event_organiser'],
          eventBudget: json['event_budget'],
          eventRequirements: json['event_requirements'],
          guests: List<String>.from(json['guests'] ?? []),
          miscellanous: json['miscellaneous'],
        ),
      );
    }).toList();
  }

  Future<List<Review>> getReviewsByReviewer(String reviewerId) async {
    final List<dynamic> response = await _supabaseClient
        .from('reviews')
        .select('*')
        .eq('reviewer_id', reviewerId);
    return response.map((json) {
      return Review(
        id: json['id'],
        reviewerId: json['reviewer_id'],
        notesheetId: json['notesheet_id'],
        comment: json['comment'],
        status: NotesheetStatus.values.firstWhere(
          (e) => e.toString().split('.').last == json['status'],
        ),
        createdAt: DateTime.parse(json['created_at']),
      );
    }).toList();
  }

  Future<void> updateReview(Review review) async {
    await _supabaseClient
        .from('reviews')
        .update({
          'comment': review.comment,
          'status': review.status.toString().split('.').last,
          'created_at': review.createdAt.toIso8601String(),
        })
        .eq('id', review.id!);
  }

  Future<void> deleteReview(String id) async {
    await _supabaseClient.from('reviews').delete().eq('id', id);
  }
}
