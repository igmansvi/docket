enum Role { student, faculty, coordinator, head_of_department }

class User {
  final String id;
  final String name;
  final Role role;
  final String email;
  final DateTime createdAt;

  User({
    required this.id,
    required this.name,
    required this.role,
    required this.email,
    required this.createdAt,
  });
}
