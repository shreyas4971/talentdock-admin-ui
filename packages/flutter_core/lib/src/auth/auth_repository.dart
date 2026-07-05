import '../domain/result.dart';
import '../storage/secure_storage.dart';

class AuthRepository {
  final SecureStorage _storage;
  
  AuthRepository(this._storage);

  Future<Result<String>> login(String email, String password) async {
    try {
      await Future.delayed(const Duration(seconds: 1));
      if (email == 'admin@talentos.com' && password == 'password') {
        const token = 'mock_jwt_token';
        await _storage.saveToken(token);
        return Success(token);
      } else {
        return Failure(UnauthorizedError('Invalid credentials'));
      }
    } catch (e) {
      return Failure(NetworkError('Connection failed'));
    }
  }

  Future<void> logout() async {
    await _storage.clear();
  }

  Future<bool> isLoggedIn() async {
    return (await _storage.getToken()) != null;
  }
}
