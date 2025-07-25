import 'package:flutter/material.dart';
import 'package:docket/data/models/user.dart';
import 'package:docket/data/models/review.dart';
import 'package:docket/data/models/notesheet.dart';

import 'package:docket/services/auth/auth_service.dart';
import 'package:docket/services/review/review_service.dart';

import 'package:docket/components/ui/loading.dart';
import 'package:docket/components/review/notesheet_list.dart';
import 'package:docket/components/review/notesheet_details.dart';

class ReviewPage extends StatefulWidget {
  const ReviewPage({super.key});

  @override
  State<ReviewPage> createState() => _ReviewPageState();
}

class _ReviewPageState extends State<ReviewPage> {
  Notesheet? _selectedNotesheet;
  User? _currentReviewer;
  List<Notesheet> _notesheetsToReview = [];
  final AuthService _authService = AuthService();
  final ReviewService _reviewService = ReviewService();
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _initReviewerAndLoadNotesheets();
  }

  Future<void> _initReviewerAndLoadNotesheets() async {
    try {
      final profile = await AuthService().getUserProfile();
      if (!mounted) return;

      if (profile == null) {
        setState(() {
          _loading = false;
        });
        return;
      }

      final reviewer = User(
        id: profile['id'],
        name: profile['name'] ?? '',
        role: Role.values.firstWhere(
          (r) => r.toString().split('.').last == (profile['role'] ?? ''),
          orElse: () => Role.faculty,
        ),
        email: profile['email'] ?? '',
        createdAt: DateTime.now(),
      );

      final notesheets = await _reviewService.getNotesheetsForReviewer(
        reviewer.id,
      );
      if (!mounted) return;

      setState(() {
        _currentReviewer = reviewer;
        _notesheetsToReview = notesheets;
        if (_notesheetsToReview.isNotEmpty) {
          _selectedNotesheet = _notesheetsToReview.firstWhere(
            (ns) =>
                ns.status == NotesheetStatus.pending &&
                ns.reviewers.contains(_currentReviewer!.id),
            orElse: () => _notesheetsToReview.first,
          );
        }
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _loading = false;
      });
      if (mounted) {
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            backgroundColor: Colors.grey[50],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            title: Text(
              'Error',
              style: TextStyle(
                color: Colors.grey[800],
                fontWeight: FontWeight.w600,
              ),
            ),
            content: Text(
              'Failed to load reviewer data: ${e.toString()}',
              style: TextStyle(color: Colors.grey[600]),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                style: TextButton.styleFrom(foregroundColor: Colors.blue[400]),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    }
  }

  void _handleLogout() async {
    try {
      await _authService.logout();
    } catch (e) {
      if (mounted) {
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            backgroundColor: Colors.grey[50],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            title: Text(
              'Logout Failed',
              style: TextStyle(
                color: Colors.grey[800],
                fontWeight: FontWeight.w600,
              ),
            ),
            content: Text(
              e.toString(),
              style: TextStyle(color: Colors.grey[600]),
            ),
          ),
        );
      }
    }
  }

  void _handleNotesheetSelection(Notesheet notesheet) {
    setState(() {
      _selectedNotesheet = notesheet;
    });
  }

  Future<void> _handleReviewSubmission(
    String notesheetId,
    String? comment,
    NotesheetStatus status,
  ) async {
    if (_currentReviewer == null) return;

    await _reviewService.createReview(
      Review(
        reviewerId: _currentReviewer!.id,
        notesheetId: notesheetId,
        comment: comment,
        status: status,
        createdAt: DateTime.now(),
      ),
    );
    if (!mounted) return;

    final notesheets = await _reviewService
        .getNotesheetsForReviewer(_currentReviewer!.id)
        .timeout(Duration(seconds: 3));

    if (!mounted) return;

    setState(() {
      _notesheetsToReview = notesheets;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Notesheet "$notesheetId" ${status == NotesheetStatus.approved ? "approved" : "rejected"}!',
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: status == NotesheetStatus.approved
              ? Colors.grey[600]
              : Colors.orange[400],
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
      _selectedNotesheet = null;
      if (_notesheetsToReview.any(
        (ns) =>
            ns.status == NotesheetStatus.pending &&
            ns.reviewers.contains(_currentReviewer!.id),
      )) {
        _selectedNotesheet = _notesheetsToReview.firstWhere(
          (ns) =>
              ns.status == NotesheetStatus.pending &&
              ns.reviewers.contains(_currentReviewer!.id),
        );
      } else if (_notesheetsToReview.isNotEmpty) {
        _selectedNotesheet = _notesheetsToReview.first;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading || _currentReviewer == null) {
      return const Scaffold(body: Center(child: Loading()));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Notesheet Review',
          style: TextStyle(
            color: Colors.grey[700],
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.grey[50],
        elevation: 1,
        shadowColor: Colors.grey[300],
        surfaceTintColor: Colors.transparent,
        iconTheme: IconThemeData(color: Colors.grey[600]),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 12),
            child: TextButton(
              onPressed: _handleLogout,
              style: TextButton.styleFrom(
                backgroundColor: Colors.orange[50],
                foregroundColor: Colors.grey[700],
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: BorderSide(color: Colors.grey[200]!, width: 0.5),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.logout_outlined,
                    color: Colors.orange[400],
                    size: 18,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Logout',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[700],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      body: Container(
        color: Colors.grey[100],
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Row(
            children: [
              Container(
                width: 350,
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(16.0),
                  border: Border.all(color: Colors.grey[200]!, width: 0.5),
                ),
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        borderRadius: BorderRadius.circular(12.0),
                        border: Border.all(
                          color: Colors.grey[200]!,
                          width: 0.5,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.blue[100],
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  Icons.person_outline,
                                  color: Colors.blue[400],
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'Reviewer',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey[700],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            _currentReviewer!.name,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[800],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _currentReviewer!.email,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Role: ${_currentReviewer!.role.toString().split('.').last.replaceAll('_', ' ')}',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Icon(
                            Icons.assignment_outlined,
                            color: Colors.grey[600],
                            size: 18,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'Notesheets for Review',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[700],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    NotesheetList(
                      notesheets: _notesheetsToReview
                          .where(
                            (ns) => ns.reviewers.contains(_currentReviewer!.id),
                          )
                          .toList(),
                      onNotesheetSelected: _handleNotesheetSelection,
                      selectedNotesheetId: _selectedNotesheet?.id,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 32),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(16.0),
                    border: Border.all(color: Colors.grey[200]!, width: 0.5),
                  ),
                  child: _selectedNotesheet == null
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: Colors.grey[200],
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.folder_open_outlined,
                                  size: 60,
                                  color: Colors.grey[400],
                                ),
                              ),
                              const SizedBox(height: 20),
                              Text(
                                'Select a Notesheet to View Details',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.grey[500],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        )
                      : NotesheetDetail(
                          notesheet: _selectedNotesheet!,
                          onReviewSubmitted: _handleReviewSubmission,
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
