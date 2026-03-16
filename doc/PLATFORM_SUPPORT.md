# Platform Support Documentation

## Overview

Device Security Kit now supports all major Flutter platforms with platform-specific implementations and graceful fallbacks.

## Supported Platforms

### ✅ Fully Supported

#### Android (API 21+)
- **Status**: Fully supported
- **Features**: All security checks available
  - Root detection
  - Debugger detection
  - Emulator detection
  - Proxy detection
  - VPN detection
- **Implementation**: Kotlin/Java
- **Secure Storage**: Android Keystore

#### iOS (iOS 12.0+)
- **Status**: Fully supported
- **Features**: All security checks available
  - Jailbreak detection
  - Debugger detection
  - Simulator detection
  - Proxy detection
  - VPN detection
- **Implementation**: Swift/Objective-C
- **Secure Storage**: iOS Keychain

### ⚠️ Partially Supported

#### Windows (Windows 7+)
- **Status**: Partial support
- **Features**: Limited security checks
  - Debugger detection (via kDebugMode)
  - Proxy detection (environment variables)
  - VPN detection (network interfaces)
- **Implementation**: C++ (FFI)
- **Secure Storage**: Windows Credential Manager
- **Limitations**:
  - No native root/admin detection
  - Limited emulator detection
  - Requires additional setup for full functionality

#### macOS (macOS 10.12+)
- **Status**: Partial support
- **Features**: Limited security checks
  - Debugger detection (via kDebugMode)
  - Proxy detection (environment variables)
  - VPN detection (network interfaces)
- **Implementation**: Swift (FFI)
- **Secure Storage**: macOS Keychain
- **Limitations**:
  - No native jailbreak detection
  - Limited emulator detection
  - Requires additional setup for full functionality

#### Linux (Ubuntu 18.04+)
- **Status**: Partial support
- **Features**: Limited security checks
  - Debugger detection (via kDebugMode)
  - Proxy detection (environment variables)
  - VPN detection (network interfaces)
- **Implementation**: C++ (FFI)
- **Secure Storage**: Linux Secret Service
- **Limitations**:
  - No native root detection
  - Limited emulator detection
  - Requires additional setup for full functionality

#### Web
- **Status**: Experimental support
- **Features**: Limited functionality
  - Basic device information
  - Browser detection
- **Implementation**: JavaScript/Dart
- **Secure Storage**: Browser LocalStorage (encrypted)
- **Limitations**:
  - No native security checks
  - Limited to browser capabilities
  - Security checks are simulated

### ❌ Not Supported

- Fuchsia
- Other platforms

## Platform-Specific Implementation Details

### Android Implementation

```kotlin
// Root detection using multiple methods
- Check for su command
- Check for Superuser.apk
- Check for Root managers
- Check build tags
```

### iOS Implementation

```swift
// Jailbreak detection using multiple methods
- Check for Cydia
- Check for jailbreak files
- Check for writable system directories
```

### Windows Implementation

```cpp
// Limited security checks
- Debugger detection via Windows API
- Proxy detection via environment variables
- VPN detection via network interfaces
```

### macOS Implementation

```swift
// Limited security checks
- Debugger detection via Dart
- Proxy detection via environment variables
- VPN detection via network interfaces
```

### Linux Implementation

```cpp
// Limited security checks
- Debugger detection via Dart
- Proxy detection via environment variables
- VPN detection via network interfaces
```

### Web Implementation

```dart
// Browser-based checks
- Browser detection
- Device information
- Simulated security checks
```

## Usage by Platform

### Android/iOS (Full Support)

```dart
import 'package:device_security_kit/device_security_kit.dart';

final security = DeviceSecurity();
final info = await security.getSecurityInfo();
print('Security Score: ${info.securityScore}');
```

### Windows/macOS/Linux (Partial Support)

```dart
import 'package:device_security_kit/device_security_kit.dart';

final security = DeviceSecurity();
final info = await security.getSecurityInfo();
// Limited checks available
// Some checks will return default values
print('Security Score: ${info.securityScore}');
```

### Web (Experimental)

```dart
import 'package:device_security_kit/device_security_kit.dart';

final security = DeviceSecurity();
final info = await security.getSecurityInfo();
// Very limited checks available
// Most checks will return default values
print('Security Score: ${info.securityScore}');
```

