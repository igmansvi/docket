import 'package:flutter/material.dart';
import 'package:docket/data/models/notesheet.dart';

class NotesheetDetail extends StatefulWidget {
  final Notesheet notesheet;
  final Function(String notesheetId, String? comment, NotesheetStatus status)
  onReviewSubmitted;

  const NotesheetDetail({
    super.key,
    required this.notesheet,
    required this.onReviewSubmitted,
  });

  @override
  State<NotesheetDetail> createState() => _NotesheetDetailState();
}

class _NotesheetDetailState extends State<NotesheetDetail> {
  final TextEditingController _commentController = TextEditingController();

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.notesheet.details == null) {
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

    final details = widget.notesheet.details!;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.notesheet.title,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Created by: ${widget.notesheet.createdBy} on ${widget.notesheet.createdAt.toLocal().toString().split(' ')[0]}',
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
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
              widget.notesheet.reviewers.isNotEmpty
                  ? widget.notesheet.reviewers.join(', ')
                  : 'No reviewers assigned',
            ),
          ]),
          const SizedBox(height: 30),
          Text(
            'Add Comment:',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _commentController,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: 'Enter your comments here...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.0),
                borderSide: BorderSide(color: Colors.grey[200]!),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.0),
                borderSide: BorderSide(color: Colors.grey[200]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.0),
                borderSide: BorderSide(color: Colors.blue[400]!),
              ),
              filled: true,
              fillColor: Colors.grey[50],
              contentPadding: const EdgeInsets.all(16),
            ),
          ),
          const SizedBox(height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  widget.onReviewSubmitted(
                    widget.notesheet.id!,
                    _commentController.text.trim().isEmpty
                        ? null
                        : _commentController.text.trim(),
                    NotesheetStatus.rejected,
                  );
                },
                icon: const Icon(Icons.close, size: 20),
                label: const Text(
                  'Reject',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red[600],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                ),
              ),
              const SizedBox(width: 20),
              ElevatedButton.icon(
                onPressed: () {
                  widget.onReviewSubmitted(
                    widget.notesheet.id!,
                    _commentController.text.trim().isEmpty
                        ? null
                        : _commentController.text.trim(),
                    NotesheetStatus.approved,
                  );
                },
                icon: const Icon(Icons.check, size: 20),
                label: const Text(
                  'Approve',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[600],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                ),
              ),
            ],
          ),
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
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value ?? 'N/A',
              style: TextStyle(color: Colors.grey[800]),
            ),
          ),
        ],
      ),
    );
  }
}
