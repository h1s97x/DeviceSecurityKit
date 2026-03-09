# device_security_kit 代码风格指南

本文档定义了 device_security_kit 项目的代码风格规范。

## 基本原则

1. **一致性**: 保持代码风格一致
2. **可读性**: 代码应该易于理解
3. **安全性**: 优先考虑安全性
4. **可维护性**: 便于后续维护和扩展

---

## Dart 代码风格

### 命名规范

#### 文件命名

使用 `snake_case`（小写下划线）:

```text
✅ 好的示例
device_security.dart
secure_storage.dart
security_check_result.dart

❌ 不好的示例
DeviceSecurity.dart
deviceSecurity.dart
Device_Security.dart
```

#### 类命名

使用 `PascalCase`（大驼峰）:

```dart
✅ 好的示例
class DeviceSecurity {}
class SecureStorage {}
class SecurityCheckResult {}

❌ 不好的示例
class deviceSecurity {}
class device_security {}
class DEVICESECURITY {}
```

#### 变量和方法命名

使用 `camelCase`（小驼峰）:

```dart
✅ 好的示例
final security = DeviceSecurity();
final checkResult = await security.checkRoot();
final isSecure = checkResult.isSecure;

Future<SecurityCheckResult> checkRoot() async { }

❌ 不好的示例
final Security = DeviceSecurity();
final CheckResult = await security.CheckRoot();
final IsSecure = checkResult.IsSecure;

Future<SecurityCheckResult> CheckRoot() async { }
```

#### 常量命名

使用 `lowerCamelCase`:

```dart
✅ 好的示例
const defaultRiskLevel = 0;
const maxRetries = 3;

❌ 不好的示例
const DEFAULT_RISK_LEVEL = 0;
const MAX_RETRIES = 3;
```

### 代码格式

#### 缩进

使用 2 个空格缩进:

```dart
✅ 好的示例
class SecurityCheckResult {
  final bool isSecure;
  
  SecurityCheckResult({required this.isSecure});
}

❌ 不好的示例
class SecurityCheckResult {
    final bool isSecure;  // 4 个空格
    
    SecurityCheckResult({required this.isSecure});
}
```

#### 行长度

每行最多 80 个字符，超过时适当换行:

```dart
✅ 好的示例
final result = SecurityCheckResult(
  isSecure: false,
  checkType: 'root',
  details: 'Root detected',
  riskLevel: 8,
);

❌ 不好的示例
final result = SecurityCheckResult(isSecure: false, checkType: 'root', details: 'Root detected', riskLevel: 8);
```

#### 尾随逗号

多行参数列表使用尾随逗号:

```dart
✅ 好的示例
return SecurityCheckResult(
  isSecure: isSecure,
  checkType: checkType,
  details: details,
  riskLevel: riskLevel,  // 尾随逗号
);

❌ 不好的示例
return SecurityCheckResult(
  isSecure: isSecure,
  checkType: checkType,
  details: details,
  riskLevel: riskLevel  // 缺少尾随逗号
);
```

### 类型注解

#### 公共 API

必须显式声明返回类型和参数类型:

```dart
✅ 好的示例
Future<SecurityCheckResult> checkRoot() async {
  // ...
}

❌ 不好的示例
checkRoot() async {
  // ...
}
```

#### 局部变量

可以使用类型推断:

```dart
✅ 好的示例
final security = DeviceSecurity();
final result = await security.checkRoot();
final isSecure = result.isSecure;

✅ 也可以
final DeviceSecurity security = DeviceSecurity();
final SecurityCheckResult result = await security.checkRoot();
final bool isSecure = result.isSecure;
```

### 文档注释

#### 公共 API

所有公共类、方法、属性必须有文档注释:

```dart
✅ 好的示例
/// 设备安全检测器
///
/// 提供各种设备安全检查功能，包括 Root/越狱检测、
/// 调试器检测、模拟器检测等。
class DeviceSecurity {
  /// 检测设备是否被 Root/越狱
  ///
  /// 返回包含检测结果和风险级别的 [SecurityCheckResult]。
  ///
  /// 示例:
  /// ```dart
  /// final security = DeviceSecurity();
  /// final result = await security.checkRoot();
  /// if (!result.isSecure) {
  ///   print('警告: 检测到 Root/越狱');
  /// }
  /// ```
  Future<SecurityCheckResult> checkRoot() async {
    // ...
  }
}
```

#### 私有成员

使用行内注释:

```dart
✅ 好的示例
// 检查文件是否存在
Future<bool> _fileExists(String path) async {
  try {
    return await File(path).exists();
  } catch (e) {
    return false;
  }
}
```

### 安全相关代码

#### 敏感数据处理

```dart
✅ 好的示例
// 使用加密存储敏感数据
await storage.write(
  key: 'api_token',
  value: token,
  encrypt: true,  // 明确标记加密
);

