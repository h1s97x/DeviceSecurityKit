/// Web implementation of device_security_kit.
///
/// Web platform support is experimental and limited.
/// Most security checks are not available on web due to browser limitations.
/// Only secure storage is available via browser LocalStorage.
// ignore: unnecessary_library_name
library device_security_kit_web;

import 'package:flutter/services.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';

/// Web implementation of the DeviceSecurityKit plugin.
///
/// This is a stub implementation that provides basic platform channel
/// support for web. Most security checks return safe defaults on web
/// due to browser security restrictions.
class DeviceSecurityKitWeb {
  /// Registers this class as the default instance of the plugin.
  static void registerWith(Registrar registrar) {
    final channel = MethodChannel(
      'device_security_kit',
      const StandardMethodCodec(),
      registrar,
    );
    final instance = DeviceSecurityKitWeb();
    channel.setMethodCallHandler(instance._handleMethodCall);
  }

  Future<dynamic> _handleMethodCall(MethodCall call) async {
    switch (call.method) {
      case 'getPlatformVersion':
        return 'Web';
      default:
        throw PlatformException(
          code: 'Unimplemented',
          details: '${call.method} is not available on web platform',
        );
    }
  }
}
