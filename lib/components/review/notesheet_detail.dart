import 'package:flutter/material.dart';

class NotesheetDetail extends StatelessWidget {
  final Map<String, dynamic> notesheet;
  final List<Map<String, dynamic>> comments;
  final void Function(String) onAddComment;
  final void Function(String) onStatusChange;
  final TextEditingController commentController;

  const NotesheetDetail({
    super.key,
    required this.notesheet,
    required this.comments,
    required this.onAddComment,
    required this.onStatusChange,
    required this.commentController,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            notesheet['title'] ?? 'Untitled',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text('Status: ${notesheet['status'] ?? 'Unknown'}'),
          const SizedBox(height: 16),
          Text(
            'Comments:',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          ...comments.map(
            (c) => ListTile(
              title: Text(c['comment_text'] ?? ''),
              subtitle: Text(c['created_at'] ?? ''),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: commentController,
                  decoration: const InputDecoration(hintText: 'Add a comment'),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.send),
                onPressed: () => onAddComment(commentController.text),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              ElevatedButton(
                onPressed: () => onStatusChange('approved'),
                child: const Text('Approve'),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () => onStatusChange('rejected'),
                child: const Text('Reject'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
