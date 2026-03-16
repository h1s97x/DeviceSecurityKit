import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';

/// Secure storage for encrypted data persistence.
///
/// This class provides a singleton instance for securely storing and retrieving
/// sensitive data using platform-native security mechanisms:
/// - Android: Android Keystore
/// - iOS: iOS Keychain
///
/// Data can be optionally encrypted using Base64 encoding for additional security.
///
/// Usage:
/// ```dart
/// final storage = SecureStorage();
/// 
/// // Write encrypted data
/// await storage.write(key: 'token', value: 'secret', encrypt: true);
/// 
/// // Read encrypted data
/// final token = await storage.read(key: 'token', decrypt: true);
/// 
/// // Write JSON object
/// await storage.writeJson(key: 'user', value: {'id': 1, 'name': 'John'});
/// 
/// // Read JSON object
/// final user = await storage.readJson(key: 'user');
/// ```
class SecureStorage {
  /// Creates a new SecureStorage instance (returns singleton).
  SecureStorage._internal();

  /// Returns the singleton instance of SecureStorage.
  factory SecureStorage() => _instance;

  static final SecureStorage _instance = SecureStorage._internal();

  final _storage = const FlutterSecureStorage(
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock,
    ),
  );

  /// Writes a value to secure storage.
  ///
  /// If [encrypt] is true, the value will be Base64 encoded before storage.
  /// The data is stored using platform-native secure storage mechanisms.
  ///
  /// Parameters:
  /// - [key]: The key to store the value under
  /// - [value]: The string value to store
  /// - [encrypt]: Whether to encrypt the value (default: false)
  ///
  /// Throws an exception if the write operation fails.
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

  /// Reads a value from secure storage.
  ///
  /// If [decrypt] is true, the value will be Base64 decoded after retrieval.
  /// Returns null if the key does not exist.
  ///
  /// Parameters:
  /// - [key]: The key to read the value from
  /// - [decrypt]: Whether to decrypt the value (default: false)
  ///
  /// Returns the stored value or null if not found.
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

  /// Deletes a value from secure storage.
  ///
  /// Parameters:
  /// - [key]: The key to delete
  ///
  /// Throws an exception if the delete operation fails.
  Future<void> delete({required String key}) async {
    try {
      await _storage.delete(key: key);
    } catch (e) {
      debugPrint('Failed to delete secure data: $e');
      rethrow;
    }
  }

  /// Deletes all values from secure storage.
  ///
  /// Throws an exception if the operation fails.
  Future<void> deleteAll() async {
    try {
      await _storage.deleteAll();
    } catch (e) {
      debugPrint('Failed to delete all secure data: $e');
      rethrow;
    }
  }

  /// Checks if a key exists in secure storage.
  ///
  /// Parameters:
  /// - [key]: The key to check
  ///
  /// Returns true if the key exists, false otherwise.
  Future<bool> containsKey({required String key}) async {
    try {
      return await _storage.containsKey(key: key);
    } catch (e) {
      debugPrint('Failed to check key: $e');
      return false;
    }
  }

  /// Reads all key-value pairs from secure storage.
  ///
  /// Returns a map of all stored key-value pairs, or an empty map if storage is empty.
  Future<Map<String, String>> readAll() async {
    try {
      return await _storage.readAll();
    } catch (e) {
      debugPrint('Failed to read all: $e');
      return {};
    }
  }

  /// Writes a JSON object to secure storage.
  ///
  /// The object is serialized to JSON string before storage.
  /// If [encrypt] is true, the JSON string will be Base64 encoded.
  ///
  /// Parameters:
  /// - [key]: The key to store the JSON under
  /// - [value]: The JSON object to store
  /// - [encrypt]: Whether to encrypt the JSON (default: false)
  Future<void> writeJson({
    required String key,
    required Map<String, dynamic> value,
    bool encrypt = false,
  }) async {
    final jsonString = jsonEncode(value);
    await write(key: key, value: jsonString, encrypt: encrypt);
  }

  /// Reads a JSON object from secure storage.
  ///
  /// The stored JSON string is deserialized to a map.
  /// If [decrypt] is true, the JSON string will be Base64 decoded first.
  ///
  /// Parameters:
  /// - [key]: The key to read the JSON from
  /// - [decrypt]: Whether to decrypt the JSON (default: false)
  ///
  /// Returns the deserialized JSON object or null if not found or parsing fails.
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

  /// Generates a SHA-256 hash of the input string.
  ///
  /// Useful for creating secure key identifiers or checksums.
  ///
  /// Parameters:
  /// - [input]: The string to hash
  ///
  /// Returns the hexadecimal representation of the SHA-256 hash.
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
