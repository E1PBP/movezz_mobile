import '../datasources/auth_remote_data_source.dart';
import '../models/auth_model.dart';

abstract class AuthRepository {
  Future<AuthUser> login(String username, String password);
  Future<AuthUser> register(
    String username,
    String email,
    String password, {
    String? phone,
  });
}

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remote;

  AuthRepositoryImpl(this.remote);

  @override
  Future<AuthUser> login(String username, String password) {
    return remote.login(username: username, password: password);
  }

  @override
  Future<AuthUser> register(
    String username,
    String email,
    String password, {
    String? phone,
  }) {
    return remote.register(
      username: username,
      email: email,
      password: password,
      phone: phone,
    );
  }
}
