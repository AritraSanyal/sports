import 'package:flutter/material.dart';
import 'package:flutter_app/model/unified_model.dart';
import 'package:flutter_app/theme/app_theme.dart';
import 'package:flutter_app/screen/policy_screen.dart';
import '../services/local_chatbot_service.dart';
import 'companion_list_screen.dart';
import 'unified_create_requirement.dart';

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
  });
}

class ChatNavigationButton {
  final String text;
  final CompanionType type;
  final bool isFindCompanion;
  final bool isPolicy;

  ChatNavigationButton({
    required this.text,
    required this.type,
    required this.isFindCompanion,
    this.isPolicy = false,
  });
}

class ChatbotScreen extends StatefulWidget {
  const ChatbotScreen({super.key});

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  final List<ChatMessage> _messages = [];
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = false;

  final List<ChatNavigationButton> _navigationButtons = [
    ChatNavigationButton(
      text: "Find Sports Buddies",
      type: CompanionType.sport,
      isFindCompanion: true,
    ),
    ChatNavigationButton(
      text: "Create Sports Group",
      type: CompanionType.sport,
      isFindCompanion: false,
    ),
    ChatNavigationButton(
      text: "Find Food Companions",
      type: CompanionType.food,
      isFindCompanion: true,
    ),
    ChatNavigationButton(
      text: "Create Food Group",
      type: CompanionType.food,
      isFindCompanion: false,
    ),
    ChatNavigationButton(
      text: "Find Travel Partners",
      type: CompanionType.travel,
      isFindCompanion: true,
    ),
    ChatNavigationButton(
      text: "Create Travel Group",
      type: CompanionType.travel,
      isFindCompanion: false,
    ),
    // Privacy Policy button
    ChatNavigationButton(
      text: "Privacy Policy",
      type: CompanionType.sport, // unused when isPolicy is true
      isFindCompanion: false,
      isPolicy: true,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _messages.add(
      ChatMessage(
        text: LocalChatbotService.getRandomGreeting(),
        isUser: false,
        timestamp: DateTime.now(),
      ),
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // Helper method to get companion type specific data
  Map<String, String> _getCompanionTypeData(CompanionType type) {
    switch (type) {
      case CompanionType.sport:
        return {
          'imagePath': 'assets/images/sportsfilter.jpg',
          'caption': 'Find People to play sports with.',
        };
      case CompanionType.food:
        return {
          'imagePath': 'assets/images/foodfilter.jpg',
          'caption': 'Find People to eat with.',
        };
      case CompanionType.travel:
        return {
          'imagePath': 'assets/images/travelfilter.jpg',
          'caption': 'Find People to travel with.',
        };
    }
  }

  Future<void> _sendMessage() async {
    final text = _textController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add(
        ChatMessage(text: text, isUser: true, timestamp: DateTime.now()),
      );
      _isLoading = true;
    });

    _textController.clear();
    _scrollToBottom();

    final intent = LocalChatbotService.detectNavigationIntent(text);

    if (intent != null) {
      await Future.delayed(const Duration(seconds: 3));

      setState(() {
        _messages.add(
          ChatMessage(
            text: intent.response,
            isUser: false,
            timestamp: DateTime.now(),
          ),
        );
        _isLoading = false;
      });
      _scrollToBottom();

      Future.delayed(const Duration(milliseconds: 800), () {
        if (intent.type == NavigationIntentType.createGroup) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (_) => UnifiedCreateRequirementScreen(
                    type: CompanionType.values[intent.companionType.index],
                  ),
            ),
          );
        } else if (intent.type == NavigationIntentType.findCompanions) {
          final typeData = _getCompanionTypeData(intent.companionType);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (_) => CompanionListScreen(
                    type: intent.companionType,
                    imagePath: typeData['imagePath']!,
                    caption: typeData['caption']!,
                  ),
            ),
          );
        }
      });
    } else {
      final botResponse = LocalChatbotService.getResponse(text);
      await Future.delayed(const Duration(seconds: 3));

      setState(() {
        _messages.add(
          ChatMessage(
            text: botResponse,
            isUser: false,
            timestamp: DateTime.now(),
          ),
        );
        _isLoading = false;
      });
      _scrollToBottom();
    }
  }

  void _handleNavigationButton(ChatNavigationButton button) {
    if (button.isPolicy) {
      setState(() {
        _messages.add(
          ChatMessage(
            text: "Open Privacy Policy",
            isUser: true,
            timestamp: DateTime.now(),
          ),
        );
        _messages.add(
          ChatMessage(
            text: "Showing Privacy Policy...",
            isUser: false,
            timestamp: DateTime.now(),
          ),
        );
      });

      _scrollToBottom();

      Future.delayed(const Duration(milliseconds: 800), () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (_) => const PolicyScreen(
                  title: 'Privacy Policy',
                  sections: [
                    PolicySection(
                      heading: '1. Introduction',
                      body:
                          'This Privacy Policy explains how we collect, use, and protect your personal information when you use our mobile application ("App"). By using the App, you agree to the collection and use of information in accordance with this policy.',
                    ),
                    PolicySection(
                      heading: '2. Information We Collect',
                      body:
                          'We collect the following types of information:\n\n'
                          'a. Personal Information\n'
                          '- Email address\n'
                          '- Password (securely stored via Firebase Authentication)\n'
                          '- Profile Photo (uploaded and stored via Firebase Storage)\n\n'
                          'b. User-Provided Content\n'
                          '- Interests in sports, food, and travel\n'
                          '- Group names and chat messages\n'
                          '- Group participation data\n\n'
                          'c. Automatically Collected Information\n'
                          '- Device type and OS version\n'
                          '- App usage data (only if analytics is added)\n'
                          '- Timestamp of actions (e.g., group creation, messages)',
                    ),
                    PolicySection(
                      heading: '3. How We Use Your Information',
                      body:
                          'We use your information to:\n'
                          '- Create and manage your user account\n'
                          '- Allow discovery of other users with shared interests\n'
                          '- Enable group creation and real-time chat\n'
                          '- Maintain security and prevent unauthorized access\n'
                          '- Improve the functionality and experience of the App',
                    ),
                    PolicySection(
                      heading: '4. Data Sharing & Disclosure',
                      body:
                          'We do not sell, trade, or rent your personal information to third parties. Your data is only shared in the following cases:\n'
                          '- With group members (your name, photo, and messages)\n'
                          '- With service providers (Firebase) for backend functionality\n'
                          '- When required by law or legal process',
                    ),
                    PolicySection(
                      heading: '5. Data Security',
                      body:
                          'We use Firebase Authentication and Firestore security rules to protect your data. All passwords are encrypted and never stored in plain text.\n\n'
                          'We apply best practices to prevent unauthorized access, including user-based access control and encrypted communications.',
                    ),
                    PolicySection(
                      heading: '6. Your Data Rights',
                      body:
                          'You can:\n'
                          '- View or edit your profile information\n'
                          '- Delete your account and associated data by contacting support\n'
                          '- Revoke access by signing out of the App',
                    ),
                    PolicySection(
                      heading: '7. Data Retention',
                      body:
                          'We retain your data as long as your account is active. If you delete your account, all associated data will be permanently removed from our systems.',
                    ),
                    PolicySection(
                      heading: '8. Children’s Privacy',
                      body:
                          'Our app is not intended for children under the age of 18. We do not knowingly collect personal information from children under 18.',
                    ),
                    PolicySection(
                      heading: '9. Changes to This Policy',
                      body:
                          'We may update this Privacy Policy from time to time. Any changes will be posted in the app or on our website, and the effective date will be updated.',
                    ),
                    PolicySection(
                      heading: '10. Contact Us',
                      body:
                          'If you have questions or concerns about this Privacy Policy or your personal data, please contact us at:\nEmail: support@sportsapp.com',
                    ),
                  ],
                ),
          ),
        );
      });
      return;
    }
    final action = button.isFindCompanion ? "find" : "create";
    final type = button.type.toString().split('.').last;

    setState(() {
      _messages.add(
        ChatMessage(
          text: "I want to $action $type companions",
          isUser: true,
          timestamp: DateTime.now(),
        ),
      );
      _messages.add(
        ChatMessage(
          text: "Taking you to $action $type...",
          isUser: false,
          timestamp: DateTime.now(),
        ),
      );
    });

    _scrollToBottom();

    Future.delayed(const Duration(milliseconds: 800), () {
      if (button.isFindCompanion) {
        final typeData = _getCompanionTypeData(button.type);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (_) => CompanionListScreen(
                  type: button.type,
                  imagePath: typeData['imagePath']!,
                  caption: typeData['caption']!,
                ),
          ),
        );
      } else {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (_) => UnifiedCreateRequirementScreen(
                  type: CompanionType.values[button.type.index],
                ),
          ),
        );
      }
    });
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryColor,
      appBar: AppBar(
        title: const Text(
          'Ai Assistant',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF9C27B0),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Container(
        decoration: const BoxDecoration(color: Color(0xFFF3D3F5)),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children:
                      _navigationButtons.map((button) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: ActionChip(
                            label: Text(
                              button.text,
                              style: const TextStyle(color: Colors.white),
                            ),
                            backgroundColor: const Color(0xFF6A1B9A),
                            onPressed: () => _handleNavigationButton(button),
                          ),
                        );
                      }).toList(),
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(16),
                itemCount: _messages.length + (_isLoading ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == _messages.length && _isLoading) {
                    return _buildLoadingMessage();
                  }
                  return _buildMessage(_messages[index]);
                },
              ),
            ),
            _buildInputArea(),
          ],
        ),
      ),
    );
  }

  Widget _buildMessage(ChatMessage message) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment:
            message.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!message.isUser) ...[
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFFE1A7EB),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.sports_soccer,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color:
                    message.isUser
                        ? Colors.white.withOpacity(0.9)
                        : const Color(0xFFE1A7EB),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                message.text,
                style: TextStyle(
                  color: message.isUser ? Colors.black87 : Colors.black,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          if (message.isUser) ...[
            const SizedBox(width: 8),
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFFE1A7EB),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(Icons.person, color: Colors.white, size: 20),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildLoadingMessage() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFFE1A7EB),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              Icons.sports_soccer,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFE1A7EB),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
                SizedBox(width: 8),
                Text(
                  'Typing...',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Color(0xFFE1A7EB),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _textController,
              style: const TextStyle(color: Colors.black),
              decoration: InputDecoration(
                hintText: 'Ask something...',
                hintStyle: TextStyle(color: Colors.black.withOpacity(0.5)),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
              ),
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF9C27B0),
              borderRadius: BorderRadius.circular(25),
            ),
            child: IconButton(
              onPressed: _isLoading ? null : _sendMessage,
              icon: const Icon(Icons.send, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
