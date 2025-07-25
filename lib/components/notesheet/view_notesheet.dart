import 'package:flutter/material.dart';
import 'package:docket/data/models/review.dart';
import 'package:docket/data/models/notesheet.dart';

import 'package:docket/services/notesheet/notesheet_service.dart';
import 'package:docket/services/auth/auth_service.dart';
import 'package:docket/services/review/review_service.dart';

import 'package:docket/components/notesheet/edit_notesheet.dart';

class ViewNotesheet extends StatefulWidget {
  const ViewNotesheet({super.key});

  @override
  State<ViewNotesheet> createState() => _ViewNotesheetState();
}

class _ViewNotesheetState extends State<ViewNotesheet> {
  Notesheet? _selectedNotesheet;
  List<Notesheet> _notesheets = [];
  bool _isLoading = true;
  String? _errorMessage;
  final _notesheetService = NotesheetService();
  final _authService = AuthService();
  final ReviewService _reviewService = ReviewService();

  @override
  void initState() {
    super.initState();
    _fetchNotesheets();
  }

  void _handleNotesheetSelection(Notesheet notesheet) {
    setState(() {
      _selectedNotesheet = notesheet;
    });
  }

  Future<void> _fetchNotesheets() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final user = _authService.getCurrentUser();
      if (user == null) {
        _errorMessage = 'User not logged in.';
        _notesheets = [];
      } else {
        final notesheets = await _notesheetService.getNotesheetsByUser(user.id);
        _notesheets = notesheets;
        if (_notesheets.isNotEmpty) {
          _selectedNotesheet = _notesheets.first;
        }
      }
    } catch (e) {
      _errorMessage = 'Failed to load notesheets.';
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _confirmAndDeleteNotesheet(String id) async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Deletion'),
          content: const Text(
            'Are you sure you want to delete this notesheet? This action cannot be undone.',
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      try {
        await _notesheetService.deleteNotesheet(id);
        _fetchNotesheets();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Notesheet deleted successfully!')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to delete notesheet: $e')),
          );
        }
      }
    }
  }

  void _handleEditNotesheet(Notesheet notesheet) async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => EditNotesheet(
          notesheetId: notesheet.id!,
          initialNotesheet: notesheet,
        ),
      ),
    );
    if (result == true) {
      _fetchNotesheets();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('View Notesheets'),
        backgroundColor: Colors.grey[50],
        foregroundColor: Colors.grey[800],
        elevation: 0,
      ),
      body: Container(
        color: Colors.grey[50],
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _errorMessage != null
              ? Center(child: Text(_errorMessage!))
              : Row(
                  children: [
                    Container(
                      width: 350,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16.0),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey[200]!,
                            spreadRadius: 1,
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Notesheets',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[800],
                            ),
                          ),
                          const SizedBox(height: 16),
                          Expanded(
                            child: _notesheets.isEmpty
                                ? const Center(
                                    child: Text('No notesheets found.'),
                                  )
                                : ListView.builder(
                                    itemCount: _notesheets.length,
                                    itemBuilder: (context, index) {
                                      final notesheet = _notesheets[index];
                                      final isSelected =
                                          notesheet.id ==
                                          _selectedNotesheet?.id;
                                      return GestureDetector(
                                        onTap: () => _handleNotesheetSelection(
                                          notesheet,
                                        ),
                                        child: Card(
                                          margin: const EdgeInsets.symmetric(
                                            vertical: 8.0,
                                          ),
                                          elevation: isSelected ? 4 : 1,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              12.0,
                                            ),
                                            side: isSelected
                                                ? BorderSide(
                                                    color: Colors.blue[400]!,
                                                    width: 2,
                                                  )
                                                : BorderSide.none,
                                          ),
                                          color: isSelected
                                              ? Colors.blue[50]
                                              : Colors.white,
                                          child: Padding(
                                            padding: const EdgeInsets.all(16.0),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  notesheet.title,
                                                  style: TextStyle(
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.w600,
                                                    color: Colors.grey[800],
                                                  ),
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                                const SizedBox(height: 8),
                                                Text(
                                                  notesheet.description,
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    color: Colors.grey[600],
                                                  ),
                                                  maxLines: 2,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                                const SizedBox(height: 8),
                                                Align(
                                                  alignment:
                                                      Alignment.bottomRight,
                                                  child: Chip(
                                                    label: Text(
                                                      notesheet.status
                                                          .toString()
                                                          .split('.')
                                                          .last
                                                          .toUpperCase(),
                                                      style: const TextStyle(
                                                        fontSize: 12,
                                                      ),
                                                    ),
                                                    side: BorderSide.none,
                                                    backgroundColor:
                                                        notesheet.status ==
                                                            NotesheetStatus
                                                                .pending
                                                        ? Colors.orange[100]
                                                        : notesheet.status ==
                                                              NotesheetStatus
                                                                  .approved
                                                        ? Colors.green[100]
                                                        : notesheet.status ==
                                                              NotesheetStatus
                                                                  .rejected
                                                        ? Colors.red[100]
                                                        : Colors.grey[100],
                                                    labelStyle: TextStyle(
                                                      color:
                                                          notesheet.status ==
                                                              NotesheetStatus
                                                                  .pending
                                                          ? Colors.orange[800]
                                                          : notesheet.status ==
                                                                NotesheetStatus
                                                                    .approved
                                                          ? Colors.green[800]
                                                          : notesheet.status ==
                                                                NotesheetStatus
                                                                    .rejected
                                                          ? Colors.red[800]
                                                          : Colors.grey[800],
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 32),
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16.0),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey[200]!,
                              spreadRadius: 1,
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: _selectedNotesheet == null
                            ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.info_outline,
                                      size: 60,
                                      color: Colors.grey[300],
                                    ),
                                    const SizedBox(height: 20),
                                    Text(
                                      'Select a notesheet to view details',
                                      style: TextStyle(
                                        fontSize: 18,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : _NotesheetDetailView(
                                notesheet: _selectedNotesheet!,
                                onDelete: _confirmAndDeleteNotesheet,
                                onEdit: _handleEditNotesheet,
                                reviewService: _reviewService,
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

class _NotesheetDetailView extends StatelessWidget {
  final Notesheet notesheet;
  final Function(String) onDelete;
  final Function(Notesheet) onEdit;
  final ReviewService reviewService;

  const _NotesheetDetailView({
    required this.notesheet,
    required this.onDelete,
    required this.onEdit,
    required this.reviewService,
  });

  @override
  Widget build(BuildContext context) {
    if (notesheet.details == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.info_outline, size: 60, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No Notesheet Details Available',
              style: TextStyle(fontSize: 18, color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }
    final details = notesheet.details!;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      notesheet.title,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: Colors.grey[800],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Created by: ${notesheet.createdBy} on ${notesheet.createdAt.toLocal().toString().split(' ')[0]}',
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Column(
                children: [
                  if (notesheet.status != NotesheetStatus.approved)
                    ElevatedButton.icon(
                      onPressed: () => onEdit(notesheet),
                      icon: const Icon(Icons.edit, size: 18),
                      label: const Text('Edit', style: TextStyle(fontSize: 12)),
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.blue[400],
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  const SizedBox(height: 8),
                  ElevatedButton.icon(
                    onPressed: () => onDelete(notesheet.id!),
                    icon: const Icon(Icons.delete, size: 18),
                    label: const Text('Delete', style: TextStyle(fontSize: 12)),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.red[400],
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildDetailSection('Event Details', [
            _buildDetailRow('Description', details.eventDescription),
            _buildDetailRow('Venue', details.eventVenue),
            _buildDetailRow('Organiser', details.eventOrganiser),
            _buildDetailRow(
              'Date',
              details.eventDate != null
                  ? details.eventDate!.toLocal().toString().split(' ')[0]
                  : 'N/A',
            ),
          ]),
          _buildDetailSection('Budget & Guests', [
            _buildDetailRow('Budget', details.eventBudget),
            _buildDetailRow(
              'Guests',
              details.guests != null && details.guests!.isNotEmpty
                  ? details.guests!.join(', ')
                  : 'No guests',
            ),
          ]),
          _buildDetailSection('Requirements & Reviewers', [
            _buildDetailRow('Requirements', details.eventRequirements),
            _buildDetailRow(
              'Reviewers',
              notesheet.reviewers.isNotEmpty
                  ? notesheet.reviewers.join(', ')
                  : 'No reviewers assigned',
            ),
          ]),
          const SizedBox(height: 24),
          _buildDetailSection('Reviews', [
            FutureBuilder<List<Review>>(
              future: reviewService.getReviewsForNotesheet(notesheet.id!),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(
                    child: Text('Error loading reviews: ${snapshot.error}'),
                  );
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No reviews yet.'));
                } else {
                  final reviews = snapshot.data!;
                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: reviews.length,
                    itemBuilder: (context, index) {
                      final review = reviews[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 8.0),
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Reviewer: ${review.reviewerId}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: Colors.grey[700],
                                    ),
                                  ),
                                  Chip(
                                    label: Text(
                                      review.status
                                          .toString()
                                          .split('.')
                                          .last
                                          .toUpperCase(),
                                      style: const TextStyle(fontSize: 10),
                                    ),
                                    backgroundColor:
                                        review.status ==
                                            NotesheetStatus.approved
                                        ? Colors.green[100]
                                        : review.status ==
                                              NotesheetStatus.rejected
                                        ? Colors.red[100]
                                        : Colors.orange[100],
                                    labelStyle: TextStyle(
                                      color:
                                          review.status ==
                                              NotesheetStatus.approved
                                          ? Colors.green[800]
                                          : review.status ==
                                                NotesheetStatus.rejected
                                          ? Colors.red[800]
                                          : Colors.orange[800],
                                    ),
                                    side: BorderSide.none,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                (review.comment != null &&
                                        review.comment!.isNotEmpty)
                                    ? review.comment!
                                    : 'No comment provided.',
                                style: TextStyle(color: Colors.grey[800]),
                              ),
                              const SizedBox(height: 8),
                              Align(
                                alignment: Alignment.bottomRight,
                                child: Text(
                                  'Reviewed on: ${review.createdAt.toLocal().toString().split(' ')[0]}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[500],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                }
              },
            ),
          ]),
        ],
      ),
    );
  }

  Widget _buildDetailSection(String title, List<Widget> children) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[25],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String? value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            child: Text(
              value ?? 'N/A',
              style: TextStyle(color: Colors.grey[800]),
            ),
          ),
        ),
      ],
    );
  }
}
