import 'package:flutter/material.dart';
import 'package:docket/data/models/notesheet.dart';

import 'package:docket/services/auth/auth_service.dart';
import 'package:docket/services/notesheet/notesheet_service.dart';

class EditNotesheet extends StatefulWidget {
  final String notesheetId;
  final Notesheet initialNotesheet;

  const EditNotesheet({
    super.key,
    required this.notesheetId,
    required this.initialNotesheet,
  });

  @override
  State<EditNotesheet> createState() => _EditNotesheetState();
}

class _EditNotesheetState extends State<EditNotesheet> {
  final NotesheetDetails _notesheetDetails = NotesheetDetails();
  final NotesheetService _notesheetService = NotesheetService();
  final AuthService _authService = AuthService();
  final _formKey = GlobalKey<FormState>();

  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _guestsController = TextEditingController();
  final _reviewersController = TextEditingController();

  List<String> _reviewers = [];
  List<Map<String, dynamic>> _availableReviewers = [];
  bool _isLoading = false;
  String? _currentUserId;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    setState(() {
      _isLoading = true;
    });

    final user = _authService.getCurrentUser();
    if (user != null) {
      _currentUserId = user.id;
      await _loadReviewers();
    }

    _titleController.text = widget.initialNotesheet.title;
    _descriptionController.text = widget.initialNotesheet.description;
    _reviewers = List.from(widget.initialNotesheet.reviewers);

    _notesheetDetails.eventTitle = widget.initialNotesheet.details?.eventTitle;
    _notesheetDetails.eventDescription =
        widget.initialNotesheet.details?.eventDescription;
    _notesheetDetails.eventDate = widget.initialNotesheet.details?.eventDate;
    _notesheetDetails.eventVenue = widget.initialNotesheet.details?.eventVenue;
    _notesheetDetails.eventOrganiser =
        widget.initialNotesheet.details?.eventOrganiser;
    _notesheetDetails.eventBudget =
        widget.initialNotesheet.details?.eventBudget;
    _notesheetDetails.eventRequirements =
        widget.initialNotesheet.details?.eventRequirements;
    _notesheetDetails.guests = List.from(
      widget.initialNotesheet.details?.guests ?? [],
    );
    _notesheetDetails.miscellanous =
        widget.initialNotesheet.details?.miscellanous;

    setState(() {
      _isLoading = false;
    });
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

  void _addReviewer(Map<String, dynamic> reviewer) {
    if (!_reviewers.contains(reviewer['id'])) {
      setState(() {
        _reviewers.add(reviewer['id']);
        _reviewersController.clear();
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
      });
    }
  }

  void _removeGuest(String guest) {
    setState(() {
      _notesheetDetails.guests!.remove(guest);
    });
  }

