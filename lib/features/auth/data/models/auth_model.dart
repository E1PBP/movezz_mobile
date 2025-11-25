/// The new AuthUser model based on your Django backend response.
/// Django returns only: username, status, message
/// No ID, no token, no email.
/// So the structure is simplified accordingly.

class AuthUser {
  final String username;
  final bool isLoggedIn;

  /// Message returned by backend (optional)
  final String? message;

  AuthUser({
    required this.username,
    required this.isLoggedIn,
    this.message,
  });

  /// Factory for login endpoint response
  factory AuthUser.fromLoginJson(Map<String, dynamic> json) {
    return AuthUser(
      username: json['username']?.toString() ?? '',
      isLoggedIn: json['status'] == true,
      message: json['message'],
    );
  }

  /// Factory for register endpoint response
  factory AuthUser.fromRegisterJson(Map<String, dynamic> json) {
    final status = json['status'];

    return AuthUser(
      username: json['username']?.toString() ?? '',
      isLoggedIn: status == true || status == 'success',
      message: json['message'],
    );
  }
}