## Secure Storage by Platform

| Platform | Storage Backend | Encryption | Status |
|----------|-----------------|-----------|--------|
| Android | Android Keystore | Hardware-backed | ✅ Full |
| iOS | iOS Keychain | Hardware-backed | ✅ Full |
| Windows | Credential Manager | Software | ⚠️ Partial |
| macOS | Keychain | Hardware-backed | ⚠️ Partial |
| Linux | Secret Service | Software | ⚠️ Partial |
| Web | LocalStorage | Software | ⚠️ Partial |

## Platform Configuration

### pubspec.yaml

```yaml
flutter:
  plugin:
    platforms:
      android:
        package: com.example.device_security_kit
        pluginClass: DeviceSecurityKitPlugin
      ios:
        pluginClass: DeviceSecurityKitPlugin
      windows:
        ffiPlugin: true
      macos:
        ffiPlugin: true
      linux:
        ffiPlugin: true
      web:
        pluginClass: DeviceSecurityKitWeb
        fileName: device_security_kit_web.dart
```

## Building for Different Platforms

### Android

```bash
flutter build apk
flutter build appbundle
```

### iOS

```bash
flutter build ios
```

### Windows

```bash
flutter build windows
```

### macOS

```bash
flutter build macos
```

### Linux

```bash
flutter build linux
```

### Web

```bash
flutter build web
```

## Testing on Different Platforms

### Android Emulator

```bash
flutter run -d emulator-5554
```

### iOS Simulator

```bash
flutter run -d iPhone
```

### Windows Desktop

```bash
flutter run -d windows
```

### macOS Desktop

```bash
flutter run -d macos
```

### Linux Desktop

```bash
flutter run -d linux
```

### Web Browser

```bash
flutter run -d chrome
```

## Platform-Specific Limitations

### Android
- Root detection may be bypassed by advanced tools
- Emulator detection may not work on all custom ROMs

### iOS
- Jailbreak detection may be bypassed by advanced tools
- Simulator detection is straightforward but limited

### Windows
- No native root/admin detection
- Requires Windows API knowledge for advanced features
- Limited to environment variable proxy detection

### macOS
- No native jailbreak detection
- Limited to environment variable proxy detection
- Requires additional setup for full functionality

### Linux
- No native root detection
- Limited to environment variable proxy detection
- Requires additional setup for full functionality

### Web
- No native security checks
- Limited to browser capabilities
- Security checks are simulated

## Future Platform Support

### Planned Enhancements

1. **Enhanced Windows Support**
   - Native admin detection
   - Improved emulator detection
   - Better secure storage

2. **Enhanced macOS Support**
   - Native jailbreak detection
   - Improved security checks
   - Better secure storage

3. **Enhanced Linux Support**
   - Native root detection
   - Improved security checks
   - Better secure storage

4. **Improved Web Support**
   - Better browser detection
   - Enhanced security checks
   - Improved secure storage

## Troubleshooting

### Platform Not Supported

If you encounter "Platform not supported" errors:

1. Check your Flutter version (requires 3.3.0+)
2. Verify platform-specific dependencies are installed
3. Run `flutter pub get` to update dependencies
4. Check platform-specific build files exist

### Build Errors

For platform-specific build errors:

1. **Windows**: Ensure Visual Studio is installed
2. **macOS**: Ensure Xcode is installed
3. **Linux**: Ensure build-essential is installed
4. **Web**: Ensure web support is enabled

### Runtime Errors

For runtime errors on specific platforms:

1. Check platform-specific logs
2. Verify platform-specific permissions
3. Check platform-specific configuration
4. Review platform-specific documentation

## Contributing

To add support for new platforms:

1. Create platform-specific implementation
2. Add platform configuration to pubspec.yaml
3. Add platform-specific tests
4. Update documentation
5. Submit pull request

## References

- [Flutter Platform Channels](https://flutter.dev/docs/development/platform-integration/platform-channels)
- [Flutter FFI](https://flutter.dev/docs/development/platform-integration/c-interop)
- [Flutter Web](https://flutter.dev/docs/get-started/web)
- [Android Security](https://developer.android.com/training/articles/security-tips)
- [iOS Security](https://developer.apple.com/security/)
