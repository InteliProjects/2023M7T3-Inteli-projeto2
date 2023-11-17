import 'package:cognivoice/models/audioProcessingResult.model.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:loggerw/loggerw.dart';
import 'dart:typed_data';
import 'dart:convert';
import 'dart:io';

class AudioService {
  final Logger logger;
  final String? apiUrl;

  AudioService(this.logger) : apiUrl = dotenv.env['API_URL'];

  Future<AudioProcessingResult> postAudio(
      String audioFilePath, String mode, String? chatId) async {
    final path = "chat/ask";
    logger.i("AudioService: Posting audio to $apiUrl/$path");

    if (apiUrl == null) {
      logger.e("AudioService: API_URL not found");
      return AudioProcessingResult(
        answer: AudioContent(text: "", audio: ""),
        question: AudioContent(text: "", audio: ""),
        statusCode: 500,
      );
    }

    List<int> audioBytes = await File(audioFilePath).readAsBytes();
    logger.i("AudioService: Audio bytes length - ${audioBytes.length}");

    final response = await http.post(
      Uri.parse("$apiUrl/$path/$mode/${chatId!}"),
      headers: {'Content-Type': 'audio/mp4'},
      body: audioBytes,
    );
    logger.i("AudioService: Response status code - ${response.statusCode}");

    final jsonResponse = json.decode(response.body);

    logger.i("AudioService: Response - ${jsonResponse['answer']['text']}");

    if (response.statusCode == 200) {
      logger.i("AudioService: Response success");

      final answer = AudioContent(
          text: jsonResponse['answer']['text'],
          audio: jsonResponse['answer']['audio']);

      final question = AudioContent(
          text: jsonResponse['question']['text'],
          audio: jsonResponse['question']['audio']);

      return AudioProcessingResult(
        answer: answer,
        question: question,
        statusCode: response.statusCode,
      );
    } else {
      logger.e("AudioService: Response error - ${response.body}");

      return AudioProcessingResult(
        answer: AudioContent(text: "", audio: ""),
        question: AudioContent(text: "", audio: ""),
        statusCode: response.statusCode,
      );
    }
  }

  Future<File> decodeAudio(String audioBase64) async {
    logger.i("AudioService: Decoding audio");

    final Uint8List audioBytes = base64.decode(audioBase64);
    logger.i("AudioService: Audio bytes length");

    final Directory tempDir = await getTemporaryDirectory();
    logger.i("AudioService: Temporary directory");

    final File tempFile = File('${tempDir.path}/audio.m4a');
    logger.i("AudioService: Temporary file created");

    await tempFile.writeAsBytes(audioBytes);
    logger.i("AudioService: Audio file written to temporary file");

    return tempFile;
  }

  Future<String> encodeAudio(String audioFilePath) async {
    logger.i("AudioService: Encoding audio");

    final File audioFile = File(audioFilePath);
    logger.i("AudioService: Audio file");

    final Uint8List audioBytes = await audioFile.readAsBytes();
    logger.i("AudioService: Audio bytes length");

    final String audioBase64 = base64.encode(audioBytes);
    logger.i("AudioService: Audio base64");

    return audioBase64;
  }
}
