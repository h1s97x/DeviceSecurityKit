# device_security_kit 快速参考

本文档提供 device_security_kit 的快速参考指南。

## 快速开始

### 安装

```yaml
dependencies:
  device_security_kit: ^1.0.0
```

```bash
flutter pub get
```

### 基本使用

```dart
import 'package:device_security_kit/device_security_kit.dart';

// 创建实例（单例）
final security = DeviceSecurity();
final storage = SecureStorage();

// 获取安全信息
final info = await security.getSecurityInfo();

// 安全存储
await storage.write(key: 'data', value: 'value');
```

---

## API 速查

### DeviceSecurity 方法

| 方法 | 返回类型 | 说明 |
| --- | --- | --- |
| `getSecurityInfo()` | `Future<DeviceSecurityInfo>` | 获取完整安全信息 |
| `checkRoot()` | `Future<SecurityCheckResult>` | Root/越狱检测 |
| `checkDebugger()` | `Future<SecurityCheckResult>` | 调试器检测 |
| `checkEmulator()` | `Future<SecurityCheckResult>` | 模拟器检测 |
| `checkProxy()` | `Future<SecurityCheckResult>` | 代理检测 |
| `checkVPN()` | `Future<SecurityCheckResult>` | VPN检测 |

### SecureStorage 方法

| 方法 | 返回类型 | 说明 |
| --- | --- | --- |
| `write()` | `Future<void>` | 写入数据 |
| `read()` | `Future<String?>` | 读取数据 |
| `delete()` | `Future<void>` | 删除数据 |
| `deleteAll()` | `Future<void>` | 删除所有数据 |
| `containsKey()` | `Future<bool>` | 检查键是否存在 |
| `readAll()` | `Future<Map<String, String>>` | 读取所有数据 |
| `writeJson()` | `Future<void>` | 写入 JSON 对象 |
| `readJson()` | `Future<Map<String, dynamic>?>` | 读取 JSON 对象 |
| `generateKeyHash()` | `String` | 生成密钥哈希 |

---

## 数据模型速查

### SecurityCheckResult

```dart
class SecurityCheckResult {
  final bool isSecure;          // 是否安全
  final String checkType;       // 检查类型
  final String? details;        // 详细信息
  final int riskLevel;          // 风险级别 (0-10)
  final DateTime timestamp;     // 检查时间
  
  // 便捷 getter
  bool get isHighRisk;          // >= 7
  bool get isMediumRisk;        // 4-6
  bool get isLowRisk;           // 1-3
}
```

### DeviceSecurityInfo

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
  bool get isSecure;            // >= 70分
  bool get hasHighRisk;         // 是否有高风险项
}
```

### SecurityReport

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

## 常用代码片段

### 完整安全检查

```dart
final security = DeviceSecurity();
final info = await security.getSecurityInfo();

print('安全评分: ${info.securityScore}');
print('是否安全: ${info.isSecure}');
print('高风险: ${info.hasHighRisk}');
```

### Root/越狱检测

```dart
final security = DeviceSecurity();
final result = await security.checkRoot();

if (!result.isSecure) {
  print('警告: 检测到 Root/越狱');
  print('风险级别: ${result.riskLevel}');
}
```

### 调试器检测

```dart
final security = DeviceSecurity();
final result = await security.checkDebugger();

if (!result.isSecure) {
  print('警告: 应用正在调试模式运行');
}
```

### 模拟器检测

```dart
final security = DeviceSecurity();
final result = await security.checkEmulator();

if (!result.isSecure) {
  print('警告: 应用运行在模拟器上');
}
```

### 代理检测

```dart
final security = DeviceSecurity();
final result = await security.checkProxy();

if (!result.isSecure) {
  print('警告: 检测到网络代理');
}
```

### VPN检测

```dart
final security = DeviceSecurity();
final result = await security.checkVPN();

if (!result.isSecure) {
  print('提示: 检测到 VPN 连接');
}
```

### 基本存储操作

```dart
final storage = SecureStorage();

// 写入
await storage.write(key: 'username', value: 'john_doe');

// 读取
final username = await storage.read(key: 'username');
print('Username: $username');

// 删除
await storage.delete(key: 'username');

// 检查存在
final exists = await storage.containsKey(key: 'username');
```

### 加密存储

```dart
final storage = SecureStorage();

// 加密写入
await storage.write(
  key: 'api_token',
  value: 'secret_token_123',
  encrypt: true,
);

// 解密读取
final token = await storage.read(
  key: 'api_token',
  decrypt: true,
);
```

### JSON 存储

```dart
final storage = SecureStorage();

// 存储 JSON
final userData = {
  'name': 'John Doe',
  'email': 'john@example.com',
  'age': 30,
};

await storage.writeJson(
  key: 'user_data',
  value: userData,
  encrypt: true,
);

// 读取 JSON
final data = await storage.readJson(
  key: 'user_data',
  decrypt: true,
);

print('Name: ${data?['name']}');
```

### 密码哈希

```dart
final storage = SecureStorage();

// 生成哈希
final passwordHash = storage.generateKeyHash('user_password_123');
await storage.write(key: 'password_hash', value: passwordHash);

// 验证密码
final inputHash = storage.generateKeyHash(userInput);
final storedHash = await storage.read(key: 'password_hash');

if (inputHash == storedHash) {
  print('密码正确');
}
```

### 错误处理

```dart
try {
  final info = await security.getSecurityInfo();
  // 使用安全信息
} catch (e) {
  print('安全检查失败: $e');
  // 降级处理
}

