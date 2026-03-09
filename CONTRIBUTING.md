# 贡献指南

感谢您对 device_security_kit 项目的关注！本指南将帮助您为项目做出贡献。

[English Version](CONTRIBUTING_EN.md)

## 目录

- [架构概览](#架构概览)
- [开发环境设置](#开发环境设置)
- [添加新功能](#添加新功能)
- [代码风格指南](#代码风格指南)
- [测试](#测试)
- [性能基准测试](#性能基准测试)
- [Pull Request 流程](#pull-request-流程)
- [获取帮助](#获取帮助)

## 架构概览

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
├── android/                             # Android 平台代码（Kotlin）
│   └── src/main/kotlin/
│       └── com/example/device_security_kit/
│           └── DeviceSecurityKitPlugin.kt
│
├── ios/                                 # iOS 平台代码（Swift/Objective-C）
│   └── Classes/
│       └── DeviceSecurityKitPlugin.swift
│
├── benchmark/                           # 性能基准测试
│   ├── benchmark_utils.dart             # 测试工具类
│   ├── device_security_benchmark.dart   # 主测试文件
│   ├── README.md                        # 测试文档
│   └── INTEGRATION_EXAMPLE.md           # 集成示例
│
└── example/                             # 示例应用
    └── lib/main.dart
```

## 开发环境设置

### 前置要求

- Flutter SDK (>=3.3.0)
- Dart SDK (>=3.0.0)
- Android Studio / Xcode（用于平台开发）
- Git

### 克隆仓库

```bash
git clone https://github.com/h1s97x/DeviceSecurityKit.git
cd device_security_kit
```

### 安装依赖

```bash
flutter pub get
cd example
flutter pub get
```

### 运行示例应用

```bash
cd example
flutter run
```

## 添加新功能

### 添加新的安全检查

#### 步骤 1：定义检查方法

在 `lib/src/device_security.dart` 中添加新的检查方法：

```dart
/// 检测新的安全威胁
Future<SecurityCheckResult> checkNewThreat() async {
  try {
    // 实现检测逻辑
    final isSecure = await _performCheck();
    
    return SecurityCheckResult(
      isSecure: isSecure,
      checkType: 'new_threat',
      details: isSecure ? 'No threat detected' : 'Threat detected',
      riskLevel: isSecure ? 0 : 7,
    );
  } catch (e) {
    debugPrint('New threat check failed: $e');
    return SecurityCheckResult(
      isSecure: true,
      checkType: 'new_threat',
      details: 'Check failed: $e',
      riskLevel: 0,
    );
  }
}
```

#### 步骤 2：更新综合信息

在 `getSecurityInfo()` 方法中添加新检查：

```dart
Future<DeviceSecurityInfo> getSecurityInfo() async {
  try {
    final results = await Future.wait([
      checkRoot(),
      checkDebugger(),
      checkEmulator(),
      checkProxy(),
      checkVPN(),
      checkNewThreat(), // 添加新检查
    ]);

    return DeviceSecurityInfo(
      rootCheck: results[0],
      debuggerCheck: results[1],
      emulatorCheck: results[2],
      proxyCheck: results[3],
      vpnCheck: results[4],
      newThreatCheck: results[5], // 添加到模型
    );
  } catch (e) {
    debugPrint('Failed to get security info: $e');
    return DeviceSecurityInfo();
  }
}
```

#### 步骤 3：更新数据模型

在 `lib/src/models/device_security_info.dart` 中添加新字段：

```dart
class DeviceSecurityInfo {
  final SecurityCheckResult? newThreatCheck;
  
  DeviceSecurityInfo({
    // ... 其他字段
    this.newThreatCheck,
  });
  
  // 更新 toJson 和 fromJson 方法
}
```

#### 步骤 4：添加平台特定实现（如需要）

**Android (Kotlin):**

在 `android/src/main/kotlin/.../DeviceSecurityKitPlugin.kt` 中添加：

```kotlin
private fun checkNewThreat(): Boolean {
    // Android 特定实现
    return false
}
```

**iOS (Swift):**

在 `ios/Classes/DeviceSecurityKitPlugin.swift` 中添加：

```swift
private func checkNewThreat() -> Bool {
    // iOS 特定实现
    return false
}
```

#### 步骤 5：添加测试

创建测试文件或更新现有测试：

```dart
test('checkNewThreat returns valid result', () async {
  final security = DeviceSecurity();
  final result = await security.checkNewThreat();
  
  expect(result, isA<SecurityCheckResult>());
  expect(result.checkType, 'new_threat');
  expect(result.riskLevel, inInclusiveRange(0, 10));
});
```

#### 步骤 6：添加性能测试

在 `benchmark/benchmark_utils.dart` 中添加：

```dart
// New Threat Check
await _benchmarkCheck('New threat check', iterations, () => security.checkNewThreat());
```

#### 步骤 7：更新文档

- 更新 `README.md` 中的功能列表
- 更新 `CHANGELOG.md` 记录新功能
- 添加使用示例到 example 应用

### 添加新的存储功能

在 `lib/src/secure_storage.dart` 中添加新方法，遵循现有的 API 设计模式。

## 代码风格指南

### Dart 代码

- 遵循 [Effective Dart](https://dart.dev/guides/language/effective-dart) 指南
- 使用 `dart format` 格式化代码
- 运行 `flutter analyze` 检查问题
- 为公共 API 添加文档注释（使用 `///`）
- 使用有意义的变量名和方法名
- 保持方法简短，单一职责
- 适当使用 `try-catch` 处理错误
- 使用 `debugPrint` 而不是 `print`

示例：

```dart
/// 检测设备是否被 Root/越狱
///
/// 返回 [SecurityCheckResult] 包含检测结果和风险级别。
/// 
/// 示例：
/// ```dart
/// final result = await DeviceSecurity().checkRoot();
/// if (!result.isSecure) {
///   print('设备已被 Root，风险级别：${result.riskLevel}');
/// }
/// ```
Future<SecurityCheckResult> checkRoot() async {
  // 实现代码
}
```

### Kotlin 代码（Android）

- 遵循 [Kotlin 编码规范](https://kotlinlang.org/docs/coding-conventions.html)
- 使用空安全特性
- 为公共方法添加 KDoc 注释
- 适当处理异常

### Swift 代码（iOS）

- 遵循 [Swift API 设计指南](https://swift.org/documentation/api-design-guidelines/)
- 使用可选类型处理空值
- 添加文档注释
- 使用 guard 语句提前返回

### 代码格式化

运行以下命令格式化代码：

```bash
# Dart 代码
dart format .

# 检查代码质量
flutter analyze

# 运行测试
flutter test
```

## 测试

### 单元测试

```bash
flutter test
```

### 集成测试

```bash
cd example
flutter test integration_test/
```

### 在真实设备上测试

```bash
cd example

# Android
flutter run -d <android-device-id>

# iOS
flutter run -d <ios-device-id>
```

### 测试覆盖率

```bash
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
```

## 性能基准测试

### 运行 Benchmark

```bash
cd example
flutter run --release
# 在应用中触发 benchmark
```

### 添加新的 Benchmark

在 `benchmark/benchmark_utils.dart` 中添加新的测试方法：

```dart
Future<void> benchmarkNewFeature() async {
  print('--- New Feature Benchmark ---');
  
  const iterations = 100;
  final stopwatch = Stopwatch()..start();
  
  for (int i = 0; i < iterations; i++) {
    try {
      await yourNewFeature();
    } catch (e) {
      // 忽略错误
    }
  }
  
  stopwatch.stop();
  final avgTime = stopwatch.elapsedMilliseconds / iterations;
  
  final result = BenchmarkResult(
    name: 'New feature',
    averageMs: avgTime,
    iterations: iterations,
    totalMs: stopwatch.elapsedMilliseconds,
  );
  
  results.add(result);
  print('  $result');
  print('');
}
```

## Pull Request 流程

### 1. Fork 仓库

点击 GitHub 页面右上角的 "Fork" 按钮。

### 2. 创建功能分支

```bash
git checkout -b feature/your-feature-name
```

或修复 bug：

```bash
git checkout -b fix/bug-description
```

### 3. 进行修改

- 编写代码
- 添加测试
- 更新文档

### 4. 提交前检查

```bash
# 格式化代码
dart format .

# 代码分析
flutter analyze

# 运行测试
flutter test

# 运行 benchmark（如果修改了性能相关代码）
cd example && flutter run --release
```

### 5. 提交更改

使用 [Conventional Commits](https://www.conventionalcommits.org/zh-hans/) 格式：

```bash
git add .
git commit -m "feat: 添加新的安全检查功能"
```

提交类型：

- `feat`: 新功能
- `fix`: Bug 修复
- `docs`: 文档变更
- `style`: 代码格式变更（不影响代码含义）
- `refactor`: 代码重构
- `perf`: 性能优化
- `test`: 添加或更新测试
- `chore`: 构建过程或辅助工具的变动
- `ci`: CI 配置文件和脚本的变动

示例：

```bash
feat(android): 添加高级 Root 检测算法
fix(ios): 修复 iOS 16+ 上的越狱检测问题
docs: 更新 API 文档和使用示例
perf: 优化安全检查的并发执行
test: 添加存储加密的单元测试
```

### 6. 推送到您的 Fork

```bash
git push origin feature/your-feature-name
```

### 7. 创建 Pull Request

1. 访问您的 fork 仓库
2. 点击 "New Pull Request"
3. 填写 PR 描述：
   - 简要说明更改内容
   - 列出相关的 issue（如有）
   - 说明测试情况
   - 添加截图（如适用）

### PR 描述模板

```markdown
## 更改说明

简要描述此 PR 的目的和内容。

## 更改类型

- [ ] 新功能
- [ ] Bug 修复
- [ ] 文档更新
- [ ] 性能优化
- [ ] 代码重构
- [ ] 测试

## 相关 Issue

Closes #123

## 测试

- [ ] 单元测试已通过
- [ ] 集成测试已通过
- [ ] 在真实设备上测试（Android/iOS）
- [ ] 性能测试已完成

## 截图（如适用）

添加截图或 GIF 展示更改效果。

## 检查清单

- [ ] 代码已格式化（`dart format .`）
- [ ] 代码分析无警告（`flutter analyze`）
- [ ] 所有测试通过（`flutter test`）
- [ ] 文档已更新
- [ ] CHANGELOG.md 已更新
```

## 获取帮助

### 资源

- 📖 [项目文档](https://github.com/h1s97x/DeviceSecurityKit)
- 🐛 [报告 Bug](https://github.com/h1s97x/DeviceSecurityKit/issues)
- 💡 [功能建议](https://github.com/h1s97x/DeviceSecurityKit/issues)
- 💬 [讨论区](https://github.com/h1s97x/DeviceSecurityKit/discussions)

### 常见问题

**Q: 如何在本地测试 Android 平台代码？**

A: 连接 Android 设备或启动模拟器，然后运行 `cd example && flutter run`。

**Q: 如何调试平台特定代码？**

A: 使用 Android Studio 或 Xcode 打开对应的平台项目，设置断点进行调试。

**Q: 性能测试应该在什么模式下运行？**

A: 始终在 Release 模式下运行性能测试：`flutter run --release`。

## 行为准则

### 我们的承诺

为了营造开放和友好的环境，我们承诺：

- 尊重不同的观点和经验
- 优雅地接受建设性批评
- 关注对社区最有利的事情
- 对其他社区成员表现出同理心

### 不可接受的行为

- 使用性暗示的语言或图像
- 人身攻击或侮辱性评论
- 公开或私下骚扰
- 未经许可发布他人的私人信息
- 其他不道德或不专业的行为

## 许可证

通过贡献，您同意您的贡献将在 MIT 许可证下授权。

## 致谢

所有贡献者将在以下位置获得认可：

- 项目 README 的贡献者部分
- CHANGELOG.md 的发布说明
- GitHub Contributors 页面

### 特别感谢

感谢所有为 device_security_kit 做出贡献的开发者！您的贡献让这个项目变得更好。

---

## 快速参考

### 常用命令

```bash
# 获取依赖
flutter pub get

# 格式化代码
dart format .

# 代码分析
flutter analyze

# 运行测试
flutter test

# 运行示例
cd example && flutter run

# 运行 benchmark
cd example && flutter run --release

# 生成测试覆盖率
flutter test --coverage
```

### 项目结构速查

- `lib/src/device_security.dart` - 安全检测核心
- `lib/src/secure_storage.dart` - 安全存储核心
- `lib/src/models/` - 数据模型
- `android/` - Android 平台代码
- `ios/` - iOS 平台代码
- `benchmark/` - 性能测试
- `example/` - 示例应用

---

再次感谢您的贡献！🎉
