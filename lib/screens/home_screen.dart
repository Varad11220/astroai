import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Map<dynamic, dynamic>? userProfile;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final profile = await AuthService.getUserProfile();
    setState(() {
      userProfile = profile;
      isLoading = false;
    });
  }

  Future<void> _logout() async {
    setState(() {
      isLoading = true;
    });

    await AuthService.logout();

    if (mounted) {
      Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        elevation: 0,
        actions: [
          IconButton(icon: const Icon(Icons.exit_to_app), onPressed: _logout),
        ],
      ),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    Center(
                      child: Column(
                        children: [
                          CircleAvatar(
                            radius: 50,
                            backgroundColor: Colors.blue.shade100,
                            child: Icon(
                              Icons.person,
                              size: 60,
                              color: Colors.blue.shade700,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            userProfile?['fullName'] ?? 'User',
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            userProfile?['email'] ?? '',
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),
                    const Text(
                      'Profile Information',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildInfoCard(
                      'Date of Birth',
                      userProfile?['dateOfBirth'] ?? 'Not provided',
                    ),
                    const SizedBox(height: 12),
                    _buildInfoCard(
                      'Time of Birth',
                      userProfile?['timeOfBirth'] ?? 'Not provided',
                    ),
                    const SizedBox(height: 12),
                    _buildInfoCard(
                      'Place of Birth',
                      userProfile?['placeOfBirth'] ?? 'Not provided',
                    ),
                    const SizedBox(height: 12),
                    _buildInfoCard(
                      'Account Status',
                      userProfile?['accountStatus'] == 1
                          ? 'Complete'
                          : 'Incomplete',
                    ),
                    const SizedBox(height: 40),
                    if (userProfile?['accountStatus'] == 1)
                      const Center(
                        child: Text(
                          'Your profile is complete! 🎉',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
    );
  }

  Widget _buildInfoCard(String title, String value) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(flex: 3, child: Text(value)),
        ],
      ),
    );
  }
}
