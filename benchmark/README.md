# Device Security Kit Benchmark

性能基准测试工具，用于评估 device_security_kit 的各项功能性能。

## 运行方式

由于 device_security_kit 是 Flutter 插件，benchmark 需要在 Flutter 环境中运行。

### 在真实设备上运行（推荐）

1. 连接 Android 或 iOS 设备
2. 进入 example 目录并运行：

```bash
cd example
flutter devices  # 查看可用设备

# Android 设备
flutter run -d <android-device-id> --release

# iOS 设备  
flutter run -d <ios-device-id> --release
```

3. 在应用中手动触发安全检查，观察性能

### 集成测试方式

将 benchmark 代码集成到 example 应用的测试中：

```bash
cd example
flutter test integration_test/
```

## 测试项目

### 1. 安全检查性能测试

- **完整安全信息获取**: 测试 `getSecurityInfo()` 的性能，包含所有安全检查
- **单项检查性能**: 分别测试各个安全检查的性能
  - Root/越狱检测
  - 调试器检测
  - 模拟器检测
  - 代理检测
  - VPN检测

### 2. 重复调用测试

测试频繁调用同一检查方法的性能，用于评估缓存效果和优化空间。

### 3. 并发调用测试

测试多个安全检查并发执行的性能，评估在高并发场景下的表现。

### 4. 安全存储性能测试

- **基础操作**: 测试 write/read/delete 的性能
- **JSON操作**: 测试 JSON 序列化/反序列化的性能
- **加密操作**: 测试加密写入和解密读取的性能

## 性能指标

所有测试结果以毫秒(ms)为单位，显示每次操作的平均耗时。

### 预期性能基准

在真实设备上的预期性能（仅供参考）：

- 单项安全检查: < 50ms
- 完整安全信息: < 200ms
- 存储写入: < 20ms
- 存储读取: < 15ms
- JSON操作: < 30ms
- 加密操作: < 25ms

## 注意事项

1. 某些检查在非移动平台（如桌面）上可能会失败，这是正常现象
2. 首次运行可能较慢，因为需要初始化各种服务
3. 实际性能会受设备性能、系统负载等因素影响
4. 建议在真实设备上运行以获得准确的性能数据
5. Release 模式下的性能比 Debug 模式更准确

## 性能优化建议

如果发现性能问题，可以考虑：

1. 实现结果缓存机制
2. 减少不必要的文件系统访问
3. 优化并发检查的执行策略
4. 使用更高效的加密算法
5. 批量处理存储操作

## 手动性能测试

如果无法运行自动化 benchmark，可以在 example 应用中手动测试：

1. 打开 example 应用
2. 点击各个安全检查按钮
3. 观察控制台输出的执行时间
4. 多次执行以获得平均值

## 使用 Flutter DevTools 分析

更详细的性能分析可以使用 Flutter DevTools：

```bash
cd example
flutter run --profile
# 然后在浏览器中打开 DevTools 进行性能分析
```
