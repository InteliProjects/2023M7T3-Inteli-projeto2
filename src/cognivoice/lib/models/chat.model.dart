import 'package:cognivoice/models/message.model.dart';

class ChatModel {
  final String id;
  final String userId;
  final String createdAt;
  final String updatedAt;
  final List<ChatMessage> messages;
  final String lastMessage;

  ChatModel({
    required this.id,
    required this.userId,
    required this.createdAt,
    required this.updatedAt,
    required this.messages,
    required this.lastMessage,
  });

  static fromJson(chat) {}
}
