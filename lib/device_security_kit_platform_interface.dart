import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'device_security_kit_method_channel.dart';

abstract class DeviceSecurityKitPlatform extends PlatformInterface {
  /// Constructs a DeviceSecurityKitPlatform.
  DeviceSecurityKitPlatform() : super(token: _token);

  static final Object _token = Object();

  static DeviceSecurityKitPlatform _instance = MethodChannelDeviceSecurityKit();

  /// The default instance of [DeviceSecurityKitPlatform] to use.
  ///
  /// Defaults to [MethodChannelDeviceSecurityKit].
  static DeviceSecurityKitPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [DeviceSecurityKitPlatform] when
  /// they register themselves.
  static set instance(DeviceSecurityKitPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
