import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'device_security_kit_platform_interface.dart';

/// An implementation of [DeviceSecurityKitPlatform] that uses method channels.
class MethodChannelDeviceSecurityKit extends DeviceSecurityKitPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('device_security_kit');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>(
      'getPlatformVersion',
    );
    return version;
  }
}