// 读取时解密
final token = await storage.read(
  key: 'api_token',
  decrypt: true,  // 明确标记解密
);

❌ 不好的示例
// 敏感数据未加密
await storage.write(
  key: 'api_token',
  value: token,
);
```

#### 错误处理

```dart
✅ 好的示例
Future<SecurityCheckResult> checkRoot() async {
  try {
    // 执行检测
    return SecurityCheckResult(...);
  } catch (e) {
    debugPrint('Root check failed: $e');
    // 返回安全的默认值
    return SecurityCheckResult(
      isSecure: true,
      checkType: 'root',
      details: 'Check failed: $e',
      riskLevel: 0,
    );
  }
}

❌ 不好的示例
Future<SecurityCheckResult> checkRoot() async {
  // 未处理异常，可能导致应用崩溃
  return SecurityCheckResult(...);
}
```

---

## Kotlin 代码风格 (Android)

### 命名规范

#### 类命名

使用 `PascalCase`:

```kotlin
✅ 好的示例
class DeviceSecurityKitPlugin : FlutterPlugin, MethodCallHandler {
}

❌ 不好的示例
class deviceSecurityKitPlugin : FlutterPlugin {
}
```

#### 函数和变量命名

使用 `camelCase`:

```kotlin
✅ 好的示例
private fun checkRoot(): Map<String, Any?> {
  val isRooted = detectRootAccess()
  return mapOf("isRooted" to isRooted)
}

❌ 不好的示例
private fun CheckRoot(): Map<String, Any?> {
  val IsRooted = detectRootAccess()
}
```

### 代码格式

#### 缩进

使用 2 个空格:

```kotlin
✅ 好的示例
override fun onMethodCall(call: MethodCall, result: Result) {
  when (call.method) {
    "checkRoot" -> {
      result.success(checkRoot())
    }
  }
}
```

#### 使用 when 而不是 if-else 链

```kotlin
✅ 好的示例
when (call.method) {
  "checkRoot" -> result.success(checkRoot())
  "checkDebugger" -> result.success(checkDebugger())
  else -> result.notImplemented()
}

❌ 不好的示例
if (call.method == "checkRoot") {
  result.success(checkRoot())
} else if (call.method == "checkDebugger") {
  result.success(checkDebugger())
} else {
  result.notImplemented()
}
```

---

## Swift 代码风格 (iOS)

### 命名规范

#### 类命名

使用 `PascalCase`:

```swift
✅ 好的示例
public class DeviceSecurityKitPlugin: NSObject, FlutterPlugin {
}

❌ 不好的示例
public class deviceSecurityKitPlugin: NSObject {
}
```

#### 函数和变量命名

使用 `camelCase`:

```swift
✅ 好的示例
private func checkJailbreak() -> [String: Any] {
  let isJailbroken = detectJailbreak()
  return ["isJailbroken": isJailbroken]
}

❌ 不好的示例
private func CheckJailbreak() -> [String: Any] {
  let IsJailbroken = detectJailbreak()
}
```

---

## 最佳实践

### 1. 使用 const

尽可能使用 `const`:

```dart
✅ 好的示例
const defaultRiskLevel = 0;
const highRiskThreshold = 7;

❌ 不好的示例
final defaultRiskLevel = 0;
final highRiskThreshold = 7;
```

### 2. 空安全

正确使用可空类型:

```dart
✅ 好的示例
final details = result.details;
if (details != null) {
  print('详情: $details');
}

// 或使用 ?.
print('详情: ${result.details ?? "无"}');

❌ 不好的示例
final details = result.details!;  // 可能崩溃
print('详情: $details');
```

### 3. 异步处理

使用 async/await:

```dart
✅ 好的示例
Future<SecurityCheckResult> checkRoot() async {
  final isRooted = await _detectRoot();
  return SecurityCheckResult(
    isSecure: !isRooted,
    checkType: 'root',
    riskLevel: isRooted ? 8 : 0,
  );
}

