import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:movezz_mobile/core/utils/session_guard.dart';

class GuardedCookieRequest extends CookieRequest {
  @override
  Future<dynamic> get(String url) async {
    final response = await super.get(url);
    return SessionGuard.validate(response);
  }

  @override
  Future<dynamic> post(String url, dynamic data) async {
    final response = await super.post(url, data);
    return SessionGuard.validate(response);
  }

  @override
  Future<dynamic> postJson(String url, dynamic data) async {
    final response = await super.postJson(url, data);
    return SessionGuard.validate(response);
  }
}
