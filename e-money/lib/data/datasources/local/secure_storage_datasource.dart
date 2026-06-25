import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/error/exceptions.dart';

abstract class SecureStorageDatasource {
  Future<void> saveToken(String token);
  Future<String?> getToken();
  Future<void> deleteToken();
  Future<void> save2faMethod(String method);
  Future<String?> get2faMethod();
  Future<void> saveUserJson(String json);
  Future<String?> getUserJson();
  Future<void> saveAuthVerified(bool verified);
  Future<bool> getAuthVerified();
  Future<void> clearAll();
}

class SecureStorageDatasourceImpl implements SecureStorageDatasource {
  final FlutterSecureStorage _storage;

  SecureStorageDatasourceImpl(this._storage);

  @override
  Future<void> saveToken(String token) async {
    try {
      await _storage.write(key: AppConstants.kJwtToken, value: token);
    } catch (_) {
      throw const CacheException('Gagal menyimpan token.');
    }
  }

  @override
  Future<String?> getToken() async {
    try {
      return await _storage.read(key: AppConstants.kJwtToken);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> deleteToken() async {
    await _storage.delete(key: AppConstants.kJwtToken);
  }

  @override
  Future<void> save2faMethod(String method) async {
    await _storage.write(key: AppConstants.k2faMethod, value: method);
  }

  @override
  Future<String?> get2faMethod() async {
    return _storage.read(key: AppConstants.k2faMethod);
  }

  @override
  Future<void> saveUserJson(String json) async {
    await _storage.write(key: AppConstants.kUserData, value: json);
  }

  @override
  Future<String?> getUserJson() async {
    return _storage.read(key: AppConstants.kUserData);
  }

  @override
  Future<void> saveAuthVerified(bool verified) async {
    await _storage.write(key: AppConstants.kAuthVerified, value: verified.toString());
  }

  @override
  Future<bool> getAuthVerified() async {
    final value = await _storage.read(key: AppConstants.kAuthVerified);
    return value == 'true';
  }

  @override
  Future<void> clearAll() async {
    // Hapus hanya data sesi — kPin sengaja dipertahankan (PIN adalah
    // setelan keamanan perangkat, bukan kredensial sesi).
    await Future.wait([
      _storage.delete(key: AppConstants.kJwtToken),
      _storage.delete(key: AppConstants.kUserData),
      _storage.delete(key: AppConstants.k2faMethod),
      _storage.delete(key: AppConstants.kFcmToken),
      _storage.delete(key: AppConstants.kAuthVerified),
    ]);
  }
}
