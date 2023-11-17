import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:cognivoice/providers/user.provider.dart';
import 'package:cognivoice/services/audio.service.dart';
import 'package:loggerw/loggerw.dart';
import 'package:path_provider/path_provider.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:cognivoice/models/message.model.dart';
import 'package:flutter/material.dart';

class MessageComponent extends StatefulWidget {
  const MessageComponent(this.message, {Key? key}) : super(key: key);

  final ChatMessage message;

  @override
  _MessageComponentState createState() => _MessageComponentState(message);
}

class _MessageComponentState extends State<MessageComponent> {
  final ChatMessage message;
  AudioPlayer audioPlayer = AudioPlayer();
  bool isPlaying = false;

  late Logger logger;
  late AudioService audioService;

  late User user;

  _MessageComponentState(this.message);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment:
            message.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          Container(
              constraints: BoxConstraints(
                maxWidth: message.isUser
                    ? MediaQuery.of(context).size.width * 0.75
                    : MediaQuery.of(context).size.width * 0.85,
              ),
              margin: const EdgeInsets.symmetric(horizontal: 8.0),
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              decoration: BoxDecoration(
                color: message.isUser
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.background,
                borderRadius: BorderRadius.only(
                  bottomLeft: const Radius.circular(16.0),
                  bottomRight: const Radius.circular(16.0),
                  topLeft: message.isUser
                      ? const Radius.circular(16.0)
                      : const Radius.circular(0.0),
                  topRight: message.isUser
                      ? const Radius.circular(0.0)
                      : const Radius.circular(16.0),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // _renderAudioPlayer(message),
                  // play pause button
                  const SizedBox(
                    height: 4.0,
                  ),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        message.isLoading ?? false
                            ? Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(
                                    width: 24.0,
                                    height: 24.0,
                                    child: CircularProgressIndicator(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onPrimary,
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 8.0,
                                  ),
                                  Text(
                                    "Loading ${message.isUser ? "transcript" : "response"}...",
                                    style: TextStyle(
                                      fontSize: Theme.of(context)
                                          .textTheme
                                          .bodyLarge!
                                          .fontSize,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onPrimary,
                                    ),
                                  ),
                                ],
                              )
                            : Expanded(
                                child: Text(
                                  message.content,
                                  style: TextStyle(
                                    fontSize: Theme.of(context)
                                        .textTheme
                                        .bodyLarge!
                                        .fontSize,
                                    color:
                                        Theme.of(context).colorScheme.onPrimary,
                                  ),
                                ),
                              ),
                        // if the message is loading and it's not from the user, hide the play button, else show it
                        message.isLoading ?? false
                            ? !message.isUser
                                ? Container()
                                : IconButton(
                                    onPressed: playPauseAudio,
                                    icon: Icon(
                                      isPlaying
                                          ? Icons.pause
                                          : Icons.play_arrow,
                                      size: 24.0,
                                    ))
                            : IconButton(
                                onPressed: playPauseAudio,
                                icon: Icon(
                                  isPlaying ? Icons.pause : Icons.play_arrow,
                                  size: 24.0,
                                ))
                      ]),
                  const SizedBox(
                    height: 4.0,
                  ),
                ],
              )),
        ],
      ),
    );
  }

  Future<void> playPauseAudio() async {
    try {
      if (isPlaying) {
        await audioPlayer.pause();
        setState(() {
          isPlaying = false;
        });
      } else {
        File audioFile = await decodeAudio(message.audio);
        Source fileSource = UrlSource(audioFile.path);

        await audioPlayer.play(fileSource);

        setState(() {
          isPlaying = true;
        });
      }

      audioPlayer.onPlayerComplete.listen((event) {
        setState(() {
          isPlaying = false;
        });
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text("Error: Could not play audio"),
        ),
      );
    }
  }

  Future<File> decodeAudio(String audioBase64) async {
    final Uint8List audioBytes = base64.decode(audioBase64);
    final Directory tempDir = await getTemporaryDirectory();
    final File tempFile = File('${tempDir.path}/audio.m4a');

    await tempFile.writeAsBytes(audioBytes);

    return tempFile;
  }

  @override
  void initState() {
    logger = Logger();
    audioService = AudioService(logger);

    super.initState();
  }

  @override
  void dispose() {
    audioPlayer.dispose();
    super.dispose();
  }
}
