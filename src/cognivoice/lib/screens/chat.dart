import 'package:audioplayers/audioplayers.dart';
import 'package:cognivoice/components/message.component.dart';
import 'package:cognivoice/models/audioProcessingResult.model.dart';
import 'package:cognivoice/services/audio.service.dart';
import 'package:cognivoice/services/chat.service.dart';
import 'package:record/record.dart';
import 'package:cognivoice/models/message.model.dart';
import 'package:cognivoice/providers/user.provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:loggerw/loggerw.dart';

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen(
      {Key? key,
      required this.context,
      required this.ref,
      required this.logger})
      : super(key: key);

  final BuildContext context;
  final WidgetRef ref;
  final Logger logger;

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  late User user;

  bool isRecording = false;
  String audioPath = "";

  bool isPlaying = false;
  bool isPlayingRecordedAudio = false;

  bool isProcessing = false;

  String chatIndex = ""; // "91891459-b896-447a-aff5-4dac8069c6f6";

  final List<ChatMessage> chat = [];
  late final ChatService chatService;

  final Record audioRecord = Record();
  final AudioPlayer audioPlayer = AudioPlayer();
  late final AudioService audioService;

  @override
  Widget build(BuildContext context) {
    user = widget.ref.read(userProvider).get();

    return Scaffold(
      appBar: AppBar(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(16),
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            widget.logger.i("ChatScreen: Back button pressed");

            // pop the chat screen and go back to the home screen
            // and run the home screen's init state
            Navigator.of(context).pop(context);
          },
        ),
        title: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: Image.asset(
            'assets/logo.png',
            width: 128,
          ),
        ),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.onBackground,
        toolbarHeight: 64.0,
        actions: [
          IconButton(
            onPressed: () {
              widget.logger.i("ChatScreen: Settings button pressed");
              Navigator.pushNamed(context, '/settings');
            },
            icon: const Icon(Icons.settings_outlined),
          ),
        ],
      ),
      backgroundColor: Theme.of(context).colorScheme.onPrimary,
      body: Stack(children: [
        Column(
          children: [
            Expanded(
              child: isGettingChat
                  ? Container(
                      alignment: Alignment.center,
                      child: const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(height: 16.0),
                          Text(
                            "Getting chat...",
                            style: TextStyle(
                              fontSize: 16.0,
                              fontWeight: FontWeight.w400,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      child: SingleChildScrollView(
                        child: _renderChat(chat),
                      ),
                      onRefresh: () async {
                        await Future.delayed(const Duration(seconds: 1));
                        _getChat(user.id, chatIndex);
                      }),
            ),
            Container(
              padding: const EdgeInsets.all(8.0),
              decoration: const BoxDecoration(
                color: Colors.transparent,
              ),
              child: Container(
                decoration: BoxDecoration(
                  // borderRadius: BorderRadius.circular(16.0),
                  borderRadius: BorderRadius.circular(16.0),
                  color: Theme.of(context).colorScheme.onBackground,
                ),
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    audioPath.isNotEmpty
                        ? Row(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  color: const Color(0xff2e2e2e),
                                  borderRadius: BorderRadius.circular(32.0),
                                ),
                                child: Row(
                                  children: [
                                    GestureDetector(
                                      onTap: !isProcessing ? deleteAudio : null,
                                      child: Container(
                                        height: 48,
                                        width: 48,
                                        decoration: BoxDecoration(
                                          gradient: const LinearGradient(
                                            colors: [
                                              Color(0xFF277AFF),
                                              Color(0xFF12307C),
                                            ],
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(32.0),
                                        ),
                                        alignment: Alignment.center,
                                        child: const Icon(
                                          Icons.delete_outline,
                                          size: 24.0,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    GestureDetector(
                                      onTap: playPauseAudio,
                                      child: Container(
                                        height: 48,
                                        width: 48,
                                        decoration: BoxDecoration(
                                          gradient: const LinearGradient(
                                            colors: [
                                              Color(0xFF277AFF),
                                              Color(0xFF12307C),
                                            ],
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(32.0),
                                        ),
                                        alignment: Alignment.center,
                                        child: Icon(
                                          isPlaying
                                              ? Icons.pause
                                              : Icons.play_arrow,
                                          size: 24.0,
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                            ],
                          )
                        : Text("Press to ${isRecording ? 'stop' : 'record'}",
                            style: Theme.of(context).textTheme.titleLarge),
                    GestureDetector(
                      onTap: audioPath.isNotEmpty
                          // ? sendMessage
                          ? processAudio
                          : isRecording
                              ? stopRecording
                              : startRecording,
                      child: Container(
                        width: 64,
                        height: 64,
                        padding: const EdgeInsets.all(16.0),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              Color(0xFF277AFF),
                              Color(0xFF12307C),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(32.0),
                        ),
                        child: Icon(
                          audioPath.isNotEmpty
                              ? Icons.send
                              : isRecording
                                  ? Icons.stop
                                  : Icons.graphic_eq,
                          size: 24.0,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ]),
    );
  }

  ScrollController _scrollController = ScrollController();

  Widget _renderChat(List<ChatMessage> chat) {
    if (chat.isEmpty) {
      return Center(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 48.0, horizontal: 16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                Icons.chat_bubble_outline,
                size: 64.0,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 0.0),
              Text(
                "No messages yet...",
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.grey[400],
                    ),
              ),
              const SizedBox(height: 48.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Make a question by tapping the",
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.grey[400],
                        ),
                  ),
                  const SizedBox(width: 4.0),
                  Icon(
                    Icons.graphic_eq,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(width: 4.0),
                  Text(
                    "button",
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.grey[400],
                        ),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Stop recording by tapping the",
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.grey[400],
                        ),
                  ),
                  const SizedBox(width: 4.0),
                  Icon(
                    Icons.stop,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(width: 4.0),
                  Text(
                    "button",
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.grey[400],
                        ),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Send the recording by tapping the",
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.grey[400],
                        ),
                  ),
                  const SizedBox(width: 4.0),
                  Icon(
                    Icons.send,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(width: 4.0),
                  Text(
                    "button",
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.grey[400],
                        ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      controller: _scrollController,
      physics: const BouncingScrollPhysics(),
      itemCount: chat.length,
      itemBuilder: (BuildContext context, int index) {
        return MessageComponent(
          chat[index],
        );
      },
    );
  }

  Future<void> processAudio() async {
    if (!isProcessing) {
      if (chatIndex.isEmpty) {
        String id = await chatService.create(user.id);
        setState(() {
          chatIndex = id;
        });

        widget.logger.i("ChatScreen: Chat created successfully: $chatIndex");
      }

      setState(() {
        isProcessing = true;
      });

      try {
        // Add user message to chat and store its index
        final int userMessageIndex = chat.length;

        // Create the audio as base64 string
        final String audioBase64 = await audioService.encodeAudio(audioPath);

        setState(() {
          chat.add(ChatMessage(
              isLoading: true,
              id: "",
              audio: audioBase64,
              audioUrl: "",
              isUser: true,
              content: "Processing transcript...",
              createdAt: DateTime.now().toString(),
              updatedAt: DateTime.now().toString(),
              chatId: chatIndex));
        });

        // Create the response message and store its index for later updating
        final int responseMessageIndex = chat.length;

        setState(() {
          chat.add(ChatMessage(
              isLoading: true,
              id: "",
              audio: "",
              audioUrl: "",
              isUser: false,
              content: "",
              createdAt: DateTime.now().toString(),
              updatedAt: DateTime.now().toString(),
              chatId: chatIndex));
        });

        final AudioProcessingResult result =
            await audioService.postAudio(audioPath, user.mode, chatIndex);

        if (result.statusCode == 200) {
          widget.logger.i("ChatScreen: Audio processed successfully");

          // Handle the success case: Destructure the result and add it to the chat
          final AudioContent question = result.question;
          final AudioContent answer = result.answer;

          // Update the user message with the question text
          setState(() {
            chat[userMessageIndex].content = question.text;
            chat[userMessageIndex].isLoading = false;

            chat[responseMessageIndex].content = answer.text;
            chat[responseMessageIndex].audio = answer.audio;
            chat[responseMessageIndex].isLoading = false;
          });

          audioPath = "";
        } else {
          widget.logger.e("ChatScreen: Error processing audio");

          // Handle the error case: Show a snackbar with a generic error message
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            behavior: SnackBarBehavior.floating,
            content:
                Text("Error: Could not process audio - ${result.statusCode}"),
            backgroundColor: Theme.of(context).colorScheme.error,
          ));
        }
      } catch (e) {
        // remove the last two messages (if they exist)
        if (chat.length >= 2) {
          chat.removeLast();
          chat.removeLast();
        }

        widget.logger.e("ChatScreen: Error processing audio - $e");

        // Handle unexpected errors: Show a snackbar with a generic error message
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          behavior: SnackBarBehavior.floating,
          content: const Text("Unexpected Error: Could not process audio"),
          backgroundColor: Theme.of(context).colorScheme.error,
        ));
      }

      setState(() {
        isProcessing = false;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        behavior: SnackBarBehavior.floating,
        content: Text("Please wait for the current audio to finish"),
      ));
    }
  }

  Future<void> playPauseAudio() async {
    try {
      if (isPlaying) {
        await audioPlayer.pause();
        setState(() {
          isPlaying = false;
        });
      } else {
        Source urlSource = UrlSource(audioPath);
        await audioPlayer.play(urlSource);

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

  Future<void> startRecording() async {
    try {
      if (await audioRecord.hasPermission()) {
        await audioRecord.start();

        setState(() {
          isRecording = true;
        });
      }
    } catch (e) {
      widget.logger.e("ChatScreen: Error starting recording - $e");

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text("Error: Could not start recording"),
        ),
      );
    }
  }

  Future<void> stopRecording() async {
    try {
      String? path = await audioRecord.stop();

      setState(() {
        isRecording = false;
        audioPath = path!;
      });
    } catch (e) {
      widget.logger.e("ChatScreen: Error stopping recording - $e");
    }
  }

  void deleteAudio() {
    setState(() {
      audioPath = "";
    });
  }

  bool isGettingChat = false;

  Future<void> _getChat(String userId, String id) async {
    setState(() {
      isGettingChat = true;
      chat.clear();
    });

    widget.logger.i("Home: Getting chat $id");

    try {
      List<ChatMessage> getChat = await chatService.getChat(userId, id);

      widget.logger.i("Home: Chat $id retrieved successfully");

      setState(() {
        chat.addAll(getChat);
        isGettingChat = false;
      });
    } catch (e) {
      widget.logger.e("Home: Error getting chat $id: $e");

      setState(() {
        isGettingChat = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Error getting chat data'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );

      Navigator.of(context).pop();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args != null && args is String) {
      setState(() {
        chatIndex = args;
      });

      // Now you can use chatIndex here
      _getChat(user.id, chatIndex);
    }
  }

  @override
  void initState() {
    chatService = ChatService(widget.logger);
    audioService = AudioService(widget.logger);
    user = widget.ref.read(userProvider).get();

    super.initState();

    if (chatIndex.isNotEmpty) {
      widget.logger.i("ChatScreen: Chat index is not empty: $chatIndex");
      _getChat(user.id, chatIndex);
    }
  }
}
