import 'notesheet.dart';

class Review {
  final String? id;
  final String reviewerId;
  final String notesheetId;
  final String? comment;
  final NotesheetStatus status;
  final DateTime createdAt;

  Review({
    this.id,
    required this.reviewerId,
    required this.notesheetId,
    this.comment,
    required this.status,
    required this.createdAt,
  });
}
