# device_security_kit 架构设计

本文档描述 device_security_kit 项目的架构设计原则和实现方案。

## 目录

1. [设计原则](#设计原则)
2. [目录结构](#目录结构)
3. [模块划分](#模块划分)
4. [平台实现](#平台实现)
5. [数据流](#数据流)
6. [扩展指南](#扩展指南)
7. [性能优化](#性能优化)
8. [错误处理](#错误处理)
9. [测试策略](#测试策略)
10. [最佳实践](#最佳实践)

---

## 设计原则

### 1. 安全第一

所有功能设计都以安全为首要考虑。

**实现:**

- 使用平台原生安全机制（Android Keystore、iOS Keychain）
- 敏感数据加密存储
- 多层次的安全检测
- 风险级别评估系统

**示例:**

```dart
// 安全存储使用平台原生机制
final _storage = const FlutterSecureStorage(
  aOptions: AndroidOptions(
    encryptedSharedPreferences: true,
  ),
  iOptions: IOSOptions(
    accessibility: KeychainAccessibility.first_unlock,
  ),
);
```

### 2. 简单易用

提供简单直观的 API，开发者可以快速集成和使用。

**优势:**

- 快速上手
- 减少学习成本
- 降低出错概率

**示例:**

```dart
// 创建实例（单例模式）
final security = DeviceSecurity();

// 一行代码获取完整安全信息
final info = await security.getSecurityInfo();
```

### 3. 跨平台一致性

所有平台提供统一的 API 接口，返回相同的数据结构。

**实现:**

- 统一的 Dart API 层
- 统一的数据模型
- 平台特定的实现细节被封装

### 4. 类型安全

使用强类型的数据模型，避免运行时错误。

**实现:**

- 所有数据模型都有明确的类型定义
- 使用可空类型处理可能缺失的数据
- 提供便捷的 getter 方法

### 5. 可扩展性

易于添加新的安全检查功能和新的平台支持。

**实现:**

- 模块化的代码结构
- 清晰的接口定义
- 详细的扩展文档

---

## 目录结构

```text
device_security_kit/
├── lib/
│   ├── device_security_kit.dart         # 主导出文件
│   └── src/
│       ├── device_security.dart         # 设备安全检测类
│       ├── secure_storage.dart          # 安全存储类
│       └── models/                      # 数据模型
│           ├── models.dart              # 模型导出
│           ├── security_check_result.dart
│           ├── device_security_info.dart
│           └── security_report.dart
│
├── android/                             # Android 平台实现
│   └── src/main/kotlin/
│       └── com/example/device_security_kit/
│           └── DeviceSecurityKitPlugin.kt
│
├── ios/                                 # iOS 平台实现
│   └── Classes/
│       └── DeviceSecurityKitPlugin.swift
│
├── benchmark/                           # 性能基准测试
│   ├── benchmark_utils.dart             # 测试工具类
│   ├── device_security_benchmark.dart   # 主测试文件
│   ├── README.md                        # 测试文档
│   └── INTEGRATION_EXAMPLE.md           # 集成示例
│
├── test/                                # 单元测试
├── example/                             # 示例应用
└── doc/                                 # 文档
    ├── API.md
    ├── QUICK_REFERENCE.md
    ├── ARCHITECTURE.md
    ├── CODE_STYLE.md
    └── USER GUIDE.md
```

---

## 模块划分

### Dart API 层

**职责:**

- 提供公共 API 接口
- 处理平台通信
- 数据模型的序列化和反序列化
- 异常处理

**核心类:**

#### DeviceSecurity

主安全检测类，提供所有安全检查方法。使用单例模式。

```dart
class DeviceSecurity {
  // 单例实例
  static final DeviceSecurity _instance = DeviceSecurity._internal();
  factory DeviceSecurity() => _instance;
  DeviceSecurity._internal();
  
  // 安全检查方法
  Future<SecurityCheckResult> checkRoot();
  Future<SecurityCheckResult> checkDebugger();
  Future<SecurityCheckResult> checkEmulator();
  Future<SecurityCheckResult> checkProxy();
  Future<SecurityCheckResult> checkVPN();
  
  // 综合安全信息
  Future<DeviceSecurityInfo> getSecurityInfo();
}
```

#### SecureStorage

安全存储类，提供加密的本地数据存储。使用单例模式。

```dart
class SecureStorage {
  // 单例实例
  static final SecureStorage _instance = SecureStorage._internal();
  factory SecureStorage() => _instance;
  SecureStorage._internal();
  
  // 基本操作
  Future<void> write({required String key, required String value, bool encrypt});
  Future<String?> read({required String key, bool decrypt});
  Future<void> delete({required String key});
  Future<void> deleteAll();
  Future<bool> containsKey({required String key});
  Future<Map<String, String>> readAll();
  
  // JSON 操作
  Future<void> writeJson({required String key, required Map<String, dynamic> value, bool encrypt});
  Future<Map<String, dynamic>?> readJson({required String key, bool decrypt});
  
  // 工具方法
  String generateKeyHash(String input);
}
```

### 数据模型层

**职责:**

- 定义安全检查信息的数据结构
- 提供 JSON 序列化/反序列化
- 提供便捷的 getter 方法

**核心模型:**

#### SecurityCheckResult

单项安全检查的结果。

```dart
class SecurityCheckResult {
  final bool isSecure;          // 是否安全
  final String checkType;       // 检查类型
  final String? details;        // 详细信息
  final int riskLevel;          // 风险级别 (0-10)
  final DateTime timestamp;     // 检查时间
  
  // 便捷 getter
  bool get isHighRisk => riskLevel >= 7;
  bool get isMediumRisk => riskLevel >= 4 && riskLevel < 7;
  bool get isLowRisk => riskLevel > 0 && riskLevel < 4;
}
```

#### DeviceSecurityInfo

设备安全综合信息。

```dart
class DeviceSecurityInfo {
  final SecurityCheckResult? rootCheck;
  final SecurityCheckResult? debuggerCheck;
  final SecurityCheckResult? emulatorCheck;
  final SecurityCheckResult? proxyCheck;
  final SecurityCheckResult? vpnCheck;
  final int securityScore;      // 0-100
  final DateTime timestamp;
  
  // 便捷 getter
  bool get isSecure => securityScore >= 70;
  bool get hasHighRisk;
}
```

#### SecurityReport

安全报告，包含多个检查结果的汇总。

```dart
class SecurityReport {
  final List<SecurityCheckResult> checks;
  final DateTime timestamp;
  
  // 便捷 getter
  bool get isSecure;
  int get totalRiskLevel;
  double get averageRiskLevel;
  List<SecurityCheckResult> get highRiskChecks;
  List<SecurityCheckResult> get mediumRiskChecks;
  List<SecurityCheckResult> get lowRiskChecks;
  List<SecurityCheckResult> get failedChecks;
}
```

---

## 平台实现

### 依赖的第三方包

device_security_kit 使用以下第三方包来实现跨平台功能：

#### flutter_secure_storage

用于安全存储，使用平台原生安全机制。

**功能:**

- Android: EncryptedSharedPreferences / Keystore
- iOS: Keychain
- 跨平台统一 API

**使用:**

```dart
final _storage = const FlutterSecureStorage(
  aOptions: AndroidOptions(
    encryptedSharedPreferences: true,
  ),
  iOptions: IOSOptions(
    accessibility: KeychainAccessibility.first_unlock,
  ),
);

await _storage.write(key: 'key', value: 'value');
final value = await _storage.read(key: 'key');
```

#### device_info_plus

用于获取设备信息。

**功能:**

- 设备型号、品牌
- 操作系统版本
- 物理设备检查（iOS）
- 构建标签（Android）

**使用:**

```dart
final _deviceInfo = DeviceInfoPlugin();

if (Platform.isAndroid) {
  final androidInfo = await _deviceInfo.androidInfo;
  final isEmulator = androidInfo.model.toLowerCase().contains('sdk');
} else if (Platform.isIOS) {
  final iosInfo = await _deviceInfo.iosInfo;
  final isSimulator = !iosInfo.isPhysicalDevice;
}
```

#### package_info_plus

用于获取应用包信息（未来可能使用）。

#### crypto

用于加密和哈希计算。

**功能:**

- SHA-256 哈希
- 密钥生成

**使用:**

```dart
import 'package:crypto/crypto.dart';
import 'dart:convert';

String generateKeyHash(String input) {
  final bytes = utf8.encode(input);
  final digest = sha256.convert(bytes);
  return digest.toString();
}
```

### 平台特定实现

#### Android Root 检测

```dart
Future<SecurityCheckResult> _checkAndroidRoot() async {
  final checks = <String, bool>{};
  
  // 检查 1: su 命令
  checks['su_exists'] = await _fileExists('/system/bin/su') ||
                       await _fileExists('/system/xbin/su');
  
  // 检查 2: Superuser.apk
  checks['superuser_apk'] = await _fileExists('/system/app/Superuser.apk');
  
  // 检查 3: Root 管理器
  checks['root_manager'] = await _fileExists('/data/data/com.noshufou.android.su') ||
                          await _fileExists('/data/data/com.topjohnwu.magisk');
  
  // 检查 4: 测试密钥
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
```

#### iOS 越狱检测

```dart
Future<SecurityCheckResult> _checkIOSJailbreak() async {
  final checks = <String, bool>{};
  
  // 检查 1: Cydia
  checks['cydia'] = await _fileExists('/Applications/Cydia.app');
  
  // 检查 2: 越狱文件
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
```

#### 模拟器检测

```dart
// Android
Future<SecurityCheckResult> _checkAndroidEmulator() async {
  final androidInfo = await _deviceInfo.androidInfo;
  final checks = <String, bool>{};
  
  checks['generic_device'] = androidInfo.model.toLowerCase().contains('sdk') ||
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
}

// iOS
Future<SecurityCheckResult> _checkIOSSimulator() async {
  final iosInfo = await _deviceInfo.iosInfo;
  final isSimulator = !iosInfo.isPhysicalDevice;
  
  return SecurityCheckResult(
    isSecure: !isSimulator,
    checkType: 'simulator',
    details: isSimulator ? 'Simulator detected' : 'Physical device',
    riskLevel: isSimulator ? 6 : 0,
  );
}
```

---

## 数据流

```text
┌─────────────┐
│   Flutter   │
│     App     │
└──────┬──────┘
       │
       │ 调用 API
       ▼
┌─────────────────────┐
│  DeviceSecurity     │
│  SecureStorage      │
│   (Dart API)        │
└──────┬──────────────┘
       │
       │ 使用第三方包
       ▼
┌─────────────────────┐
│ flutter_secure_     │
│   storage           │
│ device_info_plus    │
│ crypto              │
└──────┬──────────────┘
       │
       │ 平台通道
       ▼
┌─────────────────────┐
│  Platform Code      │
│ (Kotlin / Swift)    │
└──────┬──────────────┘
       │
       │ 系统 API
       ▼
┌─────────────────────┐
│  Operating          │
│    System           │
│ (Keystore/Keychain) │
└─────────────────────┘
```

---

## 扩展指南

### 添加新的安全检查

假设要添加 "SSL Pinning 检测"：

#### 步骤 1: 添加检查方法

在 `lib/src/device_security.dart` 中添加：

```dart
/// 检测 SSL Pinning
Future<SecurityCheckResult> checkSSLPinning() async {
  try {
    // 实现 SSL Pinning 检测逻辑
    // 可能需要检查网络请求的证书
    
    final hasPinning = await _checkSSLPinningImplementation();
    
    return SecurityCheckResult(
      isSecure: hasPinning,
      checkType: 'ssl_pinning',
      details: hasPinning ? 'SSL Pinning enabled' : 'SSL Pinning disabled',
      riskLevel: hasPinning ? 0 : 5,
    );
  } catch (e) {
    debugPrint('SSL Pinning check failed: $e');
    return SecurityCheckResult(
      isSecure: true,
      checkType: 'ssl_pinning',
      details: 'Check failed: $e',
      riskLevel: 0,
    );
  }
}
```

#### 步骤 2: 更新 DeviceSecurityInfo

在 `lib/src/models/device_security_info.dart` 中添加：

```dart
class DeviceSecurityInfo {
  final SecurityCheckResult? rootCheck;
  final SecurityCheckResult? debuggerCheck;
  final SecurityCheckResult? emulatorCheck;
  final SecurityCheckResult? proxyCheck;
  final SecurityCheckResult? vpnCheck;
  final SecurityCheckResult? sslPinningCheck;  // 新增
  final int securityScore;
  final DateTime timestamp;

  DeviceSecurityInfo({
    this.rootCheck,
    this.debuggerCheck,
    this.emulatorCheck,
    this.proxyCheck,
    this.vpnCheck,
    this.sslPinningCheck,  // 新增
    DateTime? timestamp,
  }) : securityScore = _calculateScore(
          rootCheck,
          debuggerCheck,
          emulatorCheck,
          proxyCheck,
          vpnCheck,
          sslPinningCheck,  // 新增
        ),
        timestamp = timestamp ?? DateTime.now();
}
```

#### 步骤 3: 更新 getSecurityInfo

```dart
Future<DeviceSecurityInfo> getSecurityInfo() async {
  try {
    final results = await Future.wait([
      checkRoot(),
      checkDebugger(),
      checkEmulator(),
      checkProxy(),
      checkVPN(),
      checkSSLPinning(),  // 新增
    ]);

    return DeviceSecurityInfo(
      rootCheck: results[0],
      debuggerCheck: results[1],
      emulatorCheck: results[2],
      proxyCheck: results[3],
      vpnCheck: results[4],
      sslPinningCheck: results[5],  // 新增
    );
  } catch (e) {
    debugPrint('Failed to get security info: $e');
    return DeviceSecurityInfo();
  }
}
```

#### 步骤 4: 添加测试

在 `test/` 目录添加测试：

```dart
test('checkSSLPinning returns valid result', () async {
  final security = DeviceSecurity();
  final result = await security.checkSSLPinning();
  
  expect(result, isA<SecurityCheckResult>());
  expect(result.checkType, 'ssl_pinning');
  expect(result.riskLevel, inInclusiveRange(0, 10));
});
```

#### 步骤 5: 添加性能测试

在 `benchmark/benchmark_utils.dart` 中添加：

```dart
// SSL Pinning Check
await _benchmarkCheck('SSL Pinning check', iterations, () => security.checkSSLPinning());
```

#### 步骤 6: 更新文档

- 更新 `README.md`
- 更新 `doc/API.md`
- 更新 `doc/QUICK_REFERENCE.md`
- 更新 `CHANGELOG.md`

---

## 性能优化

### 1. 单例模式

DeviceSecurity 和 SecureStorage 使用单例模式，避免重复创建实例：

```dart
class DeviceSecurity {
  static final DeviceSecurity _instance = DeviceSecurity._internal();
  factory DeviceSecurity() => _instance;
  DeviceSecurity._internal();
}
```

### 2. 并发执行

使用 `Future.wait` 并发执行多个检查：

```dart
// 推荐：并发执行
final results = await Future.wait([
  checkRoot(),
  checkDebugger(),
  checkEmulator(),
  checkProxy(),
  checkVPN(),
]);

// 不推荐：串行执行
final rootCheck = await checkRoot();
final debuggerCheck = await checkDebugger();
final emulatorCheck = await checkEmulator();
// ...
```

### 3. 缓存结果

对于不经常变化的检查结果，可以实现缓存：

```dart
class SecurityManager {
  DeviceSecurityInfo? _cachedInfo;
  DateTime? _lastCheck;
  
  Future<DeviceSecurityInfo> getSecurityInfo() async {
    // 缓存 5 分钟
    if (_cachedInfo != null && 
        _lastCheck != null &&
        DateTime.now().difference(_lastCheck!) < Duration(minutes: 5)) {
      return _cachedInfo!;
    }
    
    final security = DeviceSecurity();
    _cachedInfo = await security.getSecurityInfo();
    _lastCheck = DateTime.now();
    
    return _cachedInfo!;
  }
}
```

### 4. 按需检查

只执行必要的检查：

```dart
// 只检查 Root
final rootCheck = await security.checkRoot();
if (!rootCheck.isSecure) {
  // 处理 Root 情况
  return;
}

// 只有在需要时才检查其他项
```

---

## 错误处理

### 异常处理策略

1. **捕获异常**: 所有方法都捕获异常并返回安全的默认值
2. **日志记录**: 使用 `debugPrint` 记录错误信息
3. **优雅降级**: 返回安全的默认值而不是抛出异常

**示例:**

```dart
Future<SecurityCheckResult> checkRoot() async {
  try {
    // 执行检测
    return SecurityCheckResult(...);
  } catch (e) {
    debugPrint('Root check failed: $e');
    return SecurityCheckResult(
      isSecure: true,  // 默认安全
      checkType: 'root',
      details: 'Check failed: $e',
      riskLevel: 0,
    );
  }
}
```

---

## 测试策略

### 单元测试

测试数据模型和业务逻辑：

```dart
test('SecurityCheckResult.fromJson 正确解析数据', () {
  final json = {
    'isSecure': false,
    'checkType': 'root',
    'details': 'Root detected',
    'riskLevel': 8,
    'timestamp': DateTime.now().toIso8601String(),
  };
  
  final result = SecurityCheckResult.fromJson(json);
  
  expect(result.isSecure, false);
  expect(result.checkType, 'root');
  expect(result.riskLevel, 8);
  expect(result.isHighRisk, true);
});
```

### 集成测试

测试实际的安全检查：

```dart
testWidgets('getSecurityInfo 返回有效数据', (tester) async {
  final security = DeviceSecurity();
  final info = await security.getSecurityInfo();
  
  expect(info, isNotNull);
  expect(info.securityScore, inInclusiveRange(0, 100));
  expect(info.timestamp, isNotNull);
});
```

### 性能测试

使用 benchmark 测试性能：

```dart
void main() async {
  final benchmark = SecurityBenchmark();
  await benchmark.runAll();
}
```

---

## 最佳实践

### 1. 使用单例

```dart
// 推荐
final security = DeviceSecurity();
final storage = SecureStorage();

// 不推荐
final security1 = DeviceSecurity();
final security2 = DeviceSecurity();
```

### 2. 处理可空值

```dart
// 推荐
final rootCheck = info.rootCheck;
if (rootCheck != null && !rootCheck.isSecure) {
  print('Root detected');
}

// 或使用 ?.
print('Root: ${info.rootCheck?.isSecure ?? true}');

// 不推荐
print('Root: ${info.rootCheck!.isSecure}');  // 可能崩溃
```

### 3. 使用加密存储

```dart
// 推荐：敏感数据加密
await storage.write(
  key: 'api_token',
  value: token,
  encrypt: true,
);

// 不推荐：敏感数据不加密
await storage.write(
  key: 'api_token',
  value: token,
);
```

### 4. 及时处理安全风险

```dart
final info = await security.getSecurityInfo();

if (info.hasHighRisk) {
  // 立即处理高风险
  showSecurityAlert();
  disableSensitiveFeatures();
} else if (!info.isSecure) {
  // 警告用户
  showSecurityWarning();
}
```

---

## 总结

device_security_kit 的架构设计遵循以下原则：

1. **安全第一**: 使用平台原生安全机制
2. **简单易用**: 提供直观的 API
3. **跨平台一致**: 统一的接口和数据结构
4. **类型安全**: 强类型的数据模型
5. **可扩展**: 易于添加新功能

这种设计为项目的长期发展和维护奠定了坚实的基础。

---

**文档版本**: 1.0  
**创建日期**: 2024-03-08  
**项目**: device_security_kit
