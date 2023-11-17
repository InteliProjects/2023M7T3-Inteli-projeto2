import 'package:cognivoice/models/chat.model.dart';
import 'package:cognivoice/models/message.model.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:loggerw/loggerw.dart';
import 'dart:convert';

class ChatService {
  final Logger logger;
  final String? apiUrl;

  ChatService(this.logger) : apiUrl = dotenv.env['API_URL'];

  Future<List<ChatModel>> getAllChats(String userId) async {
    final response = await http.get(Uri.parse('$apiUrl/chat/get/$userId'));

    if (response.statusCode == 200) {
      final List<dynamic> responseData = json.decode(response.body);

      if (responseData.isNotEmpty) {
        final List<ChatModel> chats = responseData.map((chatData) {
          final List<dynamic> messages = chatData['messages'];

          final List<ChatMessage> chatMessages = messages
              .map((messageData) => ChatMessage(
                    id: messageData['id'],
                    isUser: messageData['isUser'],
                    content: messageData['content'],
                    audio: "",
                    audioUrl: messageData['audioUrl'],
                    createdAt: messageData['createdAt'],
                    updatedAt: messageData['updatedAt'],
                    chatId: messageData['chatId'],
                  ))
              .toList();

          return ChatModel(
            id: chatData['id'],
            userId: chatData['userId'],
            createdAt: chatData['createdAt'],
            updatedAt: chatData['updatedAt'],
            messages: chatMessages,
            lastMessage: messages.isNotEmpty
                ? messages.last['content']
                : "No message...",
          );
        }).toList();

        return chats;
      }
    }

    return [];
  }

  Future<String> create(String userId) async {
    final response = await http.post(Uri.parse('$apiUrl/chat/create/$userId'));

    if (response.statusCode == 200) {
      return response.body;
    }

    return "";
  }

  Future<List<ChatMessage>> getChat(String userId, String chatId) async {
    final response = await http.get(
      Uri.parse('$apiUrl/chat/getOne/$userId/$chatId'),
      headers: {"Content-Type": "application/json"},
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(response.body);
      final List<dynamic> messagesData = responseData['messages'];

      if (messagesData.isNotEmpty) {
        final List<ChatMessage> chatMessages = messagesData
            .map((messageData) => ChatMessage(
                  id: messageData['id'],
                  isUser: messageData['isUser'],
                  content: messageData['content'],
                  audio: messageData['audio'],
                  audioUrl: messageData['audioUrl'],
                  createdAt: messageData['createdAt'],
                  updatedAt: messageData['updatedAt'],
                  chatId: messageData['chatId'],
                ))
            .toList();

        return chatMessages;
      }
    } else {
      logger.e('ChatService: getChat - ${response.body}');
      throw Exception('Failed to load chat');
    }

    return [];
  }

  Future<String> deleteChat(String userId, String chatId) async {
//     router.delete(
// 	"/delete/:userId/:chatId",
// 	param("userId", "ID é necessário").exists({ checkFalsy: true }),
// 	param("chatId", "ID é necessário").exists({ checkFalsy: true }),
// 	chatController.remove
// );

// const remove = async (req, res) => {
// 	const { userId, chatId } = req.params;

// 	//Chamada para o service
// 	try {
// 		const result = await chat.Delete(chatId, userId);
// 		res.send(result);
// 	} catch (err) {
// 		res.status(500).send(err.message);
// 	}
// };

// async Delete(chatId, userId) {
// 		loggerChat.debug("Starting Delete method...");

// 		const chatAlreadyExists = await prisma.chat.findUnique({
// 			where: {
// 				id: chatId,
// 				userId: userId,
// 			},
// 		});

// 		if (!chatAlreadyExists) {
// 			throw new Error("Chat not found");
// 		}

// 		try {
// 			await prisma.chat.delete({
// 				where: {
// 					id: chatId,
// 					userId: userId,
// 				},
// 			});
// 			return "Chat removed successfully";
// 		} catch {
// 			throw new Error("Server problems");
// 		}
// 	}

    final response = await http.delete(
      Uri.parse('$apiUrl/chat/delete/$userId/$chatId'),
      headers: {"Content-Type": "application/json"},
    );

    if (response.statusCode == 200) {
      return response.body;
    } else {
      logger.e('ChatService: deleteChat - ${response.body}');
      throw Exception('Failed to delete chat');
    }
  }
}
