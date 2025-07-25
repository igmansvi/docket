import 'package:docket/data/models/notesheet.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class NotesheetService {
  final SupabaseClient _supabaseClient;

  NotesheetService() : _supabaseClient = Supabase.instance.client;

  Future<List<Map<String, dynamic>>> getReviewers() async {
    final List<dynamic> response = await _supabaseClient
        .from('users')
        .select('id, name, email, role')
        .neq('role', 'student');
    return response
        .map<Map<String, dynamic>>(
          (user) => {
            'id': user['id'],
            'name': user['name'],
            'email': user['email'],
            'role': user['role'],
          },
        )
        .toList();
  }

  Future<void> createNotesheet(Notesheet notesheet) async {
    await _supabaseClient.from('notesheets').insert({
      'created_by': notesheet.createdBy,
      'created_at': notesheet.createdAt.toIso8601String(),
      'title': notesheet.title,
      'description': notesheet.description,
      'reviewers': notesheet.reviewers,
      'status': notesheet.status.toString().split('.').last,
      'event_title': notesheet.details?.eventTitle,
      'event_description': notesheet.details?.eventDescription,
      'event_date': notesheet.details?.eventDate?.toIso8601String(),
      'event_venue': notesheet.details?.eventVenue,
      'event_organiser': notesheet.details?.eventOrganiser,
      'event_budget': notesheet.details?.eventBudget,
      'event_requirements': notesheet.details?.eventRequirements,
      'guests': notesheet.details?.guests,
      'miscellaneous': notesheet.details?.miscellanous,
    });
  }

  Future<Notesheet?> getNotesheet(String id) async {
    final response = await _supabaseClient
        .from('notesheets')
        .select('*')
        .eq('id', id)
        .single();

    if (response.isNotEmpty) {
      return Notesheet(
        id: response['id'],
        createdBy: response['created_by'],
        createdAt: DateTime.parse(response['created_at']),
        title: response['title'],
        description: response['description'],
        reviewers: List<String>.from(response['reviewers'] ?? []),
        status: NotesheetStatus.values.firstWhere(
          (e) => e.toString().split('.').last == response['status'],
        ),
        details: NotesheetDetails(
          eventTitle: response['event_title'],
          eventDescription: response['event_description'],
          eventDate: response['event_date'] != null
              ? DateTime.parse(response['event_date'])
              : null,
          eventVenue: response['event_venue'],
          eventOrganiser: response['event_organiser'],
          eventBudget: response['event_budget'],
          eventRequirements: response['event_requirements'],
          guests: List<String>.from(response['guests'] ?? []),
          miscellanous: response['miscellaneous'],
        ),
      );
    }
    return null;
  }

  Future<void> updateNotesheet(Notesheet notesheet) async {
    await _supabaseClient
        .from('notesheets')
        .update({
          'created_by': notesheet.createdBy,
          'created_at': notesheet.createdAt.toIso8601String(),
          'title': notesheet.title,
          'description': notesheet.description,
          'reviewers': notesheet.reviewers,
          'status': notesheet.status.toString().split('.').last,
          'event_title': notesheet.details?.eventTitle,
          'event_description': notesheet.details?.eventDescription,
          'event_date': notesheet.details?.eventDate?.toIso8601String(),
          'event_venue': notesheet.details?.eventVenue,
          'event_organiser': notesheet.details?.eventOrganiser,
          'event_budget': notesheet.details?.eventBudget,
          'event_requirements': notesheet.details?.eventRequirements,
          'guests': notesheet.details?.guests,
          'miscellaneous': notesheet.details?.miscellanous,
        })
        .eq('id', notesheet.id!);
  }

  Future<void> deleteNotesheet(String id) async {
    await _supabaseClient.from('notesheets').delete().eq('id', id);
  }

  Future<List<Notesheet>> getNotesheetsByUser(String createdBy) async {
    final List<dynamic> response = await _supabaseClient
        .from('notesheets')
        .select('*')
        .eq('created_by', createdBy);

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
}
