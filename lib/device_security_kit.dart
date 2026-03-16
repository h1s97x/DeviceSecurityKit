/// Device Security Kit - A comprehensive device security toolkit for Flutter.
///
/// This package provides a complete solution for device security checks and
/// secure data storage on Flutter applications. It includes:
///
/// - **Security Checks**: Root/Jailbreak detection, debugger detection,
///   emulator detection, proxy detection, and VPN detection
/// - **Security Scoring**: Comprehensive security assessment with risk levels
/// - **Secure Storage**: Encrypted data storage using platform-native mechanisms
///
/// ## Quick Start
///
/// ### Security Checks
///
/// ```dart
/// import 'package:device_security_kit/device_security_kit.dart';
///
/// final security = DeviceSecurity();
///
/// // Get comprehensive security information
/// final info = await security.getSecurityInfo();
/// print('Security Score: ${info.securityScore}');
/// print('Is Secure: ${info.isSecure}');
///
/// // Check individual security aspects
/// final rootCheck = await security.checkRoot();
/// final debuggerCheck = await security.checkDebugger();
/// final emulatorCheck = await security.checkEmulator();
/// final proxyCheck = await security.checkProxy();
/// final vpnCheck = await security.checkVPN();
/// ```
///
/// ### Secure Storage
///
/// ```dart
/// final storage = SecureStorage();
///
/// // Write encrypted data
/// await storage.write(
///   key: 'api_token',
///   value: 'secret_token_value',
///   encrypt: true,
/// );
///
/// // Read encrypted data
/// final token = await storage.read(
///   key: 'api_token',
///   decrypt: true,
/// );
///
/// // Store and retrieve JSON objects
/// await storage.writeJson(
///   key: 'user_profile',
///   value: {'id': 123, 'name': 'John Doe'},
///   encrypt: true,
/// );
///
/// final profile = await storage.readJson(
///   key: 'user_profile',
///   decrypt: true,
/// );
/// ```
///
/// ## Platform Support
///
/// - ✅ Android (API 21+)
/// - ✅ iOS (iOS 12.0+)
/// - ⚠️ Windows (Limited functionality)
/// - ⚠️ Linux (Limited functionality)
/// - ⚠️ macOS (Limited functionality)
///
/// ## Features
///
/// - **Root/Jailbreak Detection**: Detects if device is rooted or jailbroken
/// - **Debugger Detection**: Identifies if app is running in debug mode
/// - **Emulator/Simulator Detection**: Detects emulator or simulator environments
/// - **Proxy Detection**: Identifies proxy settings
/// - **VPN Detection**: Detects VPN connections
/// - **Security Scoring**: Comprehensive security assessment (0-100)
/// - **Risk Assessment**: Individual risk levels for each check
/// - **Secure Storage**: Encrypted data persistence
/// - **JSON Support**: Easy serialization of complex objects
///
/// ## Documentation
///
/// For more information, see:
/// - [User Guide](https://github.com/h1s97x/DeviceSecurityKit/blob/main/doc/USER%20GUIDE.md)
/// - [API Reference](https://github.com/h1s97x/DeviceSecurityKit/blob/main/doc/API.md)
/// - [Architecture](https://github.com/h1s97x/DeviceSecurityKit/blob/main/doc/ARCHITECTURE.md)
///
/// ## License
///
/// This package is licensed under the MIT License.
library device_security_kit;

export 'src/device_security.dart';
export 'src/secure_storage.dart';
export 'src/models/models.dart';
