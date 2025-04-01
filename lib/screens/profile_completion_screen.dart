import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/auth_service.dart';

class ProfileCompletionScreen extends StatefulWidget {
  const ProfileCompletionScreen({Key? key}) : super(key: key);

  @override
  _ProfileCompletionScreenState createState() =>
      _ProfileCompletionScreenState();
}

class _ProfileCompletionScreenState extends State<ProfileCompletionScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _dateOfBirthController = TextEditingController();
  final TextEditingController _timeOfBirthController = TextEditingController();
  final TextEditingController _placeOfBirthController = TextEditingController();

  bool _isLoading = false;
  bool _isLoadingData = true;
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  @override
  void initState() {
    super.initState();
    _loadExistingProfile();
  }

  Future<void> _loadExistingProfile() async {
    try {
      final profile = await AuthService.getUserProfile();

      if (profile != null) {
        setState(() {
          _fullNameController.text = profile['fullName'] ?? '';
          _dateOfBirthController.text = profile['dateOfBirth'] ?? '';
          _placeOfBirthController.text = profile['placeOfBirth'] ?? '';

          if (profile['timeOfBirth'] != null &&
              profile['timeOfBirth'].toString().isNotEmpty) {
            _timeOfBirthController.text = profile['timeOfBirth'];
          }

          // Try to parse the date
          if (_dateOfBirthController.text.isNotEmpty) {
            try {
              _selectedDate = DateFormat(
                'yyyy-MM-dd',
              ).parse(_dateOfBirthController.text);
            } catch (_) {}
          }

          _isLoadingData = false;
        });
      } else {
        setState(() {
          _isLoadingData = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoadingData = false;
      });
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _dateOfBirthController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
    );

    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
        _timeOfBirthController.text = picked.format(context);
      });
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final result = await AuthService.updateUserProfile(
        fullName: _fullNameController.text,
        dateOfBirth: _dateOfBirthController.text,
        timeOfBirth:
            _timeOfBirthController.text.isNotEmpty
                ? _timeOfBirthController.text
                : null,
        placeOfBirth:
            _placeOfBirthController.text.isNotEmpty
                ? _placeOfBirthController.text
                : null,
      );

      if (result) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile saved successfully')),
        );
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Failed to save profile')));
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isEditing = _fullNameController.text.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Your Profile' : 'Complete Your Profile'),
        centerTitle: true,
      ),
      body:
          _isLoadingData
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Center(
                        child: Text(
                          'PAC',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.indigo,
                          ),
                        ),
                      ),

                      const Center(
                        child: Text(
                          'Tell us about yourself',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      ),

                      const SizedBox(height: 30),

                      // Full Name (Required)
                      TextFormField(
                        controller: _fullNameController,
                        decoration: const InputDecoration(
                          labelText: 'Full Name *',
                          prefixIcon: Icon(Icons.person),
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your full name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Date of Birth (Required)
                      TextFormField(
                        controller: _dateOfBirthController,
                        decoration: const InputDecoration(
                          labelText: 'Date of Birth *',
                          prefixIcon: Icon(Icons.calendar_today),
                          border: OutlineInputBorder(),
                        ),
                        readOnly: true,
                        onTap: () => _selectDate(context),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please select your date of birth';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Time of Birth (Optional)
                      TextFormField(
                        controller: _timeOfBirthController,
                        decoration: const InputDecoration(
                          labelText: 'Time of Birth (optional)',
                          prefixIcon: Icon(Icons.access_time),
                          border: OutlineInputBorder(),
                        ),
                        readOnly: true,
                        onTap: () => _selectTime(context),
                      ),
                      const SizedBox(height: 16),

                      // Place of Birth (Optional)
                      TextFormField(
                        controller: _placeOfBirthController,
                        decoration: const InputDecoration(
                          labelText: 'Place of Birth (optional)',
                          prefixIcon: Icon(Icons.location_on),
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 30),

                      // Why we need this information
                      const Card(
                        elevation: 1,
                        child: Padding(
                          padding: EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Why do we need this information?',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'PAC uses this information to personalize your experience. Your personal details help us provide more relevant responses and recommendations.',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 30),

                      // Submit Button
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child:
                            _isLoading
                                ? const Center(
                                  child: CircularProgressIndicator(),
                                )
                                : ElevatedButton(
                                  onPressed: _saveProfile,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.indigo,
                                  ),
                                  child: Text(
                                    _fullNameController.text.isNotEmpty
                                        ? 'UPDATE PROFILE'
                                        : 'COMPLETE PROFILE',
                                    style: const TextStyle(fontSize: 16),
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
