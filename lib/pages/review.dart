import 'package:flutter/material.dart';
import 'package:docket/services/notesheet/notesheet_service.dart';
import 'package:docket/services/review/review_service.dart';
import 'package:docket/services/auth/auth_service.dart';
import 'package:docket/components/review/notesheet_list.dart';
import 'package:docket/components/review/notesheet_detail.dart';

class ReviewPage extends StatefulWidget {
  const ReviewPage({super.key});

  @override
  State<ReviewPage> createState() => _ReviewPageState();
}

class _ReviewPageState extends State<ReviewPage> {
  final NotesheetService _notesheetService = NotesheetService();
  final ReviewService _reviewService = ReviewService();
  final AuthService _authService = AuthService();
  final TextEditingController _commentController = TextEditingController();

  List<Map<String, dynamic>> _notesheets = [];
  List<Map<String, dynamic>> _comments = [];
  Map<String, dynamic>? _selectedNotesheet;
  bool _loading = true;
  String? _userId;
  String? _userRole;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    setState(() => _loading = true);
    final user = _authService.getCurrentUser();
    if (user == null) {
      Navigator.of(context).pushReplacementNamed('/login');
      return;
    }
    _userId = user.id;
    final profile = await _authService.getUserProfile();
    _userRole = profile?['role'];
    if (_userRole == 'student') {
      Navigator.of(context).pushReplacementNamed('/dashboard');
      return;
    }
    final notesheets = await _notesheetService.getNotesheetsForReviewer(
      _userId!,
    );
    setState(() {
      _notesheets = notesheets;
      _loading = false;
    });
  }

  Future<void> _selectNotesheet(String id) async {
    setState(() => _loading = true);
    final n = _notesheets.firstWhere((e) => e['id'].toString() == id);
    final comments = await _reviewService.getCommentsForNotesheet(id);
    setState(() {
      _selectedNotesheet = n;
      _comments = comments;
      _loading = false;
    });
  }

  Future<void> _addComment(String text) async {
    if (_selectedNotesheet == null || text.trim().isEmpty) return;
    await _reviewService.addComment(
      notesheetId: _selectedNotesheet!['id'].toString(),
      commentText: text.trim(),
    );
    _commentController.clear();
    await _selectNotesheet(_selectedNotesheet!['id'].toString());
  }

  Future<void> _changeStatus(String status) async {
    if (_selectedNotesheet == null) return;
    await _reviewService.updateNotesheetStatus(
      notesheetId: _selectedNotesheet!['id'].toString(),
      status: status,
    );
    await _selectNotesheet(_selectedNotesheet!['id'].toString());
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    return Row(
      children: [
        SizedBox(
          width: 300,
          child: NotesheetList(
            notesheets: _notesheets,
            selectedId: _selectedNotesheet?['id']?.toString(),
            onSelect: _selectNotesheet,
          ),
        ),
        const VerticalDivider(width: 1),
        Expanded(
          child: _selectedNotesheet == null
              ? const Center(child: Text('Select a notesheet to review'))
              : NotesheetDetail(
                  notesheet: _selectedNotesheet!,
                  comments: _comments,
                  onAddComment: _addComment,
                  onStatusChange: _changeStatus,
                  commentController: _commentController,
                ),
        ),
      ],
    );
  }
}
