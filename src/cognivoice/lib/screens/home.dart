import 'package:cognivoice/models/chat.model.dart';
import 'package:cognivoice/providers/user.provider.dart';
import 'package:cognivoice/services/chat.service.dart';
import 'package:cognivoice/services/user.service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:loggerw/loggerw.dart';

enum TimeOfDay {
  morning,
  afternoon,
  night,
}

class Home extends ConsumerStatefulWidget {
  const Home(
      {Key? key,
      required this.context,
      required this.ref,
      required this.logger})
      : super(key: key);

  final BuildContext context;
  final WidgetRef ref;
  final Logger logger;

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends ConsumerState<Home> {
  @override
  Widget build(BuildContext context) {
    user = ref.read(userProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: RefreshIndicator(
        onRefresh: () async {
          getHistory();
        },
        child: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    const SizedBox(
                      height: 72,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                  "Good ${timeOfDay.toString().split('.').last},\n${user.name.split(' ')[0]}!",
                                  style: TextStyle(
                                    fontSize: Theme.of(context)
                                        .textTheme
                                        .headlineLarge!
                                        .fontSize,
                                    fontWeight: FontWeight.w400,
                                    color:
                                        Theme.of(context).colorScheme.onPrimary,
                                  )),
                              Text("Search with CogniVoice",
                                  style: TextStyle(
                                    fontSize: Theme.of(context)
                                        .textTheme
                                        .headlineSmall!
                                        .fontSize,
                                    fontWeight: FontWeight.w300,
                                    color:
                                        Theme.of(context).colorScheme.onPrimary,
                                  ),
                                  softWrap: true),
                            ]),
                        IconButton(
                          onPressed: () {
                            widget.logger.i("Home: Settings button clicked");
                            Navigator.pushNamed(context, "/settings");
                          },
                          icon: Icon(
                            Icons.settings_outlined,
                            size: 28,
                            color: Theme.of(context).colorScheme.onPrimary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          "Prompts",
                          style: TextStyle(
                            fontSize: Theme.of(context)
                                .textTheme
                                .headlineSmall!
                                .fontSize,
                            fontWeight: FontWeight.w400,
                            color: Theme.of(context).colorScheme.onPrimary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  height: 200,
                  child: ListView.builder(
                    itemBuilder: (BuildContext context, int index) {
                      return PromptCard(
                        title: prompts[index]["title"]!,
                        description: prompts[index]["description"]!,
                      );
                    },
                    itemCount: prompts.length,
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                  )),
              const SizedBox(
                height: 8.0,
              ),
              Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "History",
                                style: TextStyle(
                                  fontSize: Theme.of(context)
                                      .textTheme
                                      .headlineSmall!
                                      .fontSize,
                                  fontWeight: FontWeight.w400,
                                  color:
                                      Theme.of(context).colorScheme.onPrimary,
                                ),
                              ),
                              IconButton(
                                onPressed: () {
                                  getHistory();
                                },
                                icon: Icon(
                                  Icons.refresh_outlined,
                                  size: 24,
                                  color:
                                      Theme.of(context).colorScheme.onPrimary,
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                      loadingHistory
                          ? const SizedBox(
                              height: 200,
                              child: Center(
                                child: CircularProgressIndicator(),
                              ),
                            )
                          : history.length > 0
                              ? ListView.builder(
                                  reverse: true,
                                  shrinkWrap: true,
                                  physics: const BouncingScrollPhysics(),
                                  itemCount: history.length,
                                  padding: const EdgeInsets.only(top: 8.0),
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    return GestureDetector(
                                      onTap: () {
                                        widget.logger.i(
                                            "Home: Navigating to chat ${history[index].id}");
                                        Navigator.pushNamed(context, "/chat",
                                            arguments:
                                                history[index].id.toString());
                                      },
                                      onLongPress: () {
                                        _deleteModal(history[index].id);
                                      },
                                      child: Column(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(16.0),
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .primary
                                                  .withOpacity(0.075),
                                            ),
                                            child: Row(
                                              children: [
                                                const Icon(
                                                  Icons.chat_outlined,
                                                  size: 24.0,
                                                ),
                                                const SizedBox(
                                                  width: 8.0,
                                                ),
                                                Flexible(
                                                  child: Text(
                                                    history[index].lastMessage,
                                                    softWrap: true,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    maxLines: 2,
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .bodyLarge,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(
                                            height: 16.0,
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                )
                              : SizedBox(
                                  height: 64,
                                  child: Center(
                                    child: Text("No history yet...",
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall),
                                  ),
                                ),
                    ],
                  )),
              const SizedBox(
                height: 96.0,
              )
            ],
          ),
        ),
      ),
      floatingActionButton: Container(
        margin: const EdgeInsets.only(bottom: 8.0, left: 16.0, right: 16.0),
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.0),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF0062FF),
              Color(0xff12307C),
            ],
          ),
        ),
        child: FloatingActionButton.extended(
          onPressed: _createChat,
          backgroundColor: Colors.transparent,
          label: Text(
            "Go chat",
            style: TextStyle(
              fontSize: Theme.of(context).textTheme.headlineSmall!.fontSize,
              fontWeight: FontWeight.w400,
              color: Theme.of(context).colorScheme.onPrimary,
            ),
          ),
          elevation: 0,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButtonAnimator: FloatingActionButtonAnimator.scaling,
    );
  }

  late User user;
  late UserService userService;

  late TimeOfDay timeOfDay;
  final List<Map<String, String>> prompts = [
    {
      "title": "Campaign strategies",
      "description": "Provide support for marketing decisions."
    },
    {
      "title": "Customer support",
      "description": "Help your customers with their questions."
    },
    {
      "title": "Market trends",
      "description": "Have an overview of the main world topics!"
    },
    {
      "title": "Sales insights",
      "description": "Get insights on how to improve your sales."
    },
  ];

  late ChatService chatService;
  bool loadingHistory = true;
  List<ChatModel> history = [];

  void _deleteChat(String chatId) async {
    widget.logger.d("Chat ID: $chatId");
    widget.logger.d("User ID: ${user.id}");

    try {
      widget.logger.i("Home: Deleting chat");

      await chatService.deleteChat(user.id, chatId);

      _getHistory();

      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Chat deleted successfully!'),
          duration: Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      widget.logger.e("Home: Error deleting chat: $e");

      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error deleting chat: $e'),
          duration: const Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  void _deleteModal(String chatId) async {
    widget.logger.i("Home: Deleting chat $chatId");

    showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.background,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16.0),
                topRight: Radius.circular(16.0),
              ),
            ),
            height: 200,
            child: Column(
              children: [
                const SizedBox(
                  height: 16.0,
                ),
                Text(
                  "Delete chat",
                  style: TextStyle(
                    fontSize:
                        Theme.of(context).textTheme.headlineSmall!.fontSize,
                    fontWeight: FontWeight.w400,
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                ),
                const SizedBox(
                  height: 16.0,
                ),
                Text(
                  "Are you sure you want to delete this chat?",
                  style: TextStyle(
                    fontSize: Theme.of(context).textTheme.bodyMedium!.fontSize,
                    fontWeight: FontWeight.w400,
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                ),
                const SizedBox(
                  height: 16.0,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        primary: Theme.of(context).colorScheme.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                      child: Text(
                        "Cancel",
                        style: TextStyle(
                          fontSize: Theme.of(context)
                              .textTheme
                              .headlineSmall!
                              .fontSize,
                          fontWeight: FontWeight.w400,
                          color: Theme.of(context).colorScheme.onPrimary,
                        ),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        _deleteChat(chatId);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.error,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                      child: Text(
                        "Delete",
                        style: TextStyle(
                          fontSize: Theme.of(context)
                              .textTheme
                              .headlineSmall!
                              .fontSize,
                          fontWeight: FontWeight.w400,
                          color: Theme.of(context).colorScheme.onPrimary,
                        ),
                      ),
                    ),
                  ],
                )
              ],
            ),
          );
        });
  }

  void _getHistory() async {
    widget.logger.i("Home: Getting history");

    List<ChatModel> chats = await chatService.getAllChats(user.id);

    setState(() {
      history = chats;
      loadingHistory = false;
    });
  }

  Future<void> getHistory() async {
    setState(() {
      loadingHistory = true;
    });

    final List<ChatModel> chats = await chatService.getAllChats(user.id);

    setState(() {
      history = chats;
      loadingHistory = false;
    });
  }

  void _createChat() {
    widget.logger.i("Home: Creating chat");

    Navigator.pushNamed(context, "/chat");
  }

  // runs when user gets back to this screen
  @override
  void didChangeDependencies() {
    widget.logger.i("Home: Changing dependencies");

    super.didChangeDependencies();
  }

  final routeObserverProvider =
      Provider<RouteObserver>((ref) => RouteObserver());

  @override
  void initState() {
    widget.logger.i("Home: Initializing state");

    DateTime now = DateTime.now();
    int hour = now.hour;

    if (hour >= 5 && hour < 12) {
      timeOfDay = TimeOfDay.morning;
    } else if (hour >= 12 && hour < 18) {
      timeOfDay = TimeOfDay.afternoon;
    } else {
      timeOfDay = TimeOfDay.night;
    }

    chatService = ChatService(widget.logger);

    user = ref.read(userProvider);
    _getHistory();

    super.initState();
  }

  @override
  void dispose() {
    widget.logger.i("Home: Disposing");

    super.dispose();
  }
}

class PromptCard extends StatelessWidget {
  final String title;
  final String description;

  const PromptCard({super.key, required this.title, required this.description});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const SizedBox(
          width: 16,
        ),
        Container(
          width: 200,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF0054DC),
                Color.fromARGB(255, 15, 40, 103),
              ],
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  textAlign: TextAlign.start,
                  style: TextStyle(
                    fontSize:
                        Theme.of(context).textTheme.displaySmall!.fontSize,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                ),
                const SizedBox(
                  height: 4,
                ),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: Theme.of(context).textTheme.bodyLarge!.fontSize,
                    fontWeight: FontWeight.w400,
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(
          width: 8,
        )
      ],
    );
  }
}
