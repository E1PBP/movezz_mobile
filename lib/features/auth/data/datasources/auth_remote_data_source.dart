import 'dart:convert';

import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:movezz_mobile/core/config/env.dart';
import '../models/auth_model.dart';

class AuthRemoteDataSource {
  final CookieRequest cookieRequest;

  AuthRemoteDataSource(this.cookieRequest);

  Future<AuthUser> login({
    required String username,
    required String password,
  }) async {
    final response = await cookieRequest.login(Env.api('/auth/api/login/'), {
      'username': username,
      'password': password,
    });

    if (!cookieRequest.loggedIn) {
      String msg = "Login failed";
      if (response is Map && response.containsKey('message')) {
        msg = response['message'];
      }
      throw Exception(msg);
    }

    return AuthUser.fromLoginJson(response);
  }

  Future<AuthUser> register({
    required String username,
    required String email,
    required String password,
    String? phone,
  }) async {
    final body = jsonEncode({
      'username': username,
      'password1': password,
      'password2': password,
    });

    final response =
        await cookieRequest.postJson(Env.api('/auth/api/register/'), body)
            as Map<String, dynamic>;

    if (!(response['status'] == true || response['status'] == 'success')) {
      throw Exception(response['message'] ?? "Registration failed");
    }

    return AuthUser.fromRegisterJson(response);
  }

  Future<bool> logout() async {
    await setValue('hasSeenOnboarding', false);
    final response = await cookieRequest.logout(Env.api('/auth/api/logout/'));

    if (response['status'] == true || response['status'] == 'success') {
      return true;
    } else {
      throw Exception(response['message'] ?? "Logout failed");
    }
  }
}
