import 'package:cognivoice/components/modal.component.dart';
import 'package:cognivoice/models/userService.model.dart';
import 'package:cognivoice/providers/user.provider.dart';
import 'package:cognivoice/services/user.service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:loggerw/loggerw.dart';

class Settings extends ConsumerStatefulWidget {
  const Settings({
    Key? key,
    required this.context,
    required this.ref,
    required this.logger,
  }) : super(key: key);

  final BuildContext context;
  final WidgetRef ref;
  final Logger logger;

  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends ConsumerState<Settings> {
  bool isLoading = false;
  late final UserService userService;
  late String selectedMode;

  @override
  Widget build(BuildContext context) {
    selectedMode = widget.ref.read(userProvider).mode;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: Text(
          'Settings',
          style: TextStyle(
            fontSize: Theme.of(context).textTheme.headlineSmall!.fontSize,
            fontWeight: FontWeight.w400,
            color: Theme.of(context).colorScheme.onPrimary,
          ),
        ),
        elevation: 0,
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(
                  height: 16,
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Mode:", style: Theme.of(context).textTheme.bodyLarge),
                    Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: Theme.of(context)
                              .colorScheme
                              .onBackground
                              .withOpacity(0.75),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: TextButton(
                                onPressed: () {
                                  _updateSelectedMode("MarketTracker");
                                },
                                style: ElevatedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                  backgroundColor: selectedMode ==
                                          "MarketTracker"
                                      ? Theme.of(context).colorScheme.background
                                      : Colors.transparent,
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    "MarketTracker",
                                    style: TextStyle(
                                      color: selectedMode == "MarketTracker"
                                          ? Theme.of(context)
                                              .colorScheme
                                              .primary
                                          : Theme.of(context)
                                              .colorScheme
                                              .onPrimary,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: TextButton(
                                onPressed: () {
                                  _updateSelectedMode("SalesTracker");
                                },
                                style: ElevatedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                  backgroundColor: selectedMode ==
                                          "SalesTracker"
                                      ? Theme.of(context).colorScheme.background
                                      : Colors.transparent,
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    "SalesTracker",
                                    style: TextStyle(
                                      color: selectedMode == "SalesTracker"
                                          ? Theme.of(context)
                                              .colorScheme
                                              .primary
                                          : Theme.of(context)
                                              .colorScheme
                                              .onPrimary,
                                    ),
                                  ),
                                ),
                              ),
                            )
                          ],
                        )),
                  ],
                ),
                SizedBox(
                  height: 8,
                ),
                const Text(
                  'MarketTracker mode: the results of the searches will be focused on guiding texts of campaigns from other companies with decision support for Marketing campaigns.',
                  style: TextStyle(fontSize: 14),
                ),
                SizedBox(
                  height: 8,
                ),
                const Text(
                  'SalesTracker mode: the results of the searches will be focused on guiding texts of campaigns from other companies with decision support for Sales campaigns.',
                  style: TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 32),
                Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFF277AFF),
                        Color(0xFF12307C),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : _logOut,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.logout, color: Colors.white),
                          const SizedBox(width: 8.0),
                          Text('Log out',
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineSmall!
                                  .copyWith(fontWeight: FontWeight.w400))
                        ]),
                  ),
                ),
              ],
            ),
          ),
          if (isLoading) ModalLoadingOverlay(),
        ],
      ),
    );
  }

  Future<void> _updateSelectedMode(String mode) async {
    widget.logger.i('Settings: Updating to: $mode');

    try {
      if (selectedMode != mode) {
        setState(() {
          isLoading = true;
        });

        String userId = widget.ref.read(userProvider).id;
        String accessToken = widget.ref.read(userProvider).accessToken!;

        UpdateUserResponse updatedUser =
            await userService.updateUser(userId, accessToken, mode);

        GetUserResponse user = await userService.getUser(userId, accessToken);

        widget.ref.read(userProvider).update(user);

        if (updatedUser.statusCode == 200) {
          widget.logger.i("Settings: _updateSelectedMode: Updated user mode");

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Updated user mode to $mode',
                textAlign: TextAlign.center,
              ),
              behavior: SnackBarBehavior.floating,
              backgroundColor: Theme.of(context).colorScheme.primary,
            ),
          );

          setState(() {
            selectedMode = widget.ref.read(userProvider).mode;
            isLoading = false;
          });
          return;
        } else {
          widget.logger
              .e("Settings: _updateSelectedMode: Error updating user mode");

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Error updating user mode'),
              backgroundColor: Theme.of(context).colorScheme.error,
              behavior: SnackBarBehavior.floating,
            ),
          );

          setState(() {
            isLoading = false;
          });
          return;
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Error updating mode'),
          backgroundColor: Theme.of(context).colorScheme.error,
          behavior: SnackBarBehavior.floating,
        ),
      );

      widget.logger.e('SelectMode: Error updating mode: $e');
    }

    widget.logger.i('SelectMode: Selected mode: $selectedMode');
  }

  void _logOut() {
    setState(() {
      isLoading = true;
    });

    bool loggedOut = widget.ref.read(userProvider).logOut();

    if (loggedOut) {
      widget.logger.i("Settings: _logOut: Logged out");

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Logged out'),
          backgroundColor: Theme.of(context).colorScheme.primary,
          behavior: SnackBarBehavior.floating,
        ),
      );

      Navigator.pushNamedAndRemoveUntil(
        context,
        '/login',
        (Route<dynamic> route) => false,
      );
    } else {
      widget.logger.e("Settings: _logOut: Error logging out");

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Error logging out'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );

      setState(() {
        isLoading = false;
      });
      return;
    }
  }

  @override
  void initState() {
    super.initState();
    userService = UserService(widget.logger);
  }
}
