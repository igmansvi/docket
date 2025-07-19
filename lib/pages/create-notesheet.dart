import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/notesheet/notesheet_service.dart';

class CreateNotesheetPage extends StatefulWidget {
  const CreateNotesheetPage({super.key});

  @override
  State<CreateNotesheetPage> createState() => _CreateNotesheetPageState();
}

class _CreateNotesheetPageState extends State<CreateNotesheetPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _eventTitleController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _venueController = TextEditingController();
  final TextEditingController _guestsController = TextEditingController();
  final TextEditingController _adminController = TextEditingController();
  final TextEditingController _clubController = TextEditingController();
  final TextEditingController _budgetController = TextEditingController();
  final TextEditingController _expectedController = TextEditingController();
  final TextEditingController _requirementsController = TextEditingController();
  // final TextEditingController _reviewersController = TextEditingController();
  final TextEditingController _attachmentsController = TextEditingController();

  String? _selectedVenue;
  String? _selectedClub;
  List<String> _reviewers = [];
  DateTime? _selectedDate;

  List<Map<String, dynamic>> _allReviewers = [];
  bool _loadingReviewers = false;

  @override
  void initState() {
    super.initState();
    _fetchReviewers();
  }

  Future<void> _fetchReviewers() async {
    setState(() {
      _loadingReviewers = true;
    });
    final client = Supabase.instance.client;
    final response = await client.from('users').select('id, name, role');
    setState(() {
      _allReviewers = List<Map<String, dynamic>>.from(response);
      _loadingReviewers = false;
    });
  }

  Future<void> _submitNotesheet({required String status}) async {
    final service = NotesheetService();
    await service.createNotesheet(
      title: _eventTitleController.text,
      eventDate: _selectedDate ?? DateTime.now(),
      venue: _selectedVenue ?? '',
      venueDetails: _venueController.text,
      guests: _guestsController.text,
      clubName: _selectedClub ?? '',
      clubDetails: _clubController.text,
      estimatedBudget: double.tryParse(_budgetController.text),
      expectedGathering: int.tryParse(_expectedController.text),
      requirements: _requirementsController.text,
      reviewerIds: _reviewers,
      attachmentUrls: _attachmentsController.text.isNotEmpty
          ? _attachmentsController.text.split(',')
          : [],
    );
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[50],
      appBar: AppBar(
        backgroundColor: Colors.blue[900],
        title: const Text('Create Notesheet'),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 900),
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(color: Colors.blue.withOpacity(0.08), blurRadius: 24),
              ],
            ),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    'Create Notesheet',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(height: 32),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Event Details',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: Colors.blue,
                              ),
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _eventTitleController,
                              decoration: const InputDecoration(
                                labelText: 'Event Title',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.event),
                              ),
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _dateController,
                              readOnly: true,
                              decoration: InputDecoration(
                                labelText: 'Event Date',
                                border: const OutlineInputBorder(),
                                prefixIcon: const Icon(Icons.calendar_today),
                                suffixIcon: IconButton(
                                  icon: const Icon(Icons.date_range),
                                  onPressed: () async {
                                    final picked = await showDatePicker(
                                      context: context,
                                      initialDate: DateTime.now(),
                                      firstDate: DateTime(2020),
                                      lastDate: DateTime(2100),
                                    );
                                    if (picked != null) {
                                      setState(() {
                                        _selectedDate = picked;
                                        _dateController.text =
                                            "${picked.day}/${picked.month}/${picked.year}";
                                      });
                                    }
                                  },
                                ),
                              ),
                            ),
                            if (_selectedDate != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Text(
                                  "Selected Date: ${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}",
                                  style: const TextStyle(
                                    color: Colors.blueGrey,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            const SizedBox(height: 16),
                            DropdownButtonFormField<String>(
                              value: _selectedVenue,
                              items:
                                  [
                                        'Auditorium',
                                        'Seminar Hall',
                                        'Ground',
                                        'Other',
                                      ]
                                      .map(
                                        (v) => DropdownMenuItem(
                                          value: v,
                                          child: Text(v),
                                        ),
                                      )
                                      .toList(),
                              onChanged: (v) {
                                setState(() {
                                  _selectedVenue = v;
                                  _venueController.text = v ?? '';
                                });
                              },
                              decoration: const InputDecoration(
                                labelText: 'Venue',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.location_on_outlined),
                              ),
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _venueController,
                              decoration: const InputDecoration(
                                labelText: 'Venue Details',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.info_outline),
                              ),
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _guestsController,
                              decoration: const InputDecoration(
                                labelText: 'Guest Speakers',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.people_outline),
                              ),
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _adminController,
                              decoration: const InputDecoration(
                                labelText: 'Administrator',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(
                                  Icons.admin_panel_settings_outlined,
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            DropdownButtonFormField<String>(
                              value: _selectedClub,
                              items:
                                  [
                                        'Coding Club',
                                        'Music Club',
                                        'Sports Club',
                                        'Other',
                                      ]
                                      .map(
                                        (v) => DropdownMenuItem(
                                          value: v,
                                          child: Text(v),
                                        ),
                                      )
                                      .toList(),
                              onChanged: (v) {
                                setState(() {
                                  _selectedClub = v;
                                  _clubController.text = v ?? '';
                                });
                              },
                              decoration: const InputDecoration(
                                labelText: 'Organizing Club',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.group_work_outlined),
                              ),
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _clubController,
                              decoration: const InputDecoration(
                                labelText: 'Club Details',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.info_outline),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 32),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Budget & Gathering',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: Colors.blue,
                              ),
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _budgetController,
                              decoration: const InputDecoration(
                                labelText: 'Budget & Expenses',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.attach_money),
                              ),
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _expectedController,
                              decoration: const InputDecoration(
                                labelText: 'Expected Students / Gathering',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.groups),
                              ),
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _requirementsController,
                              maxLines: 3,
                              decoration: const InputDecoration(
                                labelText:
                                    'Requirements (equipment, staff, etc.)',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.list_alt_outlined),
                              ),
                            ),
                            const SizedBox(height: 16),
                            _loadingReviewers
                                ? const CircularProgressIndicator()
                                : DropdownButtonFormField<String>(
                                    isExpanded: true,
                                    items: _allReviewers
                                        .map(
                                          (r) => DropdownMenuItem<String>(
                                            value: r['id'] as String,
                                            child: Text(r['name'] ?? r['id']),
                                          ),
                                        )
                                        .toList(),
                                    onChanged: (val) {
                                      if (val != null &&
                                          !_reviewers.contains(val)) {
                                        setState(() {
                                          _reviewers.add(val);
                                        });
                                      }
                                    },
                                    decoration: const InputDecoration(
                                      labelText: 'Add Reviewer',
                                      border: OutlineInputBorder(),
                                      prefixIcon: Icon(
                                        Icons.verified_user_outlined,
                                      ),
                                    ),
                                  ),
                            if (_reviewers.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Wrap(
                                  spacing: 8,
                                  children: _reviewers.map((id) {
                                    final user = _allReviewers.firstWhere(
                                      (u) => u['id'] == id,
                                      orElse: () => {'name': id},
                                    );
                                    return Chip(
                                      label: Text(user['name'] ?? id),
                                      onDeleted: () {
                                        setState(() {
                                          _reviewers.remove(id);
                                        });
                                      },
                                    );
                                  }).toList(),
                                ),
                              ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _attachmentsController,
                              decoration: const InputDecoration(
                                labelText: 'Attachments (links or file names)',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.attach_file),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      OutlinedButton(
                        onPressed: () {
                          _submitNotesheet(status: 'draft');
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.blue[700],
                          side: BorderSide(color: Colors.blue[700]!),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 16,
                          ),
                        ),
                        child: const Text('Save Draft'),
                      ),
                      const SizedBox(width: 16),
                      ElevatedButton(
                        onPressed: () {
                          _submitNotesheet(status: 'pending_level_1');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue[700],
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 16,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text('Submit for Approval'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
