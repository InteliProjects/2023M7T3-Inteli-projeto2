class GetUserResponse {
  final String message;
  final int statusCode;
  final String id;
  final String? name;
  final String? email;
  final String? mode;
  final String? createdAt;
  final String? updatedAt;

  GetUserResponse({
    required this.message,
    required this.statusCode,
    required this.id,
    this.name,
    this.email,
    this.mode,
    this.createdAt,
    this.updatedAt,
  });
}

class UserAuthResponse {
  final int statusCode;
  final String message;
  final String id;
  final String? accessToken;
  final String? refreshToken;

  UserAuthResponse({
    this.accessToken,
    this.refreshToken,
    required this.id,
    required this.message,
    required this.statusCode,
  });
}

class UpdateUserResponse {
  final int statusCode;
  final String message;
  final GetUserResponse? user;

  UpdateUserResponse({
    required this.statusCode,
    required this.message,
    this.user,
  });
}
