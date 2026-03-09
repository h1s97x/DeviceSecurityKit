import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'models/models.dart';

/// 设备安全检测器
class DeviceSecurity {
  DeviceSecurity._internal();
  factory DeviceSecurity() => _instance;
  static final DeviceSecurity _instance = DeviceSecurity._internal();

  final _deviceInfo = DeviceInfoPlugin();

  /// 检测 Root/越狱
  Future<SecurityCheckResult> checkRoot() async {
    try {
      if (Platform.isAndroid) {
        return await _checkAndroidRoot();
      } else if (Platform.isIOS) {
        return await _checkIOSJailbreak();
      } else {
        return SecurityCheckResult(
          isSecure: true,
          checkType: 'root',
          details: 'Platform not supported',
          riskLevel: 0,
        );
      }
    } catch (e) {
      debugPrint('Root check failed: $e');
      return SecurityCheckResult(
        isSecure: true,
        checkType: 'root',
        details: 'Check failed: $e',
        riskLevel: 0,
      );
    }
  }

  /// 检测调试器
  Future<SecurityCheckResult> checkDebugger() async {
    try {
      // 检测是否在调试模式
      const isDebugging = kDebugMode;

      return SecurityCheckResult(
        isSecure: !isDebugging,
        checkType: 'debugger',
        details: isDebugging ? 'Debug mode detected' : 'No debugger detected',
        riskLevel: isDebugging ? 3 : 0,
      );
    } catch (e) {
      debugPrint('Debugger check failed: $e');
      return SecurityCheckResult(
        isSecure: true,
        checkType: 'debugger',
        details: 'Check failed: $e',
        riskLevel: 0,
      );
    }
  }

  /// 检测模拟器
  Future<SecurityCheckResult> checkEmulator() async {
    try {
      if (Platform.isAndroid) {
        return await _checkAndroidEmulator();
      } else if (Platform.isIOS) {
        return await _checkIOSSimulator();
      } else {
        return SecurityCheckResult(
          isSecure: true,
          checkType: 'emulator',
          details: 'Platform not supported',
          riskLevel: 0,
        );
      }
    } catch (e) {
      debugPrint('Emulator check failed: $e');
      return SecurityCheckResult(
        isSecure: true,
        checkType: 'emulator',
        details: 'Check failed: $e',
        riskLevel: 0,
      );
    }
  }

  /// 检测代理
  Future<SecurityCheckResult> checkProxy() async {
    try {
      // 检查环境变量中的代理设置
      final httpProxy = Platform.environment['HTTP_PROXY'] ??
          Platform.environment['http_proxy'];
      final httpsProxy = Platform.environment['HTTPS_PROXY'] ??
          Platform.environment['https_proxy'];

      final hasProxy = httpProxy != null || httpsProxy != null;

      return SecurityCheckResult(
        isSecure: !hasProxy,
        checkType: 'proxy',
        details: hasProxy ? 'Proxy detected' : 'No proxy detected',
        riskLevel: hasProxy ? 5 : 0,
      );
    } catch (e) {
      debugPrint('Proxy check failed: $e');
      return SecurityCheckResult(
        isSecure: true,
        checkType: 'proxy',
        details: 'Check failed: $e',
        riskLevel: 0,
      );
    }
  }

  /// 检测 VPN
  Future<SecurityCheckResult> checkVPN() async {
    try {
      // 简单的 VPN 检测（实际需要平台特定实现）
      // 这里使用网络接口检测
      final interfaces = await NetworkInterface.list();

      final hasVPN = interfaces.any((interface) {
        final name = interface.name.toLowerCase();
        return name.contains('tun') ||
            name.contains('ppp') ||
            name.contains('vpn');
      });

      return SecurityCheckResult(
        isSecure: !hasVPN,
        checkType: 'vpn',
        details: hasVPN ? 'VPN detected' : 'No VPN detected',
        riskLevel: hasVPN ? 3 : 0,
      );
    } catch (e) {
      debugPrint('VPN check failed: $e');
      return SecurityCheckResult(
        isSecure: true,
        checkType: 'vpn',
        details: 'Check failed: $e',
        riskLevel: 0,
      );
    }
  }

  /// 获取设备安全综合信息
  Future<DeviceSecurityInfo> getSecurityInfo() async {
    try {
      final results = await Future.wait([
        checkRoot(),
        checkDebugger(),
        checkEmulator(),
        checkProxy(),
        checkVPN(),
      ]);

      return DeviceSecurityInfo(
        rootCheck: results[0],
        debuggerCheck: results[1],
        emulatorCheck: results[2],
        proxyCheck: results[3],
        vpnCheck: results[4],
      );
    } catch (e) {
      debugPrint('Failed to get security info: $e');
      return DeviceSecurityInfo();
    }
  }

