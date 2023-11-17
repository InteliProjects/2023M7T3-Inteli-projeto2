import 'package:cognivoice/models/userService.model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final userProvider = Provider<User>((ref) {
  return User();
});

class User {
  String id;
  String email;
  String name;
  String mode;
  String? accessToken;
  String? refreshToken;
  String? createdAt;
  String? updatedAt;

  User({
    this.id = '',
    this.email = '',
    this.name = '',
    this.mode = '',
  });

  User get() {
    return this;
  }

  void auth(GetUserResponse user, UserAuthResponse auth) {
    id = user.id;
    email = user.email!;
    name = user.name!;
    mode = user.mode!;
    createdAt = user.createdAt;
    updatedAt = user.updatedAt;
    accessToken = auth.accessToken;
    refreshToken = auth.refreshToken;
  }

  bool logOut() {
    id = '';
    email = '';
    name = '';
    mode = '';
    accessToken = '';
    refreshToken = '';
    createdAt = '';
    updatedAt = '';

    return true;
  }

  void update(GetUserResponse user) {
    id = user.id;
    email = user.email!;
    name = user.name!;
    mode = user.mode!;
    createdAt = user.createdAt;
    updatedAt = user.updatedAt;
  }

  ChatController getChatController() {
    final conversation = [
      {
        'role': 'user',
        'content': 'Oi, tudo bem?',
      },
      {
        'role': 'assistant',
        'content': 'Tudo ótimo, e você?',
      },
    ];

    final chat = Chat();
    chat.addConversation(id, conversation);

    return ChatController(id, chat);
  }
}

class Chat {
  final _conversations = <String, List<Map<String, String>>>{};

  void addConversation(String userId, List<Map<String, String>> conversation) {
    _conversations[userId] = conversation;
  }

  List<Map<String, String>> getConversation(String userId) {
    return _conversations[userId] ?? [];
  }
}

class ChatController {
  final String _userId;
  final Chat _chat;
  final _messages = <String>[];

  ChatController(this._userId, this._chat) {
    _messages.addAll(_chat.getConversation(_userId).map((message) =>
        '${message['role'] == 'user' ? 'User' : 'AI'}: ${message['content']}'));
  }

  List<String> get messages => _messages;

  void addMessage(String message) {
    // Simulate AI response (replace with actual AI response logic)
    _messages.add('User: $message');
    _messages.add('AI: This is an AI response for "$message"');
  }
}

void main() {
  final user = User();
  final chatController = user.getChatController();

  // Print the initial conversation
  print('Initial Conversation:');
  chatController.messages.forEach(print);

  // Simulate adding a new message and AI response
  chatController.addMessage('How are you?');
  print('\nUpdated Conversation:');
  chatController.messages.forEach(print);
}
