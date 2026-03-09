import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';

/// 安全存储
class SecureStorage {
  SecureStorage._internal();
  factory SecureStorage() => _instance;
  static final SecureStorage _instance = SecureStorage._internal();

  final _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock,
    ),
  );

  /// 保存数据
  Future<void> write({
    required String key,
    required String value,
    bool encrypt = false,
  }) async {
    try {
      final dataToStore = encrypt ? _encrypt(value) : value;
      await _storage.write(key: key, value: dataToStore);
    } catch (e) {
      debugPrint('Failed to write secure data: $e');
      rethrow;
    }
  }

  /// 读取数据
  Future<String?> read({
    required String key,
    bool decrypt = false,
  }) async {
    try {
      final value = await _storage.read(key: key);
      if (value == null) return null;
      return decrypt ? _decrypt(value) : value;
    } catch (e) {
      debugPrint('Failed to read secure data: $e');
      return null;
    }
  }

  /// 删除数据
  Future<void> delete({required String key}) async {
    try {
      await _storage.delete(key: key);
    } catch (e) {
      debugPrint('Failed to delete secure data: $e');
      rethrow;
    }
  }

  /// 删除所有数据
  Future<void> deleteAll() async {
    try {
      await _storage.deleteAll();
    } catch (e) {
      debugPrint('Failed to delete all secure data: $e');
      rethrow;
    }
  }

  /// 检查键是否存在
  Future<bool> containsKey({required String key}) async {
    try {
      return await _storage.containsKey(key: key);
    } catch (e) {
      debugPrint('Failed to check key: $e');
      return false;
    }
  }

  /// 获取所有键
  Future<Map<String, String>> readAll() async {
    try {
      return await _storage.readAll();
    } catch (e) {
      debugPrint('Failed to read all: $e');
      return {};
    }
  }

  /// 保存 JSON 对象
  Future<void> writeJson({
    required String key,
    required Map<String, dynamic> value,
    bool encrypt = false,
  }) async {
    final jsonString = jsonEncode(value);
    await write(key: key, value: jsonString, encrypt: encrypt);
  }

  /// 读取 JSON 对象
  Future<Map<String, dynamic>?> readJson({
    required String key,
    bool decrypt = false,
  }) async {
    final jsonString = await read(key: key, decrypt: decrypt);
    if (jsonString == null) return null;

    try {
      return jsonDecode(jsonString) as Map<String, dynamic>;
    } catch (e) {
      debugPrint('Failed to parse JSON: $e');
      return null;
    }
  }

  /// 生成密钥哈希
  String generateKeyHash(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  // 简单的加密（实际应用中应使用更强的加密）
  String _encrypt(String value) {
    // 这里使用 Base64 编码作为示例
    // 实际应用中应使用 AES 等强加密算法
    final bytes = utf8.encode(value);
    return base64Encode(bytes);
  }

  // 简单的解密
  String _decrypt(String value) {
    try {
      final bytes = base64Decode(value);
      return utf8.decode(bytes);
    } catch (e) {
      debugPrint('Failed to decrypt: $e');
      return value;
    }
  }
}
