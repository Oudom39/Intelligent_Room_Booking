import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../core/constants/api_constants.dart';

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final bool isLoading;

  ChatMessage({
    required this.text,
    required this.isUser,
    DateTime? timestamp,
    this.isLoading = false,
  }) : timestamp = timestamp ?? DateTime.now();
}

class ChatProvider extends ChangeNotifier {
  final List<ChatMessage> _messages = [];
  bool _isTyping = false;
  String? _sessionId;

  List<ChatMessage> get messages => List.unmodifiable(_messages);
  bool get isTyping => _isTyping;

  void _addMessage(ChatMessage msg) {
    _messages.add(msg);
    notifyListeners();
  }

  Future<void> sendMessage(String text, {String? userEmail}) async {
    if (text.trim().isEmpty) return;

    _addMessage(ChatMessage(text: text, isUser: true));
    _isTyping = true;
    notifyListeners();

    try {
      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.chat}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'message': text,
          if (_sessionId != null) 'session_id': _sessionId,
          if (userEmail != null) 'user_email': userEmail,
        }),
      );

      final data = jsonDecode(response.body);
      _sessionId = data['session_id'];
    final reply = data['reply_text']?.toString() ??
      data['response']?.toString() ??
      data['message']?.toString() ??
          'Sorry, I did not understand that.';

      _isTyping = false;
      _addMessage(ChatMessage(text: reply, isUser: false));
    } catch (e) {
      _isTyping = false;
      _addMessage(ChatMessage(
        text: 'Connection error. Please check the server is running.',
        isUser: false,
      ));
    }
  }

  void addGreeting() {
    _messages.add(ChatMessage(
      text:
          '👋 Hi! I\'m the RUPP Room Booking AI Assistant.\n\nI can help you:\n• 🔍 Find available rooms\n• 📅 Check schedules & availability\n• 📋 Guide you through booking\n• 💡 Answer any questions about facilities\n\nWhat can I help you with today?',
      isUser: false,
    ));
    notifyListeners();
  }

  Future<void> clearSession() async {
    try {
      if (_sessionId != null) {
        await http.post(
          Uri.parse('${ApiConstants.baseUrl}${ApiConstants.clearChat}'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'session_id': _sessionId}),
        );
      }
    } catch (_) {}
    _messages.clear();
    _sessionId = null;
    notifyListeners();
  }
}