try {
  await storage.write(key: 'data', value: 'value');
} catch (e) {
  print('存储失败: $e');
  // 使用备用方案
}
```

### 在 Widget 中使用

```dart
class SecurityWidget extends StatefulWidget {
  @override
  State<SecurityWidget> createState() => _SecurityWidgetState();
}

class _SecurityWidgetState extends State<SecurityWidget> {
  final _security = DeviceSecurity();
  DeviceSecurityInfo? _info;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _checkSecurity();
  }

  Future<void> _checkSecurity() async {
    setState(() => _loading = true);
    
    try {
      final info = await _security.getSecurityInfo();
      setState(() {
        _info = info;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return CircularProgressIndicator();
    }
    
    return Column(
      children: [
        Text('安全评分: ${_info?.securityScore}'),
        Text(_info?.isSecure == true ? '✅ 安全' : '⚠️ 不安全'),
      ],
    );
  }
}
```

---

## 平台支持

| 平台 | 状态 | 说明 |
| --- | --- | --- |
| Android | ✅ 完全支持 | API 21+ |
| iOS | ✅ 完全支持 | iOS 12.0+ |
| Windows | ⚠️ 部分支持 | 部分功能 |
| Linux | ⚠️ 部分支持 | 部分功能 |
| macOS | ⚠️ 部分支持 | 部分功能 |
| Web | ❌ 不支持 | 浏览器限制 |

---

## 使用场景

### 金融应用

```dart
Future<bool> canPerformTransaction() async {
  final security = DeviceSecurity();
  final info = await security.getSecurityInfo();
  
  // 要求高安全标准
  if (info.securityScore < 80) return false;
  
  // 不允许 Root/越狱
  if (info.rootCheck?.isSecure == false) return false;
  
  // 不允许模拟器
  if (info.emulatorCheck?.isSecure == false) return false;
  
  return true;
}
```

### 游戏应用

```dart
Future<void> checkAntiCheat() async {
  final security = DeviceSecurity();
  final info = await security.getSecurityInfo();
  
  // 检测调试器（防作弊）
  if (info.debuggerCheck?.isSecure == false) {
    showCheatWarning();
    return;
  }
  
  // 检测模拟器（防刷）
  if (info.emulatorCheck?.isSecure == false) {
    limitGameFeatures();
    return;
  }
}
```

### 企业应用

```dart
Future<void> storeCredentials(String username, String password) async {
  final security = DeviceSecurity();
  final storage = SecureStorage();
  
  // 检查设备安全性
  final info = await security.getSecurityInfo();
  if (!info.isSecure) {
    throw SecurityException('设备不安全');
  }
  
  // 使用安全存储
  await storage.write(key: 'username', value: username, encrypt: true);
  
  final passwordHash = storage.generateKeyHash(password);
  await storage.write(key: 'password_hash', value: passwordHash, encrypt: true);
}
```

---

## 性能提示

### 1. 缓存检查结果

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

### 2. 按需检查

```dart
// 只检查需要的项
final rootCheck = await security.checkRoot();
if (!rootCheck.isSecure) {
  // 处理 Root 情况
  return;
}

// 只有在需要时才检查其他项
final debuggerCheck = await security.checkDebugger();
```

### 3. 使用单例

```dart
// 推荐
final security = DeviceSecurity();
final storage = SecureStorage();

// 不推荐
final security1 = DeviceSecurity();
final security2 = DeviceSecurity();
```

---

## 常见问题

### Q: 如何判断设备是否安全？

```dart
final info = await security.getSecurityInfo();

// 方法 1: 使用安全评分
if (info.securityScore >= 70) {
  print('设备安全');
}

// 方法 2: 使用便捷 getter
if (info.isSecure) {
  print('设备安全');
}

// 方法 3: 检查高风险项
if (!info.hasHighRisk) {
  print('无高风险项');
}
```

### Q: 如何处理检测失败？

```dart
final result = await security.checkRoot();

if (!result.isSecure) {
  // 根据风险级别采取不同措施
  if (result.isHighRisk) {
    // 高风险: 禁止使用
    showError('设备不安全，无法使用');
  } else if (result.isMediumRisk) {
    // 中风险: 警告用户
    showWarning('检测到安全风险');
  } else {
    // 低风险: 记录日志
    logWarning('低风险: ${result.details}');
  }
}
```

### Q: 如何安全存储敏感数据？

```dart
final storage = SecureStorage();

// 始终使用加密
await storage.write(
  key: 'sensitive_data',
  value: sensitiveValue,
  encrypt: true,  // 重要！
);

// 读取时解密
final data = await storage.read(
  key: 'sensitive_data',
  decrypt: true,  // 重要！
);
```

### Q: 如何在应用启动时检查安全性？

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 执行安全检查
  final security = DeviceSecurity();
  final info = await security.getSecurityInfo();
  
  if (!info.isSecure) {
    print('警告: 设备环境不安全');
    // 可以选择显示警告或限制功能
  }
  
  runApp(MyApp());
}
```

---

## 相关链接

- [完整 API 文档](API.md)
- [用户指南](USER%20GUIDE.md)
- [架构设计](ARCHITECTURE.md)
- [代码风格指南](CODE_STYLE.md)
- [贡献指南](../CONTRIBUTING.md)
- [GitHub 仓库](https://github.com/h1s97x/DeviceSecurityKit)

---

**文档版本**: 1.0  
**创建日期**: 2024-03-08  
**项目**: device_security_kit
