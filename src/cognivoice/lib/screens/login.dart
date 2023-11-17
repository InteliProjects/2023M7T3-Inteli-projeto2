import 'package:cognivoice/components/modal.component.dart';
import 'package:cognivoice/models/userService.model.dart';
import 'package:cognivoice/providers/user.provider.dart';
import 'package:cognivoice/services/user.service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:loggerw/loggerw.dart';

class Login extends ConsumerStatefulWidget {
  const Login({Key? key, required this.ref, required this.logger})
      : super(key: key);

  final WidgetRef ref;
  final Logger logger;

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends ConsumerState<Login> {
  final _formKey = GlobalKey<FormState>();
  final emailController = TextEditingController(text: "user@ibm.com");
  final passwordController = TextEditingController(text: "senha123");
  late final UserService userService;

  bool isLoading = false;

  Future<void> _submitHandler() async {
    if (!isLoading) {
      // Check if not already loading
      widget.logger.i('Login: Login button pressed');

      if (_formKey.currentState!.validate()) {
        setState(() {
          isLoading = true;
        });

        UserAuthResponse response = await userService.auth(
          emailController.text,
          passwordController.text,
        );

        widget.logger.d('Login: Response status code - ${response.statusCode}');

        if (response.statusCode == 200) {
          widget.logger.i('Login: Login success');

          GetUserResponse user = await userService.getUser(
            response.id,
            response.accessToken!,
          );

          widget.logger.d('Login: User - ${user.email}');

          widget.ref.read(userProvider).auth(user, response);

          setState(() {
            isLoading = false;
          });

          if (widget.ref.read(userProvider).mode.isNotEmpty) {
            widget.logger.i('Login: User has mode: ${user.mode}');

            Navigator.pushNamedAndRemoveUntil(
              context,
              "/home",
              (route) => false,
            );
          } else {
            widget.logger.i('Login: User has no mode');

            Navigator.pushNamedAndRemoveUntil(
              context,
              "/select-mode",
              (route) => false,
            );
          }
        } else {
          widget.logger.e('Login: Login failed');

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                response.message,
                textAlign: TextAlign.center,
              ),
              behavior: SnackBarBehavior.floating,
              backgroundColor: Colors.red,
            ),
          );

          setState(() {
            isLoading = false;
          });
        }
      } else {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  const SizedBox(height: 64),
                  // Logo
                  Image.asset(
                    'assets/logo.png',
                    width: 200.0,
                    height: 100.0,
                  ),
                  const SizedBox(height: 128),

                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      TextFormField(
                        textInputAction: TextInputAction.next,
                        controller: emailController,
                        autocorrect: false,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            widget.logger
                                .e('Login: Email field validation error');
                            return "Please enter your email";
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderSide: const BorderSide(
                              color: Colors.grey,
                              width: 1.0,
                            ),
                            borderRadius: BorderRadius.circular(5.0),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Theme.of(context).colorScheme.primary,
                              width: 2.0,
                            ),
                            borderRadius: BorderRadius.circular(5.0),
                          ),
                          labelText: 'Email',
                        ),
                      ),
                      const SizedBox(height: 24),
                      TextFormField(
                        textInputAction: TextInputAction.done,
                        obscureText: true,
                        controller: passwordController,
                        autocorrect: false,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            widget.logger
                                .e('Login: Password field validation error');
                            return 'Please enter your password';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderSide: const BorderSide(
                              color: Colors.grey,
                              width: 1.0,
                            ),
                            borderRadius: BorderRadius.circular(5.0),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Theme.of(context).colorScheme.primary,
                              width: 2.0,
                            ),
                            borderRadius: BorderRadius.circular(5.0),
                          ),
                          labelText: 'Password',
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextButton(
                        onPressed: () {
                          widget.logger
                              .i('Login: Forgot password button pressed');
                        },
                        child: Text(
                          'Forgot password?',
                          style: TextStyle(
                            fontSize:
                                Theme.of(context).textTheme.bodySmall!.fontSize,
                            fontWeight: Theme.of(context)
                                .textTheme
                                .bodySmall!
                                .fontWeight,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          textAlign: TextAlign.end,
                        ),
                      ),
                    ],
                  ),

                  // Login button
                  const SizedBox(height: 20),
                  Container(
                    width: double.infinity,
                    height: 50,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFF277AFF),
                          Color(0xFF12307C),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: ElevatedButton(
                      onPressed: isLoading ? null : () => _submitHandler(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        'Login',
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
          if (isLoading) ModalLoadingOverlay(),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    userService = UserService(widget.logger);
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();

    super.dispose();
  }
}
