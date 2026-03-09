# Getting Started with Device Security Kit

本指南将帮助你快速开始使用 Device Security Kit。

## 安装

在 `pubspec.yaml` 中添加依赖：

```yaml
dependencies:
  device_security_kit: ^1.0.0
```

运行：

```bash
flutter pub get
```

## 基础使用

### 1. 导入包

```dart
import 'package:device_security_kit/device_security_kit.dart';
```

### 2. 创建实例

```dart
final security = DeviceSecurity();
final storage = SecureStorage();
```

## 安全检测

### Root/越狱检测

```dart
final rootCheck = await security.checkRoot();

print('是否安全: ${rootCheck.isSecure}');
print('检查类型: ${rootCheck.checkType}');
print('风险级别: ${rootCheck.riskLevel}');
print('详细信息: ${rootCheck.details}');

// 判断风险级别
if (rootCheck.isHighRisk) {
  print('高风险: 检测到 Root/越狱！');
} else if (rootCheck.isMediumRisk) {
  print('中风险');
} else if (rootCheck.isLowRisk) {
  print('低风险');
} else {
  print('安全');
}
```

### 调试器检测

```dart
final debuggerCheck = await security.checkDebugger();

if (!debuggerCheck.isSecure) {
  print('警告: 应用正在调试模式运行');
  // 可以选择禁用某些功能或显示警告
}
```

### 模拟器检测

```dart
final emulatorCheck = await security.checkEmulator();

if (!emulatorCheck.isSecure) {
  print('警告: 应用运行在模拟器上');
  // 某些应用可能需要限制模拟器访问
}
```

### 代理检测

```dart
final proxyCheck = await security.checkProxy();

if (!proxyCheck.isSecure) {
  print('警告: 检测到网络代理');
  // 可能存在中间人攻击风险
}
```

### VPN检测

```dart
final vpnCheck = await security.checkVPN();

if (!vpnCheck.isSecure) {
  print('提示: 检测到 VPN 连接');
  // 某些应用可能需要限制 VPN 使用
}
```

### 综合安全检查

```dart
final securityInfo = await security.getSecurityInfo();

// 安全评分 (0-100)
print('安全评分: ${securityInfo.securityScore}');

// 是否安全 (>= 70分)
print('是否安全: ${securityInfo.isSecure}');

// 是否有高风险项
print('高风险: ${securityInfo.hasHighRisk}');

// 检查各项结果
if (securityInfo.rootCheck != null) {
  print('Root检测: ${securityInfo.rootCheck!.isSecure}');
}

if (securityInfo.debuggerCheck != null) {
  print('调试器: ${securityInfo.debuggerCheck!.isSecure}');
}

if (securityInfo.emulatorCheck != null) {
  print('模拟器: ${securityInfo.emulatorCheck!.isSecure}');
}

if (securityInfo.proxyCheck != null) {
  print('代理: ${securityInfo.proxyCheck!.isSecure}');
}

if (securityInfo.vpnCheck != null) {
  print('VPN: ${securityInfo.vpnCheck!.isSecure}');
}
```

## 安全存储

### 基本操作

```dart
final storage = SecureStorage();

// 写入数据
await storage.write(
  key: 'username',
  value: 'john_doe',
);

// 读取数据
final username = await storage.read(key: 'username');
print('Username: $username');

// 删除数据
await storage.delete(key: 'username');

// 检查键是否存在
final exists = await storage.containsKey(key: 'username');
print('Exists: $exists');

// 删除所有数据
await storage.deleteAll();
```

### 加密存储

```dart
// 写入加密数据
await storage.write(
  key: 'api_token',
  value: 'your_secret_token_here',
  encrypt: true,  // 启用加密
);

// 读取加密数据
final token = await storage.read(
  key: 'api_token',
  decrypt: true,  // 启用解密
);
print('Token: $token');
```

### JSON 存储

```dart
// 存储 JSON 对象
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

// 读取 JSON 对象
final data = await storage.readJson(
  key: 'user_data',
  decrypt: true,
);

print('Name: ${data?['name']}');
print('Email: ${data?['email']}');
```

### 批量操作

```dart
// 读取所有数据
final allData = await storage.readAll();
print('所有键: ${allData.keys}');

// 遍历所有数据
allData.forEach((key, value) {
  print('$key: $value');
});
```

### 密钥哈希

```dart
// 生成密钥哈希（用于密码等）
final passwordHash = storage.generateKeyHash('user_password_123');
print('Hash: $passwordHash');

// 验证密码
final inputHash = storage.generateKeyHash(userInput);
if (inputHash == storedHash) {
  print('密码正确');
}
```

## 在 Flutter Widget 中使用

