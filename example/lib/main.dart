import 'package:flutter/material.dart';
import 'package:device_security_kit/device_security_kit.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Device Security Kit Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.red),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _security = DeviceSecurity();
  final _storage = SecureStorage();

  DeviceSecurityInfo? _securityInfo;
  bool _isLoading = false;
  String? _storedValue;

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
      _showError('安全检查失败: $e');
    }
  }

  Future<void> _testSecureStorage() async {
    try {
      // 写入测试数据
      await _storage.write(
        key: 'test_key',
        value: 'Hello, Secure World!',
        encrypt: true,
      );

      // 读取测试数据
      final value = await _storage.read(
        key: 'test_key',
        decrypt: true,
      );

      setState(() => _storedValue = value);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('存储测试成功: $value')),
        );
      }
    } catch (e) {
      _showError('存储测试失败: $e');
    }
  }

  Future<void> _clearStorage() async {
    try {
      await _storage.deleteAll();
      setState(() => _storedValue = null);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('存储已清空')),
        );
      }
    } catch (e) {
      _showError('清空失败: $e');
    }
  }

  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Device Security Kit Demo'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _checkSecurity,
            tooltip: '重新检查',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _checkSecurity,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _buildSecurityScoreCard(),
                  const SizedBox(height: 16),
                  _buildSecurityChecksCard(),
                  const SizedBox(height: 16),
                  _buildStorageTestCard(),
                ],
              ),
            ),
    );
  }

  Widget _buildSecurityScoreCard() {
    if (_securityInfo == null) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text('暂无安全信息'),
        ),
      );
    }

    final score = _securityInfo!.securityScore;
    final hasHighRisk = _securityInfo!.hasHighRisk;

    Color scoreColor;
    IconData scoreIcon;
    String scoreText;

    if (score >= 80) {
      scoreColor = Colors.green;
      scoreIcon = Icons.shield;
      scoreText = '安全';
    } else if (score >= 60) {
      scoreColor = Colors.orange;
      scoreIcon = Icons.warning;
      scoreText = '警告';
    } else {
      scoreColor = Colors.red;
      scoreIcon = Icons.dangerous;
      scoreText = '危险';
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(scoreIcon, size: 64, color: scoreColor),
            const SizedBox(height: 16),
            Text(
              '安全评分',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              '$score',
              style: TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: scoreColor,
              ),
            ),
            Text(
              scoreText,
              style: TextStyle(
                fontSize: 20,
                color: scoreColor,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 16),
            if (hasHighRisk)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.error, color: Colors.red),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '检测到高风险项！',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSecurityChecksCard() {
    if (_securityInfo == null) return const SizedBox();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '安全检查详情',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            if (_securityInfo!.rootCheck != null)
              _buildCheckItem(_securityInfo!.rootCheck!),
            if (_securityInfo!.debuggerCheck != null)
              _buildCheckItem(_securityInfo!.debuggerCheck!),
            if (_securityInfo!.emulatorCheck != null)
              _buildCheckItem(_securityInfo!.emulatorCheck!),
            if (_securityInfo!.proxyCheck != null)
              _buildCheckItem(_securityInfo!.proxyCheck!),
            if (_securityInfo!.vpnCheck != null)
              _buildCheckItem(_securityInfo!.vpnCheck!),
          ],
        ),
      ),
    );
  }

  Widget _buildCheckItem(SecurityCheckResult check) {
    Color color;
    IconData icon;

    if (check.isHighRisk) {
      color = Colors.red;
      icon = Icons.dangerous;
    } else if (check.isMediumRisk) {
      color = Colors.orange;
      icon = Icons.warning;
    } else if (check.isLowRisk) {
      color = Colors.yellow;
      icon = Icons.info;
    } else {
      color = Colors.green;
      icon = Icons.check_circle;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getCheckTitle(check.checkType),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                if (check.details != null)
                  Text(
                    check.details!,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: color),
            ),
            child: Text(
              '风险: ${check.riskLevel}',
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStorageTestCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '安全存储测试',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            if (_storedValue != null)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle, color: Colors.green),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '存储的值: $_storedValue',
                        style: const TextStyle(color: Colors.green),
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _testSecureStorage,
                    icon: const Icon(Icons.save),
                    label: const Text('测试存储'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _clearStorage,
                    icon: const Icon(Icons.delete),
                    label: const Text('清空存储'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _getCheckTitle(String checkType) {
    switch (checkType) {
      case 'root':
        return 'Root 检测';
      case 'jailbreak':
        return '越狱检测';
      case 'debugger':
        return '调试器检测';
      case 'emulator':
        return '模拟器检测';
      case 'simulator':
        return '模拟器检测';
      case 'proxy':
        return '代理检测';
      case 'vpn':
        return 'VPN 检测';
      default:
        return checkType;
    }
  }
}
