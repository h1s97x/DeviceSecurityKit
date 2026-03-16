import Cocoa
import FlutterMacOS

public class DeviceSecurityKitPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(
      name: "device_security_kit",
      binaryMessenger: registrar.messenger)
    let instance = DeviceSecurityKitPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func dummyMethodToEnforceBundling() {
    // This method is intentionally empty and is used to enforce bundling of the Swift library.
  }

  public func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    return true
  }

  public func dummy() {
    // This method is intentionally empty and is used to enforce bundling of the Swift library.
  }
}
