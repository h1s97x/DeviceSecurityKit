# device_security_kit API 参考

本文档提供 device_security_kit 的完整 API 参考。

## 目录

- [DeviceSecurity](#devicesecurity)
  - [实例方法](#实例方法)
  - [安全检查方法](#安全检查方法)
- [SecureStorage](#securestorage)
  - [基本操作](#基本操作)
  - [加密操作](#加密操作)
  - [JSON 操作](#json-操作)
  - [工具方法](#工具方法)
- [数据模型](#数据模型)
  - [SecurityCheckResult](#securitycheckresult)
  - [DeviceSecurityInfo](#devicesecurityinfo)
  - [SecurityReport](#securityreport)
- [完整示例](#完整示例)

---

## DeviceSecurity

主类，用于执行设备安全检测。使用单例模式。

### 实例方法

#### getSecurityInfo

```dart
Future<DeviceSecurityInfo> getSecurityInfo()
```

获取完整的设备安全信息，包含所有安全检查结果。

**返回:** `Future<DeviceSecurityInfo>` - 包含所有安全检查结果的对象

**示例:**

```dart
final security = DeviceSecurity();
final info = await security.getSecurityInfo();

print('安全评分: ${info.securityScore}');
print('是否安全: ${info.isSecure}');
print('高风险: ${info.hasHighRisk}');
```

### 安全检查方法

#### checkRoot

```dart
Future<SecurityCheckResult> checkRoot()
```

检测设备是否被 Root（Android）或越狱（iOS）。

**检测内容:**
- Android: su 命令、Superuser.apk、Root 管理器、test-keys
- iOS: Cydia、越狱文件、可写系统目录

**返回:** `Future<SecurityCheckResult>` - Root/越狱检测结果

**示例:**

```dart
final security = DeviceSecurity();
final result = await security.checkRoot();

if (!result.isSecure) {
  print('警告: 检测到 Root/越狱');
  print('风险级别: ${result.riskLevel}');
  print('详情: ${result.details}');
}
```

#### checkDebugger

```dart
Future<SecurityCheckResult> checkDebugger()
```

检测应用是否在调试模式下运行。

**返回:** `Future<SecurityCheckResult>` - 调试器检测结果

**示例:**

```dart
final security = DeviceSecurity();
final result = await security.checkDebugger();

if (!result.isSecure) {
  print('警告: 应用正在调试模式运行');
  // 可以选择禁用某些敏感功能
}
```

#### checkEmulator

```dart
Future<SecurityCheckResult> checkEmulator()
```

检测应用是否运行在模拟器/仿真器上。

**检测内容:**
- Android: 设备型号、品牌、构建标签
- iOS: 物理设备检查

**返回:** `Future<SecurityCheckResult>` - 模拟器检测结果

**示例:**

```dart
final security = DeviceSecurity();
final result = await security.checkEmulator();

if (!result.isSecure) {
  print('警告: 应用运行在模拟器上');
  // 某些应用可能需要限制模拟器访问
}
```

#### checkProxy

```dart
Future<SecurityCheckResult> checkProxy()
```

检测是否配置了网络代理。

**检测内容:**
- 环境变量中的 HTTP_PROXY、HTTPS_PROXY

**返回:** `Future<SecurityCheckResult>` - 代理检测结果

**示例:**

```dart
final security = DeviceSecurity();
final result = await security.checkProxy();

if (!result.isSecure) {
  print('警告: 检测到网络代理');
  // 可能存在中间人攻击风险
}
```

#### checkVPN

```dart
Future<SecurityCheckResult> checkVPN()
```

检测是否连接了 VPN。

**检测内容:**
- 网络接口分析（tun、ppp、vpn）

**返回:** `Future<SecurityCheckResult>` - VPN 检测结果

**示例:**

```dart
final security = DeviceSecurity();
final result = await security.checkVPN();

if (!result.isSecure) {
  print('提示: 检测到 VPN 连接');
  // 某些应用可能需要限制 VPN 使用
}
```

---

## SecureStorage

安全存储类，提供加密的本地数据存储。使用单例模式。

### 基本操作

#### write

```dart
Future<void> write({
  required String key,
  required String value,
  bool encrypt = false,
})
```

写入数据到安全存储。

**参数:**
- `key`: 存储键
- `value`: 存储值
- `encrypt`: 是否加密（默认 false）

**示例:**

```dart
final storage = SecureStorage();

// 普通存储
await storage.write(
  key: 'username',
  value: 'john_doe',
);

// 加密存储
await storage.write(
  key: 'api_token',
  value: 'secret_token_123',
  encrypt: true,
);
```

#### read

```dart
Future<String?> read({
  required String key,
  bool decrypt = false,
})
```

从安全存储读取数据。

**参数:**
- `key`: 存储键
- `decrypt`: 是否解密（默认 false）

**返回:** `Future<String?>` - 存储的值，不存在则返回 null

**示例:**

```dart
final storage = SecureStorage();

// 普通读取
final username = await storage.read(key: 'username');
print('Username: $username');

// 解密读取
final token = await storage.read(
  key: 'api_token',
  decrypt: true,
);
print('Token: $token');
```

#### delete

```dart
Future<void> delete({required String key})
```

删除指定键的数据。

**参数:**
- `key`: 要删除的键

**示例:**

```dart
final storage = SecureStorage();
await storage.delete(key: 'username');
```

#### deleteAll

```dart
Future<void> deleteAll()
```

删除所有存储的数据。

**示例:**

```dart
final storage = SecureStorage();
await storage.deleteAll();
```

#### containsKey

```dart
Future<bool> containsKey({required String key})
```

检查键是否存在。

**参数:**
- `key`: 要检查的键

**返回:** `Future<bool>` - 键是否存在

**示例:**

```dart
final storage = SecureStorage();
final exists = await storage.containsKey(key: 'username');

if (exists) {
  print('用户名已存储');
}
```

#### readAll

```dart
Future<Map<String, String>> readAll()
```

读取所有存储的数据。

**返回:** `Future<Map<String, String>>` - 所有键值对

**示例:**

```dart
final storage = SecureStorage();
final allData = await storage.readAll();

print('存储的键: ${allData.keys}');
allData.forEach((key, value) {
  print('$key: $value');
});
```

### 加密操作

加密和解密使用 Base64 编码（示例实现）。实际应用中应使用更强的加密算法如 AES。

### JSON 操作

#### writeJson

```dart
Future<void> writeJson({
  required String key,
  required Map<String, dynamic> value,
  bool encrypt = false,
})
```

存储 JSON 对象。

**参数:**
- `key`: 存储键
- `value`: JSON 对象
- `encrypt`: 是否加密（默认 false）

**示例:**

```dart
final storage = SecureStorage();

final userData = {
  'name': 'John Doe',
  'email': 'john@example.com',
  'age': 30,
  'preferences': {
    'theme': 'dark',
    'language': 'zh-CN',
  },
};

await storage.writeJson(
  key: 'user_data',
  value: userData,
  encrypt: true,
);
```

#### readJson

```dart
Future<Map<String, dynamic>?> readJson({
  required String key,
  bool decrypt = false,
})
```

读取 JSON 对象。

**参数:**
- `key`: 存储键
- `decrypt`: 是否解密（默认 false）

**返回:** `Future<Map<String, dynamic>?>` - JSON 对象，不存在或解析失败则返回 null

**示例:**

```dart
final storage = SecureStorage();

final userData = await storage.readJson(
  key: 'user_data',
  decrypt: true,
);

if (userData != null) {
  print('Name: ${userData['name']}');
  print('Email: ${userData['email']}');
  print('Age: ${userData['age']}');
}
```

### 工具方法

#### generateKeyHash

```dart
String generateKeyHash(String input)
```

生成输入字符串的 SHA-256 哈希值。

**参数:**
- `input`: 输入字符串

**返回:** `String` - SHA-256 哈希值（十六进制字符串）

**示例:**

```dart
final storage = SecureStorage();

// 生成密码哈希
final passwordHash = storage.generateKeyHash('user_password_123');
await storage.write(key: 'password_hash', value: passwordHash);

// 验证密码
final inputHash = storage.generateKeyHash(userInput);
final storedHash = await storage.read(key: 'password_hash');

if (inputHash == storedHash) {
  print('密码正确');
} else {
  print('密码错误');
}
```

---

## 数据模型

### SecurityCheckResult

单项安全检查的结果。

```dart
class SecurityCheckResult {
  final bool isSecure;          // 是否安全
  final String checkType;       // 检查类型
  final String? details;        // 详细信息
  final int riskLevel;          // 风险级别 (0-10)
  final DateTime timestamp;     // 检查时间
  
  // 便捷 getter
  bool get isHighRisk;          // 是否高风险 (>= 7)
  bool get isMediumRisk;        // 是否中风险 (4-6)
  bool get isLowRisk;           // 是否低风险 (1-3)
}
```

**风险级别说明:**
- 0: 安全
- 1-3: 低风险
- 4-6: 中风险
- 7-10: 高风险

**示例:**

```dart
final result = await security.checkRoot();

print('是否安全: ${result.isSecure}');
print('检查类型: ${result.checkType}');
print('风险级别: ${result.riskLevel}');
print('详情: ${result.details}');

if (result.isHighRisk) {
  print('高风险警告！');
} else if (result.isMediumRisk) {
  print('中等风险');
} else if (result.isLowRisk) {
  print('低风险');
}
```

### DeviceSecurityInfo

设备安全综合信息。

```dart
class DeviceSecurityInfo {
  final SecurityCheckResult? rootCheck;       // Root/越狱检测
  final SecurityCheckResult? debuggerCheck;   // 调试器检测
  final SecurityCheckResult? emulatorCheck;   // 模拟器检测
  final SecurityCheckResult? proxyCheck;      // 代理检测
  final SecurityCheckResult? vpnCheck;        // VPN检测
  final int securityScore;                    // 安全评分 (0-100)
  final DateTime timestamp;                   // 检查时间
  
  // 便捷 getter
  bool get isSecure;                          // 是否安全 (>= 70分)
  bool get hasHighRisk;                       // 是否有高风险项
}
```

**安全评分计算:**
- 基于所有检查项的平均风险级别
- 分数范围: 0-100（100 最安全）
- >= 70 分视为安全

**示例:**

```dart
final info = await security.getSecurityInfo();

print('安全评分: ${info.securityScore}/100');
print('是否安全: ${info.isSecure}');
print('高风险: ${info.hasHighRisk}');

// 检查各项结果
if (info.rootCheck != null && !info.rootCheck!.isSecure) {
  print('Root 检测失败');
}

if (info.debuggerCheck != null && !info.debuggerCheck!.isSecure) {
  print('调试器检测失败');
}

// 转换为 JSON
final json = info.toJson();
print(json);
```

### SecurityReport

安全报告，包含多个检查结果的汇总。

```dart
class SecurityReport {
  final List<SecurityCheckResult> checks;     // 所有检查结果
  final DateTime timestamp;                   // 生成时间
  
  // 便捷 getter
  bool get isSecure;                          // 是否整体安全
  int get totalRiskLevel;                     // 总风险级别
  double get averageRiskLevel;                // 平均风险级别
  List<SecurityCheckResult> get highRiskChecks;    // 高风险检查
  List<SecurityCheckResult> get mediumRiskChecks;  // 中风险检查
  List<SecurityCheckResult> get lowRiskChecks;     // 低风险检查
  List<SecurityCheckResult> get failedChecks;      // 失败的检查
}
```

**示例:**

```dart
// 创建安全报告
final checks = [
  await security.checkRoot(),
  await security.checkDebugger(),
  await security.checkEmulator(),
  await security.checkProxy(),
  await security.checkVPN(),
];

final report = SecurityReport(checks: checks);

print('整体安全: ${report.isSecure}');
print('总风险级别: ${report.totalRiskLevel}');
print('平均风险级别: ${report.averageRiskLevel.toStringAsFixed(1)}');

// 高风险项
if (report.highRiskChecks.isNotEmpty) {
  print('高风险项:');
  for (final check in report.highRiskChecks) {
    print('  - ${check.checkType}: ${check.details}');
  }
}

// 失败的检查
if (report.failedChecks.isNotEmpty) {
  print('失败的检查:');
  for (final check in report.failedChecks) {
    print('  - ${check.checkType}');
  }
}
```

---

## 完整示例

### 基础安全检查

```dart
import 'package:flutter/material.dart';
import 'package:device_security_kit/device_security_kit.dart';

class SecurityCheckPage extends StatefulWidget {
  const SecurityCheckPage({super.key});

  @override
  State<SecurityCheckPage> createState() => _SecurityCheckPageState();
}

class _SecurityCheckPageState extends State<SecurityCheckPage> {
  final _security = DeviceSecurity();
  DeviceSecurityInfo? _securityInfo;
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
        _securityInfo = info;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('安全检查失败: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_securityInfo == null) {
      return const Center(child: Text('无法获取安全信息'));
    }

    final info = _securityInfo!;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildScoreCard(info),
        const SizedBox(height: 16),
        _buildCheckItem('Root/越狱检测', info.rootCheck),
        _buildCheckItem('调试器检测', info.debuggerCheck),
        _buildCheckItem('模拟器检测', info.emulatorCheck),
        _buildCheckItem('代理检测', info.proxyCheck),
        _buildCheckItem('VPN检测', info.vpnCheck),
      ],
    );
  }

  Widget _buildScoreCard(DeviceSecurityInfo info) {
    final color = info.isSecure ? Colors.green : Colors.red;
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              '安全评分',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              '${info.securityScore}',
              style: TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              info.isSecure ? '✅ 安全' : '⚠️ 不安全',
              style: TextStyle(
                fontSize: 18,
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (info.hasHighRisk)
              const Padding(
                padding: EdgeInsets.only(top: 8),
                child: Text(
                  '检测到高风险！',
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCheckItem(String title, SecurityCheckResult? result) {
    if (result == null) return const SizedBox.shrink();

    final icon = result.isSecure ? Icons.check_circle : Icons.warning;
    final color = result.isSecure ? Colors.green : Colors.red;

    return Card(
      child: ListTile(
        leading: Icon(icon, color: color),
        title: Text(title),
        subtitle: Text(result.details ?? ''),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '风险: ${result.riskLevel}',
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (result.isHighRisk)
              const Text(
                '高风险',
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 12,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
```

### 安全存储示例

```dart
import 'package:device_security_kit/device_security_kit.dart';

class UserManager {
  final _storage = SecureStorage();

  // 保存用户凭据
  Future<void> saveCredentials(String username, String password) async {
    // 保存用户名
    await _storage.write(
      key: 'username',
      value: username,
    );

    // 保存密码哈希
    final passwordHash = _storage.generateKeyHash(password);
    await _storage.write(
      key: 'password_hash',
      value: passwordHash,
      encrypt: true,
    );
  }

  // 验证凭据
  Future<bool> verifyCredentials(String username, String password) async {
    final storedUsername = await _storage.read(key: 'username');
    if (storedUsername != username) {
      return false;
    }

    final storedHash = await _storage.read(
      key: 'password_hash',
      decrypt: true,
    );
    
    final inputHash = _storage.generateKeyHash(password);
    return inputHash == storedHash;
  }

  // 保存用户数据
  Future<void> saveUserData(Map<String, dynamic> userData) async {
    await _storage.writeJson(
      key: 'user_data',
      value: userData,
      encrypt: true,
    );
  }

  // 读取用户数据
  Future<Map<String, dynamic>?> getUserData() async {
    return await _storage.readJson(
      key: 'user_data',
      decrypt: true,
    );
  }

  // 清除所有数据
  Future<void> logout() async {
    await _storage.deleteAll();
  }
}
```

---

**文档版本**: 1.0  
**更新日期**: 2024-03-08  
**项目**: device_security_kit
