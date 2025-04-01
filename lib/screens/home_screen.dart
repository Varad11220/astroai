import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config/api_config.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Map<String, dynamic>? userProfile;
  bool isLoading = true;
  final TextEditingController _messageController = TextEditingController();
  final List<ChatMessage> _messages = [];
  bool _isTyping = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();

    // Add welcome message
    _messages.add(
      ChatMessage(
        text:
            "Hi there! I'm PAC, your Personalized AI Companion. How can I help you today?",
        isUser: false,
      ),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    final profile = await AuthService.getUserProfile();
    setState(() {
      userProfile = Map<String, dynamic>.from(profile ?? {});
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

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;

    setState(() {
      _messages.add(
        ChatMessage(text: _messageController.text.trim(), isUser: true),
      );
      _isTyping = true;
    });

    final userMessage = _messageController.text.trim();
    _messageController.clear();

    try {
      // Send request to backend
      final response = await _getAIResponse(userMessage);

      setState(() {
        _messages.add(ChatMessage(text: response, isUser: false));
        _isTyping = false;
      });
    } catch (e) {
      setState(() {
        _messages.add(
          ChatMessage(
            text:
                "I'm sorry, I couldn't process your request. Please try again.",
            isUser: false,
          ),
        );
        _isTyping = false;
      });
    }
  }

  Future<String> _getAIResponse(String message) async {
    try {
      final url = Uri.parse('${ApiConfig.baseUrl}/api/astrology/insight');

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'query': message,
          'birthDate': userProfile?['dateOfBirth'],
          'birthTime': userProfile?['timeOfBirth'],
          'birthPlace': userProfile?['placeOfBirth'],
          'userId': userProfile?['id'],
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['response'] ??
            "I'm sorry, I couldn't process your request right now.";
      } else {
        throw Exception('Failed to get response');
      }
    } catch (e) {
      throw Exception('Error getting AI response: $e');
    }
  }

  void _showProfileModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (context) => DraggableScrollableSheet(
            initialChildSize: 0.6,
            minChildSize: 0.3,
            maxChildSize: 0.9,
            expand: false,
            builder:
                (_, scrollController) => Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.indigo.shade50, Colors.indigo.shade100],
                    ),
                  ),
                  child: ListView(
                    controller: scrollController,
                    children: [
                      const Center(
                        child: Text(
                          'Profile',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.indigo,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Center(
                        child: CircleAvatar(
                          radius: 50,
                          backgroundColor: Colors.indigo.shade100,
                          child: Icon(
                            Icons.person,
                            size: 60,
                            color: Colors.indigo.shade700,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      ListTile(
                        title: const Text('Full Name'),
                        subtitle: Text(
                          userProfile?['fullName'] ?? 'Not available',
                        ),
                        leading: const Icon(Icons.person, color: Colors.indigo),
                      ),
                      ListTile(
                        title: const Text('Email'),
                        subtitle: Text(
                          userProfile?['email'] ?? 'Not available',
                        ),
                        leading: const Icon(Icons.email, color: Colors.indigo),
                      ),
                      ListTile(
                        title: const Text('Date of Birth'),
                        subtitle: Text(
                          userProfile?['dateOfBirth'] ?? 'Not available',
                        ),
                        leading: const Icon(
                          Icons.calendar_today,
                          color: Colors.indigo,
                        ),
                      ),
                      ListTile(
                        title: const Text('Time of Birth'),
                        subtitle: Text(
                          userProfile != null &&
                                  userProfile!.containsKey('timeOfBirth') &&
                                  userProfile!['timeOfBirth'] != null &&
                                  userProfile!['timeOfBirth']
                                      .toString()
                                      .isNotEmpty
                              ? userProfile!['timeOfBirth']
                              : 'No details provided',
                        ),
                        leading: const Icon(
                          Icons.access_time,
                          color: Colors.indigo,
                        ),
                        trailing:
                            userProfile == null ||
                                    !userProfile!.containsKey('timeOfBirth') ||
                                    userProfile!['timeOfBirth'] == null ||
                                    userProfile!['timeOfBirth']
                                        .toString()
                                        .isEmpty
                                ? TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                    Navigator.pushNamed(context, '/profile');
                                  },
                                  child: const Text(
                                    'Add',
                                    style: TextStyle(color: Colors.indigo),
                                  ),
                                )
                                : IconButton(
                                  icon: const Icon(
                                    Icons.edit,
                                    size: 20,
                                    color: Colors.indigo,
                                  ),
                                  onPressed: () {
                                    Navigator.pop(context);
                                    Navigator.pushNamed(context, '/profile');
                                  },
                                ),
                      ),
                      ListTile(
                        title: const Text('Place of Birth'),
                        subtitle: Text(
                          userProfile != null &&
                                  userProfile!.containsKey('placeOfBirth') &&
                                  userProfile!['placeOfBirth'] != null &&
                                  userProfile!['placeOfBirth']
                                      .toString()
                                      .isNotEmpty
                              ? userProfile!['placeOfBirth']
                              : 'No details provided',
                        ),
                        leading: const Icon(
                          Icons.location_on,
                          color: Colors.indigo,
                        ),
                        trailing:
                            userProfile == null ||
                                    !userProfile!.containsKey('placeOfBirth') ||
                                    userProfile!['placeOfBirth'] == null ||
                                    userProfile!['placeOfBirth']
                                        .toString()
                                        .isEmpty
                                ? TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                    Navigator.pushNamed(context, '/profile');
                                  },
                                  child: const Text(
                                    'Add',
                                    style: TextStyle(color: Colors.indigo),
                                  ),
                                )
                                : IconButton(
                                  icon: const Icon(
                                    Icons.edit,
                                    size: 20,
                                    color: Colors.indigo,
                                  ),
                                  onPressed: () {
                                    Navigator.pop(context);
                                    Navigator.pushNamed(context, '/profile');
                                  },
                                ),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          _logout();
                        },
                        icon: const Icon(Icons.logout),
                        label: const Text('Logout'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PAC', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.account_circle),
            onPressed: _showProfileModal,
          ),
        ],
      ),
      body:
          isLoading
              ? const Center(
                child: CircularProgressIndicator(color: Colors.indigo),
              )
              : Column(
                children: [
                  // User profile summary
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.indigo.shade50,
                      border: Border(
                        bottom: BorderSide(
                          color: Colors.indigo.shade200,
                          width: 1,
                        ),
                      ),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 20,
                          backgroundColor: Colors.indigo.shade100,
                          child: Icon(
                            Icons.person,
                            size: 24,
                            color: Colors.indigo.shade700,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Hello, ${userProfile?['fullName']?.split(' ')[0] ?? 'User'}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Text(
                              'How can I assist you today?',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Chat area
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      child: ListView.builder(
                        itemCount: _messages.length,
                        itemBuilder: (context, index) {
                          return MessageBubble(message: _messages[index]);
                        },
                      ),
                    ),
                  ),

                  // Typing indicator
                  if (_isTyping)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      alignment: Alignment.centerLeft,
                      child: Row(
                        children: [
                          const Text(
                            'Thinking',
                            style: TextStyle(
                              fontStyle: FontStyle.italic,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(width: 8),
                          SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.indigo,
                            ),
                          ),
                        ],
                      ),
                    ),

                  // Message input
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          spreadRadius: 1,
                          blurRadius: 5,
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _messageController,
                            decoration: InputDecoration(
                              hintText: 'Ask me anything...',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20),
                                borderSide: BorderSide.none,
                              ),
                              filled: true,
                              fillColor: Colors.grey.shade100,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                            ),
                            onSubmitted: (_) => _sendMessage(),
                          ),
                        ),
                        const SizedBox(width: 8),
                        FloatingActionButton(
                          onPressed: _sendMessage,
                          mini: true,
                          backgroundColor: Colors.indigo,
                          child: const Icon(Icons.send),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
    );
  }
}

// Message model
class ChatMessage {
  final String text;
  final bool isUser;

  ChatMessage({required this.text, required this.isUser});
}

// Message bubble widget
class MessageBubble extends StatelessWidget {
  final ChatMessage message;

  const MessageBubble({Key? key, required this.message}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: message.isUser ? Colors.indigo : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        child: Text(
          message.text,
          style: TextStyle(
            color: message.isUser ? Colors.white : Colors.black87,
          ),
        ),
      ),
    );
  }
}
