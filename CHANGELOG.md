# Changelog | 更新日志

## Table of Contents | 目录

- [English](#english)
- [中文](#中文)

---

## English

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

### [1.0.1] - 2026-03-16

#### Added

- Comprehensive DartDoc documentation for all public APIs
- Enhanced example app with improved UI and additional features
- Individual security check details dialog
- Statistics card showing check history
- Advanced actions section in example app

#### Changed

- Updated `flutter_secure_storage` from ^9.0.0 to ^10.0.0
- Updated `device_info_plus` from ^10.0.0 to ^11.0.0
- Improved example app UI with Material 3 design
- Enhanced storage test with timestamp tracking
- Better error handling and user feedback in example app

#### Fixed

- CHANGELOG.md now uses primarily ASCII characters for pub.dev compliance
- Added missing DartDoc comments for core API classes

### [1.0.0] - 2026-03-08

#### Added

- Initial release of device_security_kit
- Root/Jailbreak detection for Android and iOS
- Debugger detection
- Emulator/Simulator detection
- Proxy detection
- VPN detection
- Encrypted secure storage support
- Security score calculation system
- Risk level assessment (High/Medium/Low)
- Comprehensive security information aggregation
- Cross-platform support (Android, iOS, Windows, Linux, macOS)

#### Core Features

- **DeviceSecurity**: Main security detection class with singleton pattern
- **SecurityCheckResult**: Individual security check result model
- **DeviceSecurityInfo**: Comprehensive security information model
- **SecureStorage**: Encrypted local storage using platform-native security mechanisms

#### Security Checks

- **Android Root Detection**: su command, Superuser.apk, Root managers, Build tags
- **iOS Jailbreak Detection**: Cydia, Jailbreak files, Writable system directories
- **Android Emulator Detection**: Device model, brand, build tags
- **iOS Simulator Detection**: Physical device verification
- **Proxy Detection**: Environment variable checking
- **VPN Detection**: Network interface analysis

#### Storage Features

- Encrypted data storage
- JSON object storage
- Key-value operations
- Batch operations
- Key hash generation
- Platform-native security (Android Keystore, iOS Keychain)

#### Documentation

- Complete README with usage examples
- Quick start guide
- API documentation
- Example app with polished UI
- English language support

#### Performance Testing

- Complete performance benchmark tools
- Security check performance testing
- Storage operation performance testing
- Concurrent call performance testing
- Benchmark tools integrable into example app

#### Dependencies

- flutter_secure_storage: ^10.0.0 - Secure storage
- device_info_plus: ^11.0.0 - Device information
- package_info_plus: ^8.0.0 - Package information
- crypto: ^3.0.3 - Cryptographic functions

#### Technical Features

- Singleton pattern design for global unique instance
- Asynchronous API, non-blocking main thread
- Comprehensive error handling
- Detailed risk level scoring (0-10 scale)
- Comprehensive security scoring (0-100 scale)
- Support for custom encryption strategies

#### Platform Support

- ✅ Android (API 21+)
- ✅ iOS (iOS 12.0+)
- ⚠️ Windows (Limited functionality)
- ⚠️ Linux (Limited functionality)
- ⚠️ macOS (Limited functionality)

#### Known Limitations

- Limited security check functionality on desktop platforms (Windows, Linux, macOS)
- VPN detection may not be accurate on some devices
- Proxy detection only supports environment variable method
- Root/Jailbreak detection may be bypassed by advanced tools

#### Example Code

The project includes a complete example app demonstrating all features:

- Individual security checks
- Comprehensive security information retrieval
- Secure storage operations
- JSON data storage
- Encrypted data storage
- Performance benchmark testing

#### Contributors

Thanks to all developers who contributed to this project!

---

### Future Plans

#### [1.1.0] - Planned

- Enhanced Root/Jailbreak detection algorithms
- More emulator detection features
- Network-layer proxy detection
- SSL Pinning detection
- Enhanced debugger attachment detection
- Performance optimization and caching mechanisms
- Additional platform support

#### [1.2.0] - Planned

- Device fingerprinting
- Application integrity checking
- Code obfuscation detection
- Memory tampering detection
- Anti-debugging enhancements
- Custom security policy configuration

---

## Version Scheme

- **Major version**: Incompatible API changes
- **Minor version**: Backward-compatible feature additions
- **Patch version**: Backward-compatible bug fixes

## Feedback and Support

For issues or suggestions, please visit:

- GitHub Issues: [https://github.com/h1s97x/DeviceSecurityKit/issues](https://github.com/h1s97x/DeviceSecurityKit/issues)
- GitHub Repository: [https://github.com/h1s97x/DeviceSecurityKit](https://github.com/h1s97x/DeviceSecurityKit)

## License

This project is licensed under the MIT License. See the LICENSE file for details.

---

## 中文

本项目的所有重要变更都将记录在此文件中。

日志格式基于 [Keep a Changelog](https://keepachangelog.com/zh-CN/1.0.0/)，
项目版本遵循 [语义化版本](https://semver.org/lang/zh-CN/)。

### [1.0.1] - 2026-03-16

#### 新增功能

- 为所有公共 API 添加了全面的 DartDoc 文档
- 改进了示例应用，提供更好的 UI 和额外功能
- 单项安全检查详情对话框
- 显示检查历史的统计卡片
- 示例应用中的高级操作部分

#### 变更

- 将 `flutter_secure_storage` 从 ^9.0.0 更新到 ^10.0.0
- 将 `device_info_plus` 从 ^10.0.0 更新到 ^11.0.0
- 改进了示例应用 UI，采用 Material 3 设计
- 增强了存储测试，添加时间戳跟踪
- 改进了示例应用中的错误处理和用户反馈

#### 修复

- CHANGELOG.md 现在主要使用 ASCII 字符，符合 pub.dev 要求
- 为核心 API 类添加了缺失的 DartDoc 注释

### [1.0.0] - 2026-03-08

#### 新增功能

- device_security_kit 首次发布
- Android 和 iOS 的 Root/越狱检测
- 调试器检测
- 模拟器/仿真器检测
- 代理检测
- VPN 检测
- 支持加密的安全存储
- 安全评分计算系统
- 风险级别评估（高/中/低）
- 综合安全信息聚合
- 跨平台支持（Android、iOS、Windows、Linux、macOS）

#### 核心功能

- **DeviceSecurity**: 主要的安全检测类，采用单例模式
- **SecurityCheckResult**: 单项安全检查结果模型
- **DeviceSecurityInfo**: 综合安全信息模型
- **SecureStorage**: 基于平台原生安全机制的加密本地存储

#### 安全检查项

- **Android Root 检测**: su 命令、Superuser.apk、Root 管理器、构建标签
- **iOS 越狱检测**: Cydia、越狱文件、可写系统目录
- **Android 模拟器检测**: 设备型号、品牌、构建标签
- **iOS 模拟器检测**: 物理设备检查
- **代理检测**: 环境变量检查
- **VPN 检测**: 网络接口分析

#### 存储功能

- 加密数据存储
- JSON 对象存储
- 键值对操作
- 批量操作
- 密钥哈希生成
- 平台原生安全机制（Android Keystore、iOS Keychain）

#### 文档

- 包含使用示例的完整 README
- 快速入门指南
- API 文档
- 带有精美 UI 的示例应用
- 中文语言支持

#### 性能测试

- 完整的性能基准测试工具
- 安全检查性能测试
- 存储操作性能测试
- 并发调用性能测试
- 可集成到示例应用的 benchmark 工具类

#### 依赖项

- flutter_secure_storage: ^10.0.0 - 安全存储
- device_info_plus: ^11.0.0 - 设备信息
- package_info_plus: ^8.0.0 - 包信息
- crypto: ^3.0.3 - 加密函数

#### 技术特性

- 单例模式设计，确保全局唯一实例
- 异步 API，不阻塞主线程
- 完善的错误处理机制
- 详细的风险级别评分（0-10 分制）
- 综合安全评分（0-100 分制）
- 支持自定义加密策略

#### 平台支持

- ✅ Android（API 21+）
- ✅ iOS（iOS 12.0+）
- ⚠️ Windows（部分功能）
- ⚠️ Linux（部分功能）
- ⚠️ macOS（部分功能）

#### 已知限制

- 桌面平台（Windows、Linux、macOS）的某些安全检查功能有限
- VPN 检测在某些设备上可能不够准确
- 代理检测仅支持环境变量方式
- Root/越狱检测可能被高级工具绕过

#### 示例代码

项目包含完整的示例应用，展示所有功能的使用方法：

- 单项安全检查
- 综合安全信息获取
- 安全存储操作
- JSON 数据存储
- 加密数据存储
- 性能基准测试

#### 贡献者

感谢所有为本项目做出贡献的开发者！

---

### 未来计划

#### [1.1.0] - 计划中

- 增强的 Root/越狱检测算法
- 更多的模拟器检测特征
- 网络层代理检测
- SSL Pinning 检测
- 调试器附加检测增强
- 性能优化和缓存机制
- 更多平台支持

#### [1.2.0] - 计划中

- 设备指纹识别
- 应用完整性检查
- 代码混淆检测
- 内存篡改检测
- 反调试增强
- 自定义安全策略配置

---

## 版本说明

- **主版本号**: 不兼容的 API 变更
- **次版本号**: 向下兼容的功能新增
- **修订号**: 向下兼容的问题修正

## 反馈与支持

如有问题或建议，请访问：

- GitHub Issues: [https://github.com/h1s97x/DeviceSecurityKit/issues](https://github.com/h1s97x/DeviceSecurityKit/issues)
- GitHub 仓库: [https://github.com/h1s97x/DeviceSecurityKit](https://github.com/h1s97x/DeviceSecurityKit)

## 许可证

本项目采用 MIT 许可证，详见 LICENSE 文件。
