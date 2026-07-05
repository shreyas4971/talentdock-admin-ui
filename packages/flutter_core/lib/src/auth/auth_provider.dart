import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../state/talent_state.dart';
import '../domain/result.dart';
import 'auth_repository.dart';
import '../storage/secure_storage.dart';

final secureStorageProvider = Provider((ref) => SecureStorage());

final authRepositoryProvider = Provider((ref) {
  final storage = ref.watch(secureStorageProvider);
  return AuthRepository(storage);
});

class AuthNotifier extends StateNotifier<TalentState<String>> {
  final AuthRepository _repository;

  AuthNotifier(this._repository) : super(TalentStateInitial());

  Future<void> checkSession() async {
    state = TalentStateLoading();
    final hasSession = await _repository.isLoggedIn();
    if (hasSession) {
      state = TalentStateSuccess('Session Restored');
    } else {
      state = TalentStateEmpty();
    }
  }

  Future<void> login(String email, String password) async {
    state = TalentStateLoading();
    final result = await _repository.login(email, password);
    
    if (result is Success<String>) {
      state = TalentStateSuccess(result.data);
    } else if (result is Failure<String>) {
      state = TalentStateError(result.error.message);
    }
  }

  Future<void> logout() async {
    await _repository.logout();
    state = TalentStateEmpty();
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, TalentState<String>>((ref) {
  final repo = ref.watch(authRepositoryProvider);
  return AuthNotifier(repo)..checkSession();
});
