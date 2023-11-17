class ChatMessage {
  String id;
  bool isUser;
  String content;
  String audio;
  String audioUrl;
  String createdAt;
  String updatedAt;
  String chatId;
  bool? isLoading;

  ChatMessage({
    required this.id,
    required this.isUser,
    required this.content,
    required this.audio,
    required this.audioUrl,
    required this.createdAt,
    required this.updatedAt,
    required this.chatId,
    this.isLoading,
  });
}
