enum NotesheetStatus {
  approved,
  rejected,
  pending,
  draft,
}

class NotesheetDetails {
  String? eventTitle;
  String? eventDescription;
  DateTime? eventDate;
  String? eventVenue;
  String? eventOrganiser;
  String? eventBudget;
  String? eventRequirements;
  List<String>? guests;
  String? miscellanous;

  NotesheetDetails({
    this.eventTitle,
    this.eventDescription,
    this.eventDate,
    this.eventVenue,
    this.eventOrganiser,
    this.eventBudget,
    this.eventRequirements,
    this.guests,
    this.miscellanous,
  });
}

class Notesheet {
  final String? id;
  final String createdBy;
  final DateTime createdAt;
  final String title;
  final String description;
  final List<String> reviewers;
  final NotesheetStatus status;
  final NotesheetDetails? details;

  Notesheet({
    this.id,
    required this.createdAt,
    required this.createdBy,
    required this.title,
    required this.description,
    required this.reviewers,
    required this.status,
    this.details,
  });
}
