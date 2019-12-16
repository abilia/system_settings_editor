import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenDb {
  final String _tokenKey = 'tokenKey';
  final FlutterSecureStorage secureStorage;

  TokenDb() : secureStorage = FlutterSecureStorage();

  Future<void> delete() async {
    await secureStorage.delete(key: _tokenKey);
  }

  Future<void> persistToken(String token) =>
      secureStorage.write(key: _tokenKey, value: token);

  Future<String> getToken() => secureStorage.read(key: _tokenKey);
}
