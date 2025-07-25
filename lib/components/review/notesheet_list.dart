import 'package:flutter/material.dart';
import 'package:docket/data/models/notesheet.dart';

class NotesheetList extends StatefulWidget {
  final List<Notesheet> notesheets;
  final Function(Notesheet) onNotesheetSelected;
  final String? selectedNotesheetId;

  const NotesheetList({
    super.key,
    required this.notesheets,
    required this.onNotesheetSelected,
    this.selectedNotesheetId,
  });

  @override
  State<NotesheetList> createState() => _NotesheetListState();
}

class _NotesheetListState extends State<NotesheetList> {
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ListView.builder(
        itemCount: widget.notesheets.length,
        itemBuilder: (context, index) {
          final notesheet = widget.notesheets[index];
          final isSelected = notesheet.id == widget.selectedNotesheetId;

          return GestureDetector(
            onTap: () => widget.onNotesheetSelected(notesheet),
            child: Card(
              margin: const EdgeInsets.symmetric(vertical: 8.0),
              elevation: isSelected ? 4 : 1,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
                side: isSelected
                    ? BorderSide(color: Colors.blue[400]!, width: 2)
                    : BorderSide.none,
              ),
              color: isSelected ? Colors.blue[50] : Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      notesheet.title,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[800],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      notesheet.description,
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.bottomRight,
                      child: Chip(
                        label: Text(
                          notesheet.status
                              .toString()
                              .split('.')
                              .last
                              .toUpperCase(),
                          style: const TextStyle(fontSize: 12),
                        ),
                        backgroundColor:
                            notesheet.status == NotesheetStatus.pending
                            ? Colors.orange[100]
                            : notesheet.status == NotesheetStatus.approved
                            ? Colors.green[100]
                            : notesheet.status == NotesheetStatus.rejected
                            ? Colors.red[100]
                            : Colors.grey[100],
                        labelStyle: TextStyle(
                          color: notesheet.status == NotesheetStatus.pending
                              ? Colors.orange[800]
                              : notesheet.status == NotesheetStatus.approved
                              ? Colors.green[800]
                              : notesheet.status == NotesheetStatus.rejected
                              ? Colors.red[800]
                              : Colors.grey[800],
                        ),
                        side: BorderSide.none,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
