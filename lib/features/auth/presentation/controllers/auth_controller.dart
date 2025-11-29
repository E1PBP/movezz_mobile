import 'package:flutter/foundation.dart';
import '../../data/models/auth_model.dart';
import '../../data/repositories/auth_repository.dart';

class AuthController extends ChangeNotifier {
  final AuthRepository _repository;

  AuthController(this._repository);

  AuthUser? currentUser;
  bool isLoading = false;
  String? error;

  Future<bool> login(String username, String password) async {
    try {
      isLoading = true;
      error = null;
      notifyListeners();

      currentUser = await _repository.login(username, password);

      isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      isLoading = false;
      error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> register(
    String username,
    String email,
    String password, {
    String? phone,
  }) async {
    try {
      isLoading = true;
      error = null;
      notifyListeners();

      currentUser = await _repository.register(
        username,
        email,
        password,
        phone: phone,
      );

      isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      isLoading = false;
      error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> logout() async {
    try {
      isLoading = true;
      notifyListeners();

      await _repository.logout();
      currentUser = null;
      error = null;
      
      isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      isLoading = false;
      error = e.toString();
      notifyListeners();
      return false;
    }
  }
}
