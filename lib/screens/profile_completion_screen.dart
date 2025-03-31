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
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

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
    return Scaffold(
      appBar: AppBar(title: const Text('Complete Your Profile')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Please provide the following details to complete your profile',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 20),

              // Full Name (Required)
              TextFormField(
                controller: _fullNameController,
                decoration: const InputDecoration(
                  labelText: 'Full Name *',
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
                  border: OutlineInputBorder(),
                  suffixIcon: Icon(Icons.calendar_today),
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
                  labelText: 'Time of Birth (if known)',
                  border: OutlineInputBorder(),
                  suffixIcon: Icon(Icons.access_time),
                ),
                readOnly: true,
                onTap: () => _selectTime(context),
              ),
              const SizedBox(height: 16),

              // Place of Birth (Optional)
              TextFormField(
                controller: _placeOfBirthController,
                decoration: const InputDecoration(
                  labelText: 'Place of Birth (if known)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 24),

              // Submit Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child:
                    _isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : ElevatedButton(
                          onPressed: _saveProfile,
                          child: const Text(
                            'Save Profile',
                            style: TextStyle(fontSize: 16),
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
