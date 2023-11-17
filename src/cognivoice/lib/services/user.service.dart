import 'package:cognivoice/models/userService.model.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:loggerw/loggerw.dart';
import 'dart:convert';

class UserService {
  final Logger logger;
  final String? apiUrl;

  UserService(this.logger) : apiUrl = dotenv.env['API_URL'];

  Future<UserAuthResponse> auth(String email, String password) async {
    const path = "user/auth";
    logger.d("UserService: auth: $apiUrl/$path");

    if (apiUrl == null) {
      logger.e("AudioService: API_URL not found");
      return UserAuthResponse(
          message: "API_URL not found", statusCode: -1, id: "");
    }

    if (email.isEmpty || password.isEmpty) {
      logger.e("UserService: auth: Email or password is empty");
      return UserAuthResponse(
        message: "Email or password is empty",
        statusCode: -1,
        id: "",
      );
    }

    final response = await http.post(
      Uri.parse("$apiUrl/$path"),
      headers: {
        "Content-Type": "application/json",
      },
      body: jsonEncode(<String, String>{
        "email": email,
        "password": password,
      }),
    );

    logger
        .d("UserService: auth: Response status code - ${response.statusCode}");

    final jsonResponse = json.decode(response.body);

    if (response.statusCode == 200) {
      logger.i("UserService: auth: Response success");

      final String message = jsonResponse['message'];
      final String accessToken = jsonResponse['access_token'];
      final String refreshToken = jsonResponse['refresh_token'];
      final String id = jsonResponse['id'];

      return UserAuthResponse(
        id: id,
        message: message,
        statusCode: response.statusCode,
        accessToken: accessToken,
        refreshToken: refreshToken,
      );
    } else {
      logger.e("UserService: auth: Response error - ${response.body}");

      final String error = jsonResponse['message'];

      return UserAuthResponse(
          message: error, statusCode: response.statusCode, id: "");
    }
  }

  Future<GetUserResponse> getUser(String userId, String accessToken) async {
    final path = "user/$userId";
    logger.d("UserService: getUser: $apiUrl/$path");

    if (apiUrl == null) {
      logger.e("AudioService: API_URL not found");
      return GetUserResponse(
          message: "API_URL not found", statusCode: -1, id: "");
    }

    if (userId.isEmpty || accessToken.isEmpty) {
      logger.e("UserService: getUser: userId or accessToken is empty");
      return GetUserResponse(
        message: "userId or accessToken is empty",
        statusCode: -1,
        id: "",
      );
    }

    final response = await http.get(
      Uri.parse("$apiUrl/$path"),
      headers: {
        "Authorization": accessToken,
      },
    );

    logger.d(
        "UserService: getUser: Response status code - ${response.statusCode}");

    final jsonResponse = json.decode(response.body);

    if (response.statusCode == 200) {
      logger.i("UserService: getUser: Response success");

      final String id = jsonResponse['id'];
      final String email = jsonResponse['email'];
      final String name = jsonResponse['name'];
      final String createdAt = jsonResponse['createdAt'];
      final String updatedAt = jsonResponse['updatedAt'];
      final String? mode = jsonResponse['mode'];

      return GetUserResponse(
        statusCode: response.statusCode,
        id: id,
        email: email,
        name: name,
        mode: mode,
        createdAt: createdAt,
        updatedAt: updatedAt,
        message: "",
      );
    } else {
      logger.e("UserService: getUser: Response error - ${response.body}");

      final String error = jsonResponse['error'];

      return GetUserResponse(
          message: error, statusCode: response.statusCode, id: "");
    }
  }

  Future<UpdateUserResponse> updateUser(
      String userId, String accessToken, String mode) async {
    final path = "user/$userId";
    logger.d("UserService: updateUser: $apiUrl/$path");

    if (apiUrl == null) {
      logger.e("AudioService: API_URL not found");
      return UpdateUserResponse(message: "API_URL not found", statusCode: -1);
    }

    if (userId.isEmpty || accessToken.isEmpty) {
      logger.e("UserService: updateUser: userId or accessToken is empty");
      return UpdateUserResponse(
          message: "userId or accessToken is empty", statusCode: -1);
    }

    final response = await http.put(
      Uri.parse("$apiUrl/$path"),
      headers: {
        "Authorization": accessToken,
        "Content-Type": "application/json",
      },
      body: jsonEncode(<String, String>{
        "mode": mode,
      }),
    );

    logger.d(
        "UserService: updateUser: Response status code - ${response.statusCode}");

    final jsonResponse = json.decode(response.body);

    if (response.statusCode == 200) {
      logger.i("UserService: updateUser: Response success");

      final String message = jsonResponse['message'];
      final String id = jsonResponse['user']['id'];
      final String email = jsonResponse['user']['email'];
      final String name = jsonResponse['user']['name'];
      final String createdAt = jsonResponse['user']['createdAt'];
      final String updatedAt = jsonResponse['user']['updatedAt'];
      final String mode = jsonResponse['user']['mode'];

      return UpdateUserResponse(
        statusCode: response.statusCode,
        message: message,
        user: GetUserResponse(
          statusCode: response.statusCode,
          id: id,
          email: email,
          name: name,
          mode: mode,
          createdAt: createdAt,
          updatedAt: updatedAt,
          message: "",
        ),
      );
    } else {
      logger.e("UserService: updateUser: Response error - ${response.body}");

      final String error = jsonResponse['error'];

      return UpdateUserResponse(
          message: error, statusCode: response.statusCode);
    }
  }
}