❌ 不好的示例
Future<SecurityCheckResult> checkRoot() {
  return _detectRoot().then((isRooted) {
    return SecurityCheckResult(
      isSecure: !isRooted,
      checkType: 'root',
      riskLevel: isRooted ? 8 : 0,
    );
  });
}
```

### 4. 使用单例模式

```dart
✅ 好的示例
class DeviceSecurity {
  static final DeviceSecurity _instance = DeviceSecurity._internal();
  factory DeviceSecurity() => _instance;
  DeviceSecurity._internal();
}

// 使用
final security = DeviceSecurity();
```

### 5. 提供便捷 getter

```dart
✅ 好的示例
class SecurityCheckResult {
  final int riskLevel;
  
  // 便捷 getter
  bool get isHighRisk => riskLevel >= 7;
  bool get isMediumRisk => riskLevel >= 4 && riskLevel < 7;
  bool get isLowRisk => riskLevel > 0 && riskLevel < 4;
}

// 使用
if (result.isHighRisk) {
  print('高风险！');
}
```

### 6. 使用命名参数

```dart
✅ 好的示例
class SecurityCheckResult {
  SecurityCheckResult({
    required this.isSecure,
    required this.checkType,
    this.details,
    required this.riskLevel,
  });
  
  final bool isSecure;
  final String checkType;
  final String? details;
  final int riskLevel;
}

// 使用
final result = SecurityCheckResult(
  isSecure: false,
  checkType: 'root',
  details: 'Root detected',
  riskLevel: 8,
);

❌ 不好的示例
class SecurityCheckResult {
  SecurityCheckResult(this.isSecure, this.checkType, this.details, this.riskLevel);
  
  final bool isSecure;
  final String checkType;
  final String? details;
  final int riskLevel;
}

// 使用 - 不清楚每个参数的含义
final result = SecurityCheckResult(false, 'root', 'Root detected', 8);
```

### 7. 安全的默认值

```dart
✅ 好的示例
Future<SecurityCheckResult> checkRoot() async {
  try {
    // 执行检测
    return SecurityCheckResult(...);
  } catch (e) {
    // 返回安全的默认值
    return SecurityCheckResult(
      isSecure: true,  // 默认安全
      checkType: 'root',
      details: 'Check failed',
      riskLevel: 0,
    );
  }
}
```

---

## 工具

### 格式化

```bash
# 格式化所有文件
dart format .

# 检查格式（不修改）
dart format --output=none --set-exit-if-changed .
```

### 分析

```bash
# 运行代码分析
flutter analyze

# 修复可自动修复的问题
dart fix --apply
```

### 测试

```bash
# 运行所有测试
flutter test

# 运行特定测试
flutter test test/security_check_result_test.dart

# 生成覆盖率报告
flutter test --coverage
```

---

## 提交规范

遵循 [Conventional Commits](https://www.conventionalcommits.org/zh-hans/) 规范。

### 提交消息格式

```text
<类型>(<范围>): <简短描述>

[可选的详细描述]

[可选的 Footer]
```

### 类型

- `feat`: 新功能
- `fix`: 修复 bug
- `docs`: 文档更新
- `style`: 代码格式（不影响功能）
- `refactor`: 重构
- `perf`: 性能优化
- `test`: 测试相关
- `chore`: 构建/工具相关

### 示例

```text
feat(security): 添加 SSL Pinning 检测

- 添加 checkSSLPinning 方法
- 实现证书验证逻辑
- 添加单元测试

Closes #123
```

```text
fix(storage): 修复加密存储的解密问题

修复在某些情况下解密失败的问题。

Fixes #456
```

```text
docs(api): 更新 API 文档

更新 checkRoot 方法的文档说明。
```

---

## 代码审查清单

在提交代码前，请检查：

- [ ] 代码遵循命名规范
- [ ] 使用了正确的缩进和格式
- [ ] 公共 API 有完整的文档注释
- [ ] 处理了所有可能的异常
- [ ] 使用了类型安全的代码
- [ ] 敏感数据使用加密存储
- [ ] 添加了必要的测试
- [ ] 运行 `flutter analyze` 无错误
- [ ] 运行 `flutter test` 所有测试通过
- [ ] 提交消息符合规范

---

**文档版本**: 1.0  
**创建日期**: 2024-03-08  
**项目**: device_security_kit
