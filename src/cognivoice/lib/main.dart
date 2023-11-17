import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cognivoice/screens/select_mode.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:cognivoice/screens/settings.dart';
import 'package:cognivoice/screens/login.dart';
import 'package:cognivoice/screens/home.dart';
import 'package:cognivoice/screens/chat.dart';
import 'package:cognivoice/screens/work.dart';
import 'package:cognivoice/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:loggerw/loggerw.dart';

Future main() async {
  await dotenv.load(fileName: ".env");

  var logger = Logger(
    level: Level.debug,
    printer: PrettyPrinter(
      methodCount: 0,
      errorMethodCount: 8,
      colors: true,
      printEmojis: true,
      printTime: true,
    ),
    apiUrl: "${dotenv.env['LOG_API_URL']}/logs",
  );

  runApp(ProviderScope(child: CogniVoice(logger)));
}

class CogniVoice extends ConsumerWidget {
  const CogniVoice(this.logger, {Key? key}) : super(key: key);

  final Logger logger;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'Cogni Voice',
      theme: ThemeData(
        colorScheme: CogniVoiceTheme.colorScheme,
        textTheme: CogniVoiceTheme.textTheme,
        fontFamily: 'IBMPlexSans-Regular',
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      initialRoute: '/login',
      routes: <String, WidgetBuilder>{
        '/work': (BuildContext context) =>
            Work(context: context, ref: ref, logger: logger),
        '/login': (BuildContext context) => Login(ref: ref, logger: logger),
        '/select-mode': (BuildContext context) =>
            SelectMode(context: context, ref: ref, logger: logger),
        '/home': (BuildContext context) =>
            Home(context: context, ref: ref, logger: logger),
        '/settings': (BuildContext context) =>
            Settings(context: context, ref: ref, logger: logger),
        '/chat': (BuildContext context) =>
            ChatScreen(context: context, ref: ref, logger: logger),
      },
    );
  }
}
