# Pub.dev 自动发布设置指南

本文档说明如何配置 GitHub Actions 自动发布到 pub.dev。

## 前置条件

1. 拥有 pub.dev 账户
2. 拥有 GitHub 仓库的管理员权限
3. 已安装 Dart SDK

## 步骤 1：获取 Pub.dev 凭证

### 方法 A：使用 OAuth 2.0（推荐）

1. 访问 [pub.dev 账户设置](https://pub.dev/account)
2. 点击 "Create new token"
3. 选择 "Pub API"
4. 复制生成的 **Access Token** 和 **Refresh Token**

### 方法 B：使用 Credentials 文件

1. 运行以下命令生成凭证：
   ```bash
   pub token add https://pub.dartlang.org
   ```
2. 按照提示输入凭证
3. 凭证将保存在 `~/.pub-cache/credentials.json`

## 步骤 2：配置 GitHub Secrets

1. 进入 GitHub 仓库
2. 点击 **Settings** → **Secrets and variables** → **Actions**
3. 点击 **New repository secret**
4. 添加以下 secrets：

### 使用 OAuth 2.0 方式

| Secret 名称 | 值 | 说明 |
|------------|-----|------|
| `PUBLISH_ACCESS_TOKEN` | 从 pub.dev 复制 | OAuth 2.0 Access Token |
| `PUBLISH_REFRESH_TOKEN` | 从 pub.dev 复制 | OAuth 2.0 Refresh Token |

### 使用 Credentials 文件方式

| Secret 名称 | 值 | 说明 |
|------------|-----|------|
| `PUB_CREDENTIALS` | credentials.json 内容 | 完整的 credentials.json 文件内容 |

## 步骤 3：验证工作流

1. 进入 **Actions** 标签页
2. 查看 "Publish to pub.dev" 工作流
3. 确保工作流已启用

## 步骤 4：发布新版本

### 自动发布流程

1. 更新 `pubspec.yaml` 中的版本号
2. 更新 `CHANGELOG.md`
3. 提交更改：
   ```bash
   git add pubspec.yaml CHANGELOG.md
   git commit -m "chore: 版本更新到 x.y.z"
   ```
4. 创建标签：
   ```bash
   git tag -a vx.y.z -m "Release version x.y.z"
   ```
5. 推送到 GitHub：
   ```bash
   git push origin main --tags
   ```

### 工作流触发

当推送带有 `v*` 前缀的标签时，GitHub Actions 会自动：
1. 检出代码
2. 运行测试
3. 检查代码质量
4. 发布到 pub.dev

## 步骤 5：监控发布

1. 进入 **Actions** 标签页
2. 查看 "Publish to pub.dev" 工作流的执行状态
3. 点击工作流查看详细日志
4. 发布成功后，访问 [pub.dev](https://pub.dev/packages/device_security_kit) 验证

## 故障排除

### 问题 1：发布失败 - 凭证错误

**症状**：工作流日志显示 "Invalid credentials"

**解决方案**：
1. 验证 GitHub Secrets 中的凭证是否正确
2. 确保凭证未过期
3. 重新生成凭证并更新 Secrets

### 问题 2：发布失败 - 版本冲突

**症状**：工作流日志显示 "Version already exists"

**解决方案**：
1. 确保 `pubspec.yaml` 中的版本号是新的
2. 检查 pub.dev 上是否已存在该版本
3. 更新版本号并重新推送标签

### 问题 3：发布失败 - 测试失败

**症状**：工作流在测试步骤失败

**解决方案**：
1. 在本地运行 `flutter test` 验证测试
2. 修复失败的测试
3. 提交修复并重新推送标签

### 问题 4：发布失败 - 代码分析失败

**症状**：工作流在 `flutter analyze` 步骤失败

**解决方案**：
1. 在本地运行 `flutter analyze` 检查问题
2. 修复所有警告和错误
3. 提交修复并重新推送标签

## 手动发布（备选方案）

如果自动发布失败，可以手动发布：

```bash
# 1. 确保所有测试通过
flutter test

# 2. 检查代码质量
flutter analyze

# 3. 手动发布
pub publish
```

## 安全建议

1. **定期轮换凭证**
   - 每 3-6 个月更新一次 pub.dev 凭证
   - 更新 GitHub Secrets

2. **限制 Secret 访问**
   - 仅在必要的工作流中使用 Secrets
   - 定期审计 Secrets 的使用

3. **监控发布**
   - 每次发布后验证 pub.dev 上的包
   - 检查发布日志中的任何异常

## 参考资源

- [Pub.dev 文档](https://dart.dev/tools/pub)
- [GitHub Actions 文档](https://docs.github.com/en/actions)
- [dart-package-publisher Action](https://github.com/k-paxian/dart-package-publisher)

## 常用命令

```bash
# 查看本地凭证
cat ~/.pub-cache/credentials.json

# 删除本地凭证
rm ~/.pub-cache/credentials.json

# 测试发布（不实际发布）
pub publish --dry-run

# 查看发布历史
pub history device_security_kit
```

## 支持

如有问题，请：
1. 查看 GitHub Actions 工作流日志
2. 检查 pub.dev 包页面
3. 提交 GitHub Issue
