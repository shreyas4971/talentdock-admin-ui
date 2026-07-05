class SecureStorage {
  String? _token;

  Future<String?> getToken() async => _token;
  
  Future<void> saveToken(String token) async {
    _token = token;
  }

  Future<void> clear() async {
    _token = null;
  }
}
