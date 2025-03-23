import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class FirebaseTestScreen extends StatefulWidget {
  const FirebaseTestScreen({Key? key}) : super(key: key);

  @override
  _FirebaseTestScreenState createState() => _FirebaseTestScreenState();
}

class _FirebaseTestScreenState extends State<FirebaseTestScreen> {
  final DatabaseReference _database = FirebaseDatabase.instance.ref();
  String _testResult = "Testing...";
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _testDatabaseConnection();
  }

  Future<void> _testDatabaseConnection() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Try to create a test node
      await _database.child('test').set({
        'timestamp': DateTime.now().toIso8601String(),
        'message': 'Test connection successful',
      });

      // Read the test node to verify connection
      final snapshot = await _database.child('test').get();

      setState(() {
        _testResult =
            "Firebase Database connected successfully!\nData: ${snapshot.value}";
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _testResult = "Error connecting to Firebase Database: ${e.toString()}";
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Firebase Database Test')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _isLoading
                  ? CircularProgressIndicator()
                  : Icon(
                    _testResult.contains('successfully')
                        ? Icons.check_circle
                        : Icons.error,
                    color:
                        _testResult.contains('successfully')
                            ? Colors.green
                            : Colors.red,
                    size: 80,
                  ),
              SizedBox(height: 24),
              Text(
                _testResult,
                style: TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isLoading ? null : _testDatabaseConnection,
                child: Text('Test Again'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
