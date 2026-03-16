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
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
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
  int _checkCount = 0;
  DateTime? _lastCheckTime;

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
        _checkCount++;
        _lastCheckTime = DateTime.now();
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _showError('Security check failed: $e');
    }
  }

  Future<void> _testSecureStorage() async {
    try {
      final testValue = 'Secure Data - ${DateTime.now().millisecondsSinceEpoch}';
      
      // Write encrypted data
      await _storage.write(
        key: 'test_key',
        value: testValue,
        encrypt: true,
      );

      // Read encrypted data
      final value = await _storage.read(
        key: 'test_key',
        decrypt: true,
      );

      setState(() => _storedValue = value);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Storage test successful: $value'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      _showError('Storage test failed: $e');
    }
  }

  Future<void> _clearStorage() async {
    try {
      await _storage.deleteAll();
      setState(() => _storedValue = null);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Storage cleared'),
            backgroundColor: Colors.blue,
          ),
        );
      }
    } catch (e) {
      _showError('Clear failed: $e');
    }
  }

  Future<void> _testIndividualChecks() async {
    setState(() => _isLoading = true);

    try {
      final results = <String, SecurityCheckResult>{};
      
      results['Root'] = await _security.checkRoot();
      results['Debugger'] = await _security.checkDebugger();
      results['Emulator'] = await _security.checkEmulator();
      results['Proxy'] = await _security.checkProxy();
      results['VPN'] = await _security.checkVPN();

      if (mounted) {
        _showDetailedResults(results);
      }
    } catch (e) {
      _showError('Individual checks failed: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showDetailedResults(Map<String, SecurityCheckResult> results) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Individual Security Checks'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: results.entries.map((entry) {
              final check = entry.value;
              final color = _getRiskColor(check.riskLevel);
              
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: color),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            entry.key,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: color,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'Risk: ${check.riskLevel}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        check.details ?? 'No details',
                        style: TextStyle(
                          color: Colors.grey[700],
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Secure: ${check.isSecure ? 'Yes' : 'No'}',
                        style: TextStyle(
                          color: check.isSecure ? Colors.green : Colors.red,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
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

  Color _getRiskColor(int riskLevel) {
    if (riskLevel >= 7) return Colors.red;
    if (riskLevel >= 4) return Colors.orange;
    if (riskLevel >= 1) return Colors.yellow;
    return Colors.green;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Device Security Kit'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _checkSecurity,
            tooltip: 'Refresh',
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
                  const SizedBox(height: 16),
                  _buildStatsCard(),
                  const SizedBox(height: 16),
                  _buildActionButtonsCard(),
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
          child: Text('No security information available'),
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
      scoreText = 'Secure';
    } else if (score >= 60) {
      scoreColor = Colors.orange;
      scoreIcon = Icons.warning;
      scoreText = 'Warning';
    } else {
      scoreColor = Colors.red;
      scoreIcon = Icons.dangerous;
      scoreText = 'Danger';
    }

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Icon(scoreIcon, size: 64, color: scoreColor),
            const SizedBox(height: 16),
            Text(
              'Security Score',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              '$score',
              style: TextStyle(
                fontSize: 56,
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
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: score / 100,
                minHeight: 8,
                backgroundColor: Colors.grey[300],
                valueColor: AlwaysStoppedAnimation<Color>(scoreColor),
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
                        'High-risk items detected!',
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
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Security Check Details',
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
    final color = _getRiskColor(check.riskLevel);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              check.isSecure ? Icons.check_circle : Icons.warning_circle,
              color: color,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getCheckTitle(check.checkType),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                if (check.details != null)
                  Text(
                    check.details!,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 13,
                    ),
                  ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: color),
            ),
            child: Text(
              'L${check.riskLevel}',
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStorageTestCard() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Secure Storage Test',
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
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Stored Value:',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                          Text(
                            _storedValue!,
                            style: const TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
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
                    label: const Text('Test Storage'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _clearStorage,
                    icon: const Icon(Icons.delete),
                    label: const Text('Clear'),
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

  Widget _buildStatsCard() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Statistics',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(
                  'Checks',
                  _checkCount.toString(),
                  Icons.check_circle,
                  Colors.blue,
                ),
                _buildStatItem(
                  'Last Check',
                  _lastCheckTime != null
                      ? '${_lastCheckTime!.hour}:${_lastCheckTime!.minute.toString().padLeft(2, '0')}'
                      : 'N/A',
                  Icons.schedule,
                  Colors.purple,
                ),
                _buildStatItem(
                  'Score',
                  _securityInfo?.securityScore.toString() ?? 'N/A',
                  Icons.trending_up,
                  Colors.green,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Icon(icon, color: color, size: 32),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtonsCard() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Advanced Actions',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _testIndividualChecks,
                icon: const Icon(Icons.analytics),
                label: const Text('Run Individual Checks'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getCheckTitle(String checkType) {
    switch (checkType) {
      case 'root':
        return 'Root Detection';
      case 'jailbreak':
        return 'Jailbreak Detection';
      case 'debugger':
        return 'Debugger Detection';
      case 'emulator':
        return 'Emulator Detection';
      case 'simulator':
        return 'Simulator Detection';
      case 'proxy':
        return 'Proxy Detection';
      case 'vpn':
        return 'VPN Detection';
      default:
        return checkType;
    }
  }
}
