import 'package:demeterapp/app/data/models/auth/user_model.dart';

class AuthResponse {
  final String accessToken;
  final String refreshToken;
  final String tokenType;
  final UserModel user;

  AuthResponse({
    required this.accessToken,
    required this.refreshToken,
    required this.tokenType,
    required this.user,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    final tokens = json['tokens'] as Map<String, dynamic>;
    return AuthResponse(
      accessToken: tokens['access_token'] as String,
      refreshToken: tokens['refresh_token'] as String,
      tokenType: tokens['token_type'] as String? ?? 'bearer',
      user: UserModel.fromJson(json['user'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'access_token': accessToken,
      'refresh_token': refreshToken,
      'token_type': tokenType,
      'user': user.toJson(),
    };
  }

  AuthResponse copyWith({
    String? accessToken,
    String? refreshToken,
    String? tokenType,
    UserModel? user,
  }) {
    return AuthResponse(
      accessToken: accessToken ?? this.accessToken,
      refreshToken: refreshToken ?? this.refreshToken,
      tokenType: tokenType ?? this.tokenType,
      user: user ?? this.user,
    );
  }

  @override
  String toString() {
    return 'AuthResponse(user: $user, tokenType: $tokenType)';
  }
}
