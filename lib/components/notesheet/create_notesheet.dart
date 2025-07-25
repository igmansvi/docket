import 'package:flutter/material.dart';
import 'package:docket/data/models/notesheet.dart';

import 'package:docket/services/auth/auth_service.dart';
import 'package:docket/services/notesheet/notesheet_service.dart';

class CreateNotesheet extends StatefulWidget {
  const CreateNotesheet({super.key});

  @override
  State<CreateNotesheet> createState() => _CreateNotesheetState();
}

class _CreateNotesheetState extends State<CreateNotesheet> {
  final NotesheetDetails _notesheetDetails = NotesheetDetails();
  final NotesheetService _notesheetService = NotesheetService();
  final AuthService _authService = AuthService();
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _reviewersController = TextEditingController();
  final _guestsController = TextEditingController();

  final List<String> _reviewers = [];
  List<Map<String, dynamic>> _availableReviewers = [];
  bool _isLoading = false;
  String? _currentUserId;

  final List<String> _progressCategories = [
    'Basic Info',
    'Event Details',
    'Date & Time',
    'Budget & Guests',
    'Reviewers',
    'Miscellaneous',
  ];

  int get _completedCategories {
    int count = 0;

    if (_titleController.text.isNotEmpty &&
        _descriptionController.text.isNotEmpty) {
      count++;
    }

    if (_notesheetDetails.eventTitle != null &&
        _notesheetDetails.eventTitle!.isNotEmpty &&
        _notesheetDetails.eventDescription != null &&
        _notesheetDetails.eventDescription!.isNotEmpty &&
        _notesheetDetails.eventVenue != null &&
        _notesheetDetails.eventVenue!.isNotEmpty &&
        _notesheetDetails.eventOrganiser != null &&
        _notesheetDetails.eventOrganiser!.isNotEmpty) {
      count++;
    }

    if (_notesheetDetails.eventDate != null) {
      count++;
    }

    if (_notesheetDetails.eventBudget != null &&
        _notesheetDetails.eventBudget!.isNotEmpty &&
        _notesheetDetails.guests != null &&
        _notesheetDetails.guests!.isNotEmpty) {
      count++;
    }

    if (_reviewers.isNotEmpty) {
      count++;
    }

    if (_notesheetDetails.eventRequirements != null &&
        _notesheetDetails.eventRequirements!.isNotEmpty) {
      count++;
    }

    return count;
  }

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    final user = _authService.getCurrentUser();
    if (user != null) {
      _currentUserId = user.id;
      await _loadReviewers();
    }
  }

  Future<void> _loadReviewers() async {
    try {
      final reviewers = await _notesheetService.getReviewers();
      setState(() {
        _availableReviewers = reviewers;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load reviewers: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _updateProgress() {
    setState(() {});
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _notesheetDetails.eventDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _notesheetDetails.eventDate) {
      setState(() {
        _notesheetDetails.eventDate = picked;
        _updateProgress();
      });
    }
  }

  void _addReviewer(Map<String, dynamic> reviewer) {
    if (!_reviewers.contains(reviewer['id'])) {
      setState(() {
        _reviewers.add(reviewer['id']);
        _reviewersController.clear();
        _updateProgress();
      });
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${reviewer['name']} is already added.'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  void _addGuest() {
    if (_guestsController.text.isNotEmpty) {
      setState(() {
        _notesheetDetails.guests ??= [];
        _notesheetDetails.guests!.add(_guestsController.text);
        _guestsController.clear();
        _updateProgress();
      });
    }
  }

  Future<void> _saveDraft() async {
    if (_currentUserId == null) return;

    setState(() => _isLoading = true);

    try {
      final notesheet = Notesheet(
        createdBy: _currentUserId!,
        createdAt: DateTime.now(),
        title: _titleController.text,
        description: _descriptionController.text,
        reviewers: _reviewers,
        status: NotesheetStatus.draft,
        details: _notesheetDetails,
      );

      await _notesheetService.createNotesheet(notesheet);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Notesheet saved as draft successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save draft: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _submitForReview() async {
    if (_currentUserId == null || !_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final notesheet = Notesheet(
        createdBy: _currentUserId!,
        createdAt: DateTime.now(),
        title: _titleController.text,
        description: _descriptionController.text,
        reviewers: _reviewers,
        status: NotesheetStatus.pending,
        details: _notesheetDetails,
      );

      await _notesheetService.createNotesheet(notesheet);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Notesheet submitted for review successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to submit notesheet: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Notesheet'),
        backgroundColor: Colors.grey[50],
        foregroundColor: Colors.grey[800],
        elevation: 0,
      ),
      body: Container(
        color: Colors.grey[50],
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Row(
            children: [
              Container(
                width: 280,
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
                      'Progress',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[800],
                      ),
                    ),
                    const SizedBox(height: 24),
                    ...List.generate(_progressCategories.length, (index) {
                      bool isCompleted = index < _completedCategories;
                      bool isActive = index == _completedCategories;

                      return _buildProgressTile(
                        _progressCategories[index],
                        isCompleted,
                        isActive,
                        index,
                      );
                    }),
                    const Spacer(),
                    SizedBox(
                      height: 120,
                      child: Center(
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            SizedBox(
                              width: 80,
                              height: 80,
                              child: CircularProgressIndicator(
                                value:
                                    _completedCategories /
                                    _progressCategories.length,
                                strokeWidth: 6,
                                backgroundColor: Colors.grey[200],
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.green[500]!,
                                ),
                              ),
                            ),
                            Text(
                              '${(_completedCategories / _progressCategories.length * 100).toStringAsFixed(0)}%',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey[700],
                              ),
                            ),
                          ],
                        ),
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
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(32.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Create New Notesheet',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w700,
                              color: Colors.grey[800],
                            ),
                          ),
                          Text(
                            'Fill in the details to create your notesheet',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 40),

                          _buildSectionContainer(
                            'Basic Information',
                            Icons.info_outline,
                            [
                              _buildTextField(
                                'Notesheet Title',
                                'Enter notesheet title',
                                controller: _titleController,
                                onChanged: (value) => _updateProgress(),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter a title';
                                  }
                                  return null;
                                },
                              ),
                              _buildTextField(
                                'Description',
                                'Enter notesheet description',
                                controller: _descriptionController,
                                onChanged: (value) => _updateProgress(),
                                maxLines: 3,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter a description';
                                  }
                                  return null;
                                },
                              ),
                            ],
                          ),

                          _buildSectionContainer(
                            'Event Details',
                            Icons.event_note,
                            [
                              _buildTextField(
                                'Event Title',
                                'Enter event title',
                                onChanged: (value) {
                                  _notesheetDetails.eventTitle = value;
                                  _updateProgress();
                                },
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter event title';
                                  }
                                  return null;
                                },
                              ),
                              _buildTextField(
                                'Event Description',
                                'Describe the event',
                                onChanged: (value) {
                                  _notesheetDetails.eventDescription = value;
                                  _updateProgress();
                                },
                                maxLines: 3,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter event description';
                                  }
                                  return null;
                                },
                              ),
                              _buildTextField(
                                'Event Venue',
                                'Enter venue location',
                                onChanged: (value) {
                                  _notesheetDetails.eventVenue = value;
                                  _updateProgress();
                                },
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter event venue';
                                  }
                                  return null;
                                },
                              ),
                              _buildTextField(
                                'Event Organiser',
                                'Enter organiser name',
                                onChanged: (value) {
                                  _notesheetDetails.eventOrganiser = value;
                                  _updateProgress();
                                },
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter organiser name';
                                  }
                                  return null;
                                },
                              ),
                            ],
                          ),

                          _buildSectionContainer('Date & Time', Icons.schedule, [
                            GestureDetector(
                              onTap: () => _selectDate(context),
                              child: Container(
                                padding: const EdgeInsets.all(16.0),
                                decoration: BoxDecoration(
                                  color: Colors.grey[50],
                                  borderRadius: BorderRadius.circular(12.0),
                                  border: Border.all(color: Colors.grey[200]!),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.calendar_today,
                                      color: Colors.grey[600],
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      _notesheetDetails.eventDate != null
                                          ? '${_notesheetDetails.eventDate!.day}/${_notesheetDetails.eventDate!.month}/${_notesheetDetails.eventDate!.year}'
                                          : 'Select event date',
                                      style: TextStyle(
                                        color:
                                            _notesheetDetails.eventDate != null
                                            ? Colors.grey[800]
                                            : Colors.grey[500],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ]),

                          _buildSectionContainer(
                            'Budget & Guests',
                            Icons.group,
                            [
                              _buildTextField(
                                'Event Budget',
                                'Enter budget amount',
                                onChanged: (value) {
                                  _notesheetDetails.eventBudget = value;
                                  _updateProgress();
                                },
                                keyboardType: TextInputType.number,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter budget amount';
                                  }
                                  return null;
                                },
                              ),
                              Row(
                                children: [
                                  Expanded(
                                    child: TextFormField(
                                      controller: _guestsController,
                                      decoration: InputDecoration(
                                        labelText: 'Add Guest',
                                        hintText: 'Enter guest name',
                                        labelStyle: TextStyle(
                                          color: Colors.grey.shade500,
                                        ),
                                        hintStyle: TextStyle(
                                          color: Colors.grey.shade500,
                                        ),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            12.0,
                                          ),
                                          borderSide: BorderSide(
                                            color: Colors.grey[200]!,
                                          ),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            12.0,
                                          ),
                                          borderSide: BorderSide(
                                            color: Colors.grey[200]!,
                                          ),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            12.0,
                                          ),
                                          borderSide: BorderSide(
                                            color: Colors.blue[400]!,
                                          ),
                                        ),
                                        filled: true,
                                        fillColor: Colors.grey[50],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  ElevatedButton(
                                    onPressed: _addGuest,
                                    style: ElevatedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 20,
                                      ),
                                      backgroundColor: Colors.blue[600],
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                          12.0,
                                        ),
                                      ),
                                    ),
                                    child: const Text('Add'),
                                  ),
                                ],
                              ),
                              if (_notesheetDetails.guests != null &&
                                  _notesheetDetails.guests!.isNotEmpty)
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: _notesheetDetails.guests!
                                      .map(
                                        (guest) => Chip(
                                          label: Text(guest),
                                          backgroundColor: Colors.blue[50],
                                          deleteIcon: const Icon(
                                            Icons.close,
                                            size: 18,
                                          ),
                                          side: BorderSide.none,
                                          onDeleted: () {
                                            setState(() {
                                              _notesheetDetails.guests!.remove(
                                                guest,
                                              );
                                              _updateProgress();
                                            });
                                          },
                                        ),
                                      )
                                      .toList(),
                                ),
                            ],
                          ),

                          _buildSectionContainer(
                            'Reviewers',
                            Icons.people_outline,
                            [
                              Autocomplete<Map<String, dynamic>>(
                                displayStringForOption: (option) =>
                                    '${option['name']} (${option['email']})',
                                optionsBuilder:
                                    (TextEditingValue textEditingValue) {
                                      if (textEditingValue.text == '') {
                                        return const Iterable<
                                          Map<String, dynamic>
                                        >.empty();
                                      }
                                      return _availableReviewers.where((
                                        reviewer,
                                      ) {
                                        final name =
                                            (reviewer['name'] as String)
                                                .toLowerCase();
                                        final email =
                                            (reviewer['email'] as String)
                                                .toLowerCase();
                                        final input = textEditingValue.text
                                            .toLowerCase();
                                        return name.contains(input) ||
                                            email.contains(input);
                                      });
                                    },
                                onSelected: (Map<String, dynamic> selection) {
                                  _addReviewer(selection);
                                },
                                fieldViewBuilder:
                                    (
                                      BuildContext context,
                                      TextEditingController
                                      textEditingController,
                                      FocusNode focusNode,
                                      VoidCallback onFieldSubmitted,
                                    ) {
                                      _reviewersController.text =
                                          textEditingController.text;
                                      return TextFormField(
                                        controller: textEditingController,
                                        focusNode: focusNode,
                                        decoration: InputDecoration(
                                          labelText: 'Add Reviewer',
                                          hintText:
                                              'Type to search for reviewers',
                                          labelStyle: TextStyle(
                                            color: Colors.grey.shade500,
                                          ),
                                          hintStyle: TextStyle(
                                            color: Colors.grey.shade500,
                                          ),
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                              12.0,
                                            ),
                                            borderSide: BorderSide(
                                              color: Colors.grey[200]!,
                                            ),
                                          ),
                                          enabledBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                              12.0,
                                            ),
                                            borderSide: BorderSide(
                                              color: Colors.grey[200]!,
                                            ),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                              12.0,
                                            ),
                                            borderSide: BorderSide(
                                              color: Colors.blue[400]!,
                                            ),
                                          ),
                                          filled: true,
                                          fillColor: Colors.grey[50],
                                        ),
                                        onFieldSubmitted: (String value) {},
                                      );
                                    },
                                optionsViewBuilder:
                                    (
                                      BuildContext context,
                                      AutocompleteOnSelected<
                                        Map<String, dynamic>
                                      >
                                      onSelected,
                                      Iterable<Map<String, dynamic>> options,
                                    ) {
                                      return Align(
                                        alignment: Alignment.topLeft,
                                        child: Material(
                                          elevation: 4.0,
                                          child: SizedBox(
                                            height: 200.0,
                                            child: ListView.builder(
                                              padding: EdgeInsets.zero,
                                              itemCount: options.length,
                                              itemBuilder:
                                                  (
                                                    BuildContext context,
                                                    int index,
                                                  ) {
                                                    final option = options
                                                        .elementAt(index);
                                                    return ListTile(
                                                      title: Text(
                                                        '${option['name']} (${option['email']})',
                                                      ),
                                                      onTap: () {
                                                        onSelected(option);
                                                      },
                                                    );
                                                  },
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                              ),
                              const SizedBox(height: 12),
                              if (_reviewers.isNotEmpty)
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: _reviewers.map((reviewerId) {
                                    final reviewer = _availableReviewers
                                        .firstWhere(
                                          (r) => r['id'] == reviewerId,
                                          orElse: () => {
                                            'name': 'Unknown Reviewer',
                                            'email': '',
                                          },
                                        );
                                    return Chip(
                                      label: Text(
                                        reviewer['name'] ?? reviewer['email'],
                                      ),
                                      backgroundColor: Colors.purple[50],
                                      deleteIcon: const Icon(
                                        Icons.close,
                                        size: 18,
                                      ),
                                      side: BorderSide.none,
                                      onDeleted: () {
                                        setState(() {
                                          _reviewers.remove(reviewerId);
                                          _updateProgress();
                                        });
                                      },
                                    );
                                  }).toList(),
                                ),
                            ],
                          ),

                          _buildSectionContainer(
                            'Miscellaneous',
                            Icons.more_horiz,
                            [
                              _buildTextField(
                                'Additional Requirements',
                                'Enter any additional requirements',
                                onChanged: (value) {
                                  _notesheetDetails.eventRequirements = value;
                                  _updateProgress();
                                },
                                maxLines: 4,
                              ),
                            ],
                          ),

                          const SizedBox(height: 40),
                          Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                ElevatedButton(
                                  onPressed: _isLoading ? null : _saveDraft,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green[600],
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 48,
                                      vertical: 16,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12.0),
                                    ),
                                  ),
                                  child: _isLoading
                                      ? const SizedBox(
                                          width: 16,
                                          height: 16,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                                  Colors.white,
                                                ),
                                          ),
                                        )
                                      : const Text(
                                          'Save draft',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                ),
                                const SizedBox(width: 20),
                                ElevatedButton(
                                  onPressed: _isLoading
                                      ? null
                                      : _submitForReview,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green[600],
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 48,
                                      vertical: 16,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12.0),
                                    ),
                                  ),
                                  child: _isLoading
                                      ? const SizedBox(
                                          width: 16,
                                          height: 16,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                                  Colors.white,
                                                ),
                                          ),
                                        )
                                      : const Text(
                                          'Submit for review',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressTile(
    String title,
    bool isCompleted,
    bool isActive,
    int index,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isCompleted
            ? Colors.green[50]
            : isActive
            ? Colors.blue[50]
            : Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isCompleted
              ? Colors.green[200]!
              : isActive
              ? Colors.blue[200]!
              : Colors.grey[200]!,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: isCompleted
                  ? Colors.green[500]
                  : isActive
                  ? Colors.blue[500]
                  : Colors.grey[300],
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: isCompleted
                  ? const Icon(Icons.check, color: Colors.white, size: 20)
                  : Text(
                      '${index + 1}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: isCompleted || isActive
                    ? Colors.grey[800]
                    : Colors.grey[500],
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionContainer(
    String title,
    IconData icon,
    List<Widget> children,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.grey[25],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.grey[600], size: 24),
              const SizedBox(width: 12),
              Text(
                title,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ...children.map(
            (child) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: child,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(
    String label,
    String hint, {
    ValueChanged<String>? onChanged,
    TextEditingController? controller,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        labelStyle: TextStyle(color: Colors.grey.shade500),
        hintStyle: TextStyle(color: Colors.grey.shade500),
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
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.all(16),
      ),
      maxLines: maxLines,
      keyboardType: keyboardType,
      onChanged: onChanged,
      validator: validator,
    );
  }
}
