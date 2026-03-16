# Device Security Kit Example

This is a complete example application demonstrating all features of the Device Security Kit package.

## Features Demonstrated

### 1. Security Checks
- **Root/Jailbreak Detection**: Detects if the device is rooted (Android) or jailbroken (iOS)
- **Debugger Detection**: Checks if the app is running in debug mode
- **Emulator/Simulator Detection**: Identifies if running on an emulator or simulator
- **Proxy Detection**: Detects proxy settings via environment variables
- **VPN Detection**: Identifies VPN connections through network interfaces

### 2. Security Scoring
- Comprehensive security score (0-100)
- Individual risk levels for each check
- Risk categorization (High/Medium/Low)
- Real-time security assessment

### 3. Secure Storage
- Encrypted data storage using platform-native mechanisms
- JSON object serialization
- Key-value operations
- Batch operations

## Running the Example

### Prerequisites
- Flutter SDK (3.3.0 or higher)
- Android SDK (for Android testing)
- Xcode (for iOS testing)

### Android

```bash
flutter run
```

### iOS

```bash
flutter run
```

## Example Usage

### Basic Security Check

```dart
import 'package:device_security_kit/device_security_kit.dart';

final security = DeviceSecurity();

// Get comprehensive security information
final info = await security.getSecurityInfo();
print('Security Score: ${info.securityScore}');
print('Is Secure: ${info.isSecure}');

// Check individual security aspects
final rootCheck = await security.checkRoot();
final debuggerCheck = await security.checkDebugger();
final emulatorCheck = await security.checkEmulator();
```

### Secure Storage

```dart
import 'package:device_security_kit/device_security_kit.dart';

final storage = SecureStorage();

// Write encrypted data
await storage.write(
  key: 'api_token',
  value: 'secret_token_value',
  encrypt: true,
);

// Read encrypted data
final token = await storage.read(
  key: 'api_token',
  decrypt: true,
);

// Store JSON objects
await storage.writeJson(
  key: 'user_profile',
  value: {
    'id': 123,
    'name': 'John Doe',
    'email': 'john@example.com',
  },
  encrypt: true,
);

// Retrieve JSON objects
final profile = await storage.readJson(
  key: 'user_profile',
  decrypt: true,
);
```

## App Features

### Main Screen
- **Security Score Card**: Displays overall security score with visual indicator
- **Security Check Details**: Shows results of all individual security checks
- **Secure Storage Test**: Demonstrates secure storage functionality
- **Statistics**: Displays check count, last check time, and current score
- **Advanced Actions**: Button to run individual security checks with detailed results

### Individual Checks Dialog
- Detailed results for each security check
- Risk level indicators
- Security status for each check
- Color-coded risk visualization

## Platform Support

- ✅ Android (API 21+)
- ✅ iOS (iOS 12.0+)
- ⚠️ Windows (Limited functionality)
- ⚠️ Linux (Limited functionality)
- ⚠️ macOS (Limited functionality)

## Troubleshooting

### Android Issues
- Ensure you have the latest Android SDK
- Check that your device or emulator is running Android API 21 or higher

### iOS Issues
- Ensure you have the latest Xcode
- Check that your device or simulator is running iOS 12.0 or higher
- Run `flutter clean` and `flutter pub get` if you encounter build issues

## Additional Resources

- [Device Security Kit Documentation](../doc/USER%20GUIDE.md)
- [API Reference](../doc/API.md)
- [Architecture Guide](../doc/ARCHITECTURE.md)
- [Quick Reference](../doc/QUICK_REFERENCE.md)

## License

This example is part of the Device Security Kit package, which is licensed under the MIT License.