  void _removeReviewer(String reviewerId) {
    setState(() {
      _reviewers.remove(reviewerId);
    });
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
      });
    }
  }

  Future<void> _updateNotesheet() async {
    if (_currentUserId == null || !_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final updatedNotesheet = Notesheet(
        id: widget.notesheetId,
        createdBy: widget.initialNotesheet.createdBy,
        createdAt: widget.initialNotesheet.createdAt,
        title: _titleController.text,
        description: _descriptionController.text,
        reviewers: _reviewers,
        status: widget.initialNotesheet.status,
        details: _notesheetDetails,
      );

      await _notesheetService.updateNotesheet(updatedNotesheet);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Notesheet updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update notesheet: $e'),
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
        title: const Text('Edit Notesheet'),
        backgroundColor: Colors.grey[50],
        foregroundColor: Colors.grey[800],
        elevation: 0,
      ),
      body: Container(
        color: Colors.grey[50],
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1000),
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: _isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : Container(
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
                                      'Edit Notesheet',
                                      style: TextStyle(
                                        fontSize: 28,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.grey[800],
                                      ),
                                    ),
                                    Text(
                                      'Modify the details of your notesheet',
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
                                          validator: (value) {
                                            if (value == null ||
                                                value.isEmpty) {
                                              return 'Please enter a title';
                                            }
                                            return null;
                                          },
                                        ),
                                        _buildTextField(
                                          'Description',
                                          'Enter notesheet description',
                                          controller: _descriptionController,
                                          maxLines: 3,
                                          validator: (value) {
                                            if (value == null ||
                                                value.isEmpty) {
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
                                          initialValue:
                                              _notesheetDetails.eventTitle,
                                          onChanged: (value) =>
                                              _notesheetDetails.eventTitle =
                                                  value,
                                          validator: (value) {
                                            if (value == null ||
                                                value.isEmpty) {
                                              return 'Please enter event title';
                                            }
                                            return null;
                                          },
                                        ),
                                        _buildTextField(
                                          'Event Description',
                                          'Describe the event',
                                          initialValue: _notesheetDetails
                                              .eventDescription,
                                          onChanged: (value) =>
                                              _notesheetDetails
                                                      .eventDescription =
                                                  value,
                                          maxLines: 3,
                                          validator: (value) {
                                            if (value == null ||
                                                value.isEmpty) {
                                              return 'Please enter event description';
                                            }
                                            return null;
                                          },
                                        ),
                                        _buildTextField(
                                          'Event Venue',
                                          'Enter venue location',
                                          initialValue:
                                              _notesheetDetails.eventVenue,
                                          onChanged: (value) =>
                                              _notesheetDetails.eventVenue =
                                                  value,
                                          validator: (value) {
                                            if (value == null ||
                                                value.isEmpty) {
                                              return 'Please enter event venue';
                                            }
                                            return null;
                                          },
                                        ),
                                        _buildTextField(
                                          'Event Organiser',
                                          'Enter organiser name',
                                          initialValue:
                                              _notesheetDetails.eventOrganiser,
                                          onChanged: (value) =>
                                              _notesheetDetails.eventOrganiser =
                                                  value,
                                          validator: (value) {
                                            if (value == null ||
                                                value.isEmpty) {
                                              return 'Please enter organiser name';
                                            }
                                            return null;
                                          },
                                        ),
                                      ],
                                    ),
                                    _buildSectionContainer(
                                      'Date & Time',
                                      Icons.schedule,
                                      [
                                        GestureDetector(
                                          onTap: () => _selectDate(context),
                                          child: Container(
                                            padding: const EdgeInsets.all(16.0),
                                            decoration: BoxDecoration(
                                              color: Colors.grey[50],
                                              borderRadius:
                                                  BorderRadius.circular(12.0),
                                              border: Border.all(
                                                color: Colors.grey[200]!,
                                              ),
                                            ),
                                            child: Row(
                                              children: [
                                                Icon(
                                                  Icons.calendar_today,
                                                  color: Colors.grey[600],
                                                ),
                                                const SizedBox(width: 12),
                                                Text(
                                                  _notesheetDetails.eventDate !=
                                                          null
                                                      ? '${_notesheetDetails.eventDate!.day}/${_notesheetDetails.eventDate!.month}/${_notesheetDetails.eventDate!.year}'
                                                      : 'Select event date',
                                                  style: TextStyle(
                                                    color:
                                                        _notesheetDetails
                                                                .eventDate !=
                                                            null
                                                        ? Colors.grey[800]
                                                        : Colors.grey[500],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    _buildSectionContainer(
                                      'Budget & Guests',
                                      Icons.group,
                                      [
                                        _buildTextField(
                                          'Event Budget',
                                          'Enter budget amount',
                                          initialValue:
                                              _notesheetDetails.eventBudget,
                                          onChanged: (value) =>
                                              _notesheetDetails.eventBudget =
                                                  value,
                                          keyboardType: TextInputType.number,
                                          validator: (value) {
                                            if (value == null ||
                                                value.isEmpty) {
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
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          12.0,
                                                        ),
                                                    borderSide: BorderSide(
                                                      color: Colors.grey[200]!,
                                                    ),
                                                  ),
                                                  enabledBorder:
                                                      OutlineInputBorder(
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              12.0,
                                                            ),
                                                        borderSide: BorderSide(
                                                          color:
                                                              Colors.grey[200]!,
                                                        ),
                                                      ),
                                                  focusedBorder:
                                                      OutlineInputBorder(
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              12.0,
                                                            ),
                                                        borderSide: BorderSide(
                                                          color:
                                                              Colors.blue[400]!,
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
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 16,
                                                      vertical: 20,
                                                    ),
                                                backgroundColor:
                                                    Colors.blue[600],
                                                foregroundColor: Colors.white,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                        12.0,
                                                      ),
                                                ),
                                              ),
                                              child: const Text('Add'),
                                            ),
                                          ],
                                        ),
                                        if (_notesheetDetails.guests != null &&
                                            _notesheetDetails
                                                .guests!
                                                .isNotEmpty)
                                          Wrap(
                                            spacing: 8,
                                            runSpacing: 8,
                                            children: _notesheetDetails.guests!
                                                .map(
                                                  (guest) => Chip(
                                                    label: Text(guest),
                                                    backgroundColor:
                                                        Colors.blue[50],
                                                    deleteIcon: const Icon(
                                                      Icons.close,
                                                      size: 18,
                                                    ),
                                                    side: BorderSide.none,
                                                    onDeleted: () =>
                                                        _removeGuest(guest),
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
                                              (
                                                TextEditingValue
                                                textEditingValue,
                                              ) {
                                                if (textEditingValue.text ==
                                                    '') {
                                                  return const Iterable<
                                                    Map<String, dynamic>
                                                  >.empty();
                                                }
                                                return _availableReviewers
                                                    .where((reviewer) {
                                                      final name =
                                                          (reviewer['name']
                                                                  as String)
                                                              .toLowerCase();
                                                      final email =
                                                          (reviewer['email']
                                                                  as String)
                                                              .toLowerCase();
                                                      final input =
                                                          textEditingValue.text
                                                              .toLowerCase();
                                                      return name.contains(
                                                            input,
                                                          ) ||
                                                          email.contains(input);
                                                    });
                                              },
                                          onSelected:
                                              (Map<String, dynamic> selection) {
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
                                                  controller:
                                                      textEditingController,
                                                  focusNode: focusNode,
                                                  decoration: InputDecoration(
                                                    labelText: 'Add Reviewer',
                                                    hintText:
                                                        'Type to search for reviewers',
                                                    labelStyle: TextStyle(
                                                      color:
                                                          Colors.grey.shade500,
                                                    ),
                                                    hintStyle: TextStyle(
                                                      color:
                                                          Colors.grey.shade500,
                                                    ),
                                                    border: OutlineInputBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            12.0,
                                                          ),
                                                      borderSide: BorderSide(
                                                        color:
                                                            Colors.grey[200]!,
                                                      ),
                                                    ),
                                                    enabledBorder:
                                                        OutlineInputBorder(
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                12.0,
                                                              ),
                                                          borderSide:
                                                              BorderSide(
                                                                color: Colors
                                                                    .grey[200]!,
                                                              ),
                                                        ),
                                                    focusedBorder:
                                                        OutlineInputBorder(
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                12.0,
                                                              ),
                                                          borderSide:
                                                              BorderSide(
                                                                color: Colors
                                                                    .blue[400]!,
                                                              ),
                                                        ),
                                                    filled: true,
                                                    fillColor: Colors.grey[50],
                                                  ),
                                                  onFieldSubmitted:
                                                      (String value) {},
                                                );
                                              },
                                          optionsViewBuilder:
                                              (
                                                BuildContext context,
                                                AutocompleteOnSelected<
                                                  Map<String, dynamic>
                                                >
                                                onSelected,
                                                Iterable<Map<String, dynamic>>
                                                options,
                                              ) {
                                                return Align(
                                                  alignment: Alignment.topLeft,
                                                  child: Material(
                                                    elevation: 4.0,
                                                    child: SizedBox(
                                                      height: 200.0,
                                                      child: ListView.builder(
                                                        padding:
                                                            EdgeInsets.zero,
                                                        itemCount:
                                                            options.length,
                                                        itemBuilder:
                                                            (
                                                              BuildContext
                                                              context,
                                                              int index,
                                                            ) {
                                                              final option =
                                                                  options
                                                                      .elementAt(
                                                                        index,
                                                                      );
                                                              return ListTile(
                                                                title: Text(
                                                                  '${option['name']} (${option['email']})',
                                                                ),
                                                                onTap: () {
                                                                  onSelected(
                                                                    option,
                                                                  );
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
                                            children: _reviewers.map((
                                              reviewerId,
                                            ) {
                                              final reviewer =
                                                  _availableReviewers.firstWhere(
                                                    (r) =>
                                                        r['id'] == reviewerId,
                                                    orElse: () => {
                                                      'name':
                                                          'Unknown Reviewer',
                                                      'email': '',
                                                    },
                                                  );
                                              return Chip(
                                                label: Text(
                                                  reviewer['name'] ??
                                                      reviewer['email'],
                                                ),
                                                backgroundColor:
                                                    Colors.purple[50],
                                                deleteIcon: const Icon(
                                                  Icons.close,
                                                  size: 18,
                                                ),
                                                side: BorderSide.none,
                                                onDeleted: () =>
                                                    _removeReviewer(reviewerId),
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
                                          initialValue: _notesheetDetails
                                              .eventRequirements,
                                          onChanged: (value) =>
                                              _notesheetDetails
                                                      .eventRequirements =
                                                  value,
                                          maxLines: 4,
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 40),
                                    Center(
                                      child: ElevatedButton(
                                        onPressed: _isLoading
                                            ? null
                                            : _updateNotesheet,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.blue[600],
                                          foregroundColor: Colors.white,
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 48,
                                            vertical: 16,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              12.0,
                                            ),
                                          ),
                                        ),
                                        child: _isLoading
                                            ? const SizedBox(
                                                width: 16,
                                                height: 16,
                                                child: CircularProgressIndicator(
                                                  strokeWidth: 2,
                                                  valueColor:
                                                      AlwaysStoppedAnimation<
                                                        Color
                                                      >(Colors.white),
                                                ),
                                              )
                                            : const Text(
                                                'Update Notesheet',
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                  ),
                ),
              ),
            ),
          ],
        ),
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
    String? initialValue,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      initialValue: controller == null ? initialValue : null,
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