### StatefulWidget 示例

```dart
class SecurityCheckWidget extends StatefulWidget {
  @override
  _SecurityCheckWidgetState createState() => _SecurityCheckWidgetState();
}

class _SecurityCheckWidgetState extends State<SecurityCheckWidget> {
  final _security = DeviceSecurity();
  DeviceSecurityInfo? _securityInfo;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkSecurity();
  }

  Future<void> _checkSecurity() async {
    setState(() => _isLoading = true);
    
    try {
      final info = await _security.getSecurityInfo();
      setState(() {
        _securityInfo = info;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      print('安全检查失败: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return CircularProgressIndicator();
    }

    if (_securityInfo == null) {
      return Text('无法获取安全信息');
    }

    return Column(
      children: [
        Text('安全评分: ${_securityInfo!.securityScore}'),
        Text(
          _securityInfo!.isSecure ? '✅ 安全' : '⚠️ 不安全',
          style: TextStyle(
            color: _securityInfo!.isSecure ? Colors.green : Colors.red,
            fontWeight: FontWeight.bold,
          ),
        ),
        if (_securityInfo!.hasHighRisk)
          Text(
            '检测到高风险！',
            style: TextStyle(color: Colors.red),
          ),
      ],
    );
  }
}
```

### 应用启动时检查

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 执行安全检查
  final security = DeviceSecurity();
  final info = await security.getSecurityInfo();
  
  if (!info.isSecure) {
    print('警告: 设备环境不安全');
    // 可以选择显示警告对话框或限制功能
  }
  
  runApp(MyApp());
}
```

### 敏感操作前检查

```dart
Future<void> performPayment() async {
  // 执行支付前检查安全性
  final security = DeviceSecurity();
  final info = await security.getSecurityInfo();
  
  if (info.hasHighRisk) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('安全警告'),
        content: Text('检测到安全风险，无法完成支付'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('确定'),
          ),
        ],
      ),
    );
    return;
  }
  
  // 继续支付流程
  await processPayment();
}
```

## 实际应用场景

### 场景 1: 金融应用

```dart
class BankingApp {
  final _security = DeviceSecurity();
  
  Future<bool> canPerformTransaction() async {
    final info = await _security.getSecurityInfo();
    
    // 金融应用要求更高的安全标准
    if (info.securityScore < 80) {
      return false;
    }
    
    // 不允许 Root/越狱设备
    if (info.rootCheck?.isSecure == false) {
      return false;
    }
    
    // 不允许模拟器
    if (info.emulatorCheck?.isSecure == false) {
      return false;
    }
    
    return true;
  }
}
```

### 场景 2: 游戏应用

```dart
class GameApp {
  final _security = DeviceSecurity();
  
  Future<void> checkAntiCheat() async {
    final info = await _security.getSecurityInfo();
    
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
}
```

### 场景 3: 企业应用

```dart
class EnterpriseApp {
  final _security = DeviceSecurity();
  final _storage = SecureStorage();
  
  Future<void> storeCredentials(String username, String password) async {
    // 检查设备安全性
    final info = await _security.getSecurityInfo();
    
    if (!info.isSecure) {
      throw SecurityException('设备不安全，无法存储凭据');
    }
    
    // 使用安全存储
    await _storage.write(
      key: 'username',
      value: username,
      encrypt: true,
    );
    
    final passwordHash = _storage.generateKeyHash(password);
    await _storage.write(
      key: 'password_hash',
      value: passwordHash,
      encrypt: true,
    );
  }
}
```

## 错误处理

```dart
try {
  final info = await security.getSecurityInfo();
  // 使用安全信息
} catch (e) {
  print('安全检查失败: $e');
  // 降级处理或显示错误
}

try {
  await storage.write(key: 'data', value: 'value');
} catch (e) {
  print('存储失败: $e');
  // 使用备用存储方案
}
```

## 性能优化

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

## 故障排除

### 检测失败

如果检测失败，检查返回的详细信息：

```dart
final check = await security.checkRoot();
if (check.details != null) {
  print('详情: ${check.details}');
}
```

### 存储失败

确保应用有必要的权限：

```dart
try {
  await storage.write(key: 'test', value: 'value');
} catch (e) {
  print('存储失败: $e');
  // 检查权限或使用备用方案
}
```

## 下一步

- 查看 [README.md](README.md) 了解更多功能
- 运行 [example](example/) 查看完整示例
- 查看 [CHANGELOG.md](CHANGELOG.md) 了解版本历史

## 支持

如有问题或建议，请访问：
- GitHub Issues: https://github.com/h1s97x/DeviceSecurityKit/issues
- 文档: https://github.com/h1s97x/DeviceSecurityKit
