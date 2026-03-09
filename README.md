# Device Security Kit

一个功能全面的 Flutter 设备安全工具包，提供 Root/越狱检测、调试器检测、模拟器检测、代理检测、VPN检测和安全存储功能。

## 功能特性

- ✅ **Root/越狱检测**: 检测 Android Root 和 iOS 越狱
- ✅ **调试器检测**: 检测应用是否在调试模式运行
- ✅ **模拟器检测**: 检测应用是否在模拟器/模拟器上运行
- ✅ **代理检测**: 检测网络代理设置
- ✅ **VPN检测**: 检测 VPN 连接
- ✅ **安全存储**: 加密的本地数据存储
- ✅ **安全评分**: 综合安全评分系统
- ✅ **风险级别**: 多级风险评估（高/中/低）
- ✅ **跨平台支持**: Android、iOS、Windows、Linux、macOS

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

## 快速开始

### 1. Root/越狱检测

```dart
import 'package:device_security_kit/device_security_kit.dart';

final security = DeviceSecurity();

// 检测 Root/越狱
final rootCheck = await security.checkRoot();
print('是否安全: ${rootCheck.isSecure}');
print('风险级别: ${rootCheck.riskLevel}');
print('详情: ${rootCheck.details}');

if (!rootCheck.isSecure) {
  print('警告: 检测到 Root/越狱设备！');
}
```

### 2. 调试器检测

```dart
final debuggerCheck = await security.checkDebugger();
if (!debuggerCheck.isSecure) {
  print('警告: 检测到调试器！');
}
```

### 3. 模拟器检测

```dart
final emulatorCheck = await security.checkEmulator();
if (!emulatorCheck.isSecure) {
  print('警告: 运行在模拟器上！');
}
```

### 4. 代理检测

```dart
final proxyCheck = await security.checkProxy();
if (!proxyCheck.isSecure) {
  print('警告: 检测到代理设置！');
}
```

### 5. VPN检测

```dart
final vpnCheck = await security.checkVPN();
if (!vpnCheck.isSecure) {
  print('警告: 检测到 VPN 连接！');
}
```

### 6. 综合安全检查

```dart
final securityInfo = await security.getSecurityInfo();

print('安全评分: ${securityInfo.securityScore}/100');
print('是否安全: ${securityInfo.isSecure}');
print('是否有高风险: ${securityInfo.hasHighRisk}');

// 检查各项结果
if (securityInfo.rootCheck != null) {
  print('Root检测: ${securityInfo.rootCheck!.isSecure}');
}
if (securityInfo.debuggerCheck != null) {
  print('调试器检测: ${securityInfo.debuggerCheck!.isSecure}');
}
```

### 7. 安全存储

```dart
final storage = SecureStorage();

// 写入数据（加密）
await storage.write(
  key: 'api_token',
  value: 'your_secret_token',
  encrypt: true,
);

// 读取数据（解密）
final token = await storage.read(
  key: 'api_token',
  decrypt: true,
);
print('Token: $token');

// 存储 JSON
await storage.writeJson(
  key: 'user_data',
  value: {'name': 'John', 'age': 30},
  encrypt: true,
);

// 读取 JSON
final userData = await storage.readJson(
  key: 'user_data',
  decrypt: true,
);
print('User: ${userData?['name']}');

// 删除数据
await storage.delete(key: 'api_token');

// 清空所有数据
await storage.deleteAll();
```

## 完整示例

```dart
import 'package:flutter/material.dart';
import 'package:device_security_kit/device_security_kit.dart';

class SecurityCheckPage extends StatefulWidget {
  @override
  _SecurityCheckPageState createState() => _SecurityCheckPageState();
}

class _SecurityCheckPageState extends State<SecurityCheckPage> {
  final _security = DeviceSecurity();
  DeviceSecurityInfo? _securityInfo;

  @override
  void initState() {
    super.initState();
    _checkSecurity();
  }

  Future<void> _checkSecurity() async {
    final info = await _security.getSecurityInfo();
    setState(() => _securityInfo = info);

    // 根据安全评分采取行动
    if (info.securityScore < 50) {
      _showSecurityWarning();
    }
  }

  void _showSecurityWarning() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('安全警告'),
        content: Text('检测到安全风险，请在安全环境下使用应用'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('确定'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_securityInfo == null) {
      return Center(child: CircularProgressIndicator());
    }

    return Column(
      children: [
        Text('安全评分: ${_securityInfo!.securityScore}'),
        Text('状态: ${_securityInfo!.isSecure ? "安全" : "不安全"}'),
        if (_securityInfo!.hasHighRisk)
          Text('警告: 检测到高风险！', style: TextStyle(color: Colors.red)),
      ],
    );
  }
}
```

## API 文档

### DeviceSecurity

主要的安全检测类。

#### 方法