  // Android Root 检测
  Future<SecurityCheckResult> _checkAndroidRoot() async {
    final checks = <String, bool>{};

    // 检查 1: su 命令
    checks['su_exists'] = await _fileExists('/system/bin/su') ||
        await _fileExists('/system/xbin/su');

    // 检查 2: Superuser.apk
    checks['superuser_apk'] = await _fileExists('/system/app/Superuser.apk');

    // 检查 3: 常见 Root 管理器
    checks['root_manager'] =
        await _fileExists('/data/data/com.noshufou.android.su') ||
            await _fileExists('/data/data/com.topjohnwu.magisk');

    // 检查 4: 测试路径
    checks['test_keys'] = await _checkBuildTags();

    final rootIndicators = checks.values.where((v) => v).length;
    final isRooted = rootIndicators > 0;

    return SecurityCheckResult(
      isSecure: !isRooted,
      checkType: 'root',
      details: isRooted
          ? 'Root detected ($rootIndicators indicators)'
          : 'No root detected',
      riskLevel: isRooted ? 8 : 0,
    );
  }

  // iOS 越狱检测
  Future<SecurityCheckResult> _checkIOSJailbreak() async {
    final checks = <String, bool>{};

    // 检查 1: Cydia
    checks['cydia'] = await _fileExists('/Applications/Cydia.app');

    // 检查 2: 常见越狱文件
    checks['jailbreak_files'] = await _fileExists('/bin/bash') ||
        await _fileExists('/usr/sbin/sshd') ||
        await _fileExists('/etc/apt');

    // 检查 3: 可写系统目录
    checks['writable_system'] = await _canWriteToPath('/private');

    final jailbreakIndicators = checks.values.where((v) => v).length;
    final isJailbroken = jailbreakIndicators > 0;

    return SecurityCheckResult(
      isSecure: !isJailbroken,
      checkType: 'jailbreak',
      details: isJailbroken
          ? 'Jailbreak detected ($jailbreakIndicators indicators)'
          : 'No jailbreak detected',
      riskLevel: isJailbroken ? 8 : 0,
    );
  }

  // Android 模拟器检测
  Future<SecurityCheckResult> _checkAndroidEmulator() async {
    try {
      final androidInfo = await _deviceInfo.androidInfo;
      final checks = <String, bool>{};

      // 检查设备信息
      checks['generic_device'] =
          androidInfo.model.toLowerCase().contains('sdk') ||
              androidInfo.model.toLowerCase().contains('emulator');

      checks['generic_brand'] = androidInfo.brand.toLowerCase() == 'generic';

      checks['test_keys'] = androidInfo.tags.contains('test-keys');

      final emulatorIndicators = checks.values.where((v) => v).length;
      final isEmulator = emulatorIndicators >= 2;

      return SecurityCheckResult(
        isSecure: !isEmulator,
        checkType: 'emulator',
        details: isEmulator
            ? 'Emulator detected ($emulatorIndicators indicators)'
            : 'Physical device',
        riskLevel: isEmulator ? 6 : 0,
      );
    } catch (e) {
      return SecurityCheckResult(
        isSecure: true,
        checkType: 'emulator',
        details: 'Check failed: $e',
        riskLevel: 0,
      );
    }
  }

  // iOS 模拟器检测
  Future<SecurityCheckResult> _checkIOSSimulator() async {
    try {
      final iosInfo = await _deviceInfo.iosInfo;
      final isSimulator = !iosInfo.isPhysicalDevice;

      return SecurityCheckResult(
        isSecure: !isSimulator,
        checkType: 'simulator',
        details: isSimulator ? 'Simulator detected' : 'Physical device',
        riskLevel: isSimulator ? 6 : 0,
      );
    } catch (e) {
      return SecurityCheckResult(
        isSecure: true,
        checkType: 'simulator',
        details: 'Check failed: $e',
        riskLevel: 0,
      );
    }
  }

  // 辅助方法
  Future<bool> _fileExists(String path) async {
    try {
      return await File(path).exists();
    } catch (e) {
      return false;
    }
  }

  Future<bool> _canWriteToPath(String path) async {
    try {
      final testFile =
          File('$path/test_${DateTime.now().millisecondsSinceEpoch}.txt');
      await testFile.writeAsString('test');
      await testFile.delete();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> _checkBuildTags() async {
    try {
      if (Platform.isAndroid) {
        final androidInfo = await _deviceInfo.androidInfo;
        return androidInfo.tags.contains('test-keys');
      }
      return false;
    } catch (e) {
      return false;
    }
  }
}