- `checkRoot()` - 检测 Root/越狱
- `checkDebugger()` - 检测调试器
- `checkEmulator()` - 检测模拟器
- `checkProxy()` - 检测代理
- `checkVPN()` - 检测 VPN
- `getSecurityInfo()` - 获取综合安全信息

### SecurityCheckResult

单项安全检查结果。

#### 属性

- `isSecure` - 是否安全
- `checkType` - 检查类型
- `details` - 详细信息
- `riskLevel` - 风险级别 (0-10)
- `timestamp` - 检查时间
- `isHighRisk` - 是否高风险 (>= 7)
- `isMediumRisk` - 是否中风险 (4-6)
- `isLowRisk` - 是否低风险 (1-3)

### DeviceSecurityInfo

设备安全综合信息。

#### 属性

- `rootCheck` - Root/越狱检测结果
- `debuggerCheck` - 调试器检测结果
- `emulatorCheck` - 模拟器检测结果
- `proxyCheck` - 代理检测结果
- `vpnCheck` - VPN检测结果
- `securityScore` - 安全评分 (0-100)
- `isSecure` - 是否安全 (>= 70分)
- `hasHighRisk` - 是否有高风险项

### SecureStorage

安全存储类。

#### 方法

- `write({key, value, encrypt})` - 写入数据
- `read({key, decrypt})` - 读取数据
- `delete({key})` - 删除数据
- `deleteAll()` - 删除所有数据
- `containsKey({key})` - 检查键是否存在
- `readAll()` - 读取所有数据
- `writeJson({key, value, encrypt})` - 写入 JSON
- `readJson({key, decrypt})` - 读取 JSON
- `generateKeyHash(input)` - 生成密钥哈希

## 安全检测详情

### Android Root 检测

检测以下指标：
- su 命令存在性
- Superuser.apk 存在性
- Root 管理器应用
- 系统构建标签

### iOS 越狱检测

检测以下指标：
- Cydia 应用存在性
- 越狱文件存在性
- 系统目录可写性

### 模拟器检测

**Android:**
- 设备型号包含 "sdk" 或 "emulator"
- 品牌为 "generic"
- 构建标签包含 "test-keys"

**iOS:**
- 检查 isPhysicalDevice 属性

### 代理检测

检查环境变量：
- HTTP_PROXY / http_proxy
- HTTPS_PROXY / https_proxy

### VPN检测

检查网络接口名称：
- tun (Tunnel)
- ppp (Point-to-Point Protocol)
- vpn

## 安全评分系统

安全评分基于所有检查项的风险级别计算：

- **100-80分**: 安全 ✅
- **79-60分**: 警告 ⚠️
- **59-0分**: 危险 ❌

风险级别：
- **0**: 无风险
- **1-3**: 低风险
- **4-6**: 中风险
- **7-10**: 高风险

## 平台支持

| 平台 | Root/越狱 | 调试器 | 模拟器 | 代理 | VPN | 安全存储 |
|------|-----------|--------|--------|------|-----|----------|
| Android | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| iOS | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| Windows | ❌ | ✅ | ❌ | ✅ | ✅ | ✅ |
| Linux | ❌ | ✅ | ❌ | ✅ | ✅ | ✅ |
| macOS | ❌ | ✅ | ❌ | ✅ | ✅ | ✅ |

## 注意事项

1. **Root/越狱检测**: 可能存在误报，建议结合多个指标判断
2. **模拟器检测**: 某些高级模拟器可能绕过检测
3. **安全存储**: 使用平台原生安全存储（Android Keystore, iOS Keychain）
4. **权限要求**: 某些检测可能需要特定权限
5. **性能影响**: 安全检查会消耗一定资源，建议在应用启动时执行一次

## 最佳实践

### 1. 应用启动时检查

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  final security = DeviceSecurity();
  final info = await security.getSecurityInfo();
  
  if (!info.isSecure) {
    // 显示警告或限制功能
    print('警告: 设备环境不安全');
  }
  
  runApp(MyApp());
}
```

### 2. 敏感操作前检查

```dart
Future<void> performSensitiveOperation() async {
  final security = DeviceSecurity();
  final info = await security.getSecurityInfo();
  
  if (info.hasHighRisk) {
    throw SecurityException('环境不安全，无法执行操作');
  }
  
  // 执行敏感操作
}
```

### 3. 使用安全存储

```dart
// 存储敏感数据
final storage = SecureStorage();
await storage.write(
  key: 'user_token',
  value: sensitiveToken,
  encrypt: true,
);

// 读取时解密
final token = await storage.read(
  key: 'user_token',
  decrypt: true,
);
```

## 许可证

MIT License

## 贡献

欢迎提交 Issue 和 Pull Request！

## 相关链接

- [GitHub](https://github.com/h1s97x/DeviceSecurityKit)
- [问题反馈](https://github.com/h1s97x/DeviceSecurityKit/issues)
