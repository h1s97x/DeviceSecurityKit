import 'security_check_result.dart';

/// Comprehensive device security information model.
///
/// This class aggregates all security check results and provides an overall
/// security score and assessment. It includes results from root/jailbreak,
/// debugger, emulator, proxy, and VPN checks.
///
/// The security score ranges from 0 to 100, where 100 is the most secure.
/// A score of 70 or higher is considered secure.
///
/// Example:
/// ```dart
/// final security = DeviceSecurity();
/// final info = await security.getSecurityInfo();
/// print('Security Score: ${info.securityScore}');
/// print('Is Secure: ${info.isSecure}');
/// print('Has High Risk: ${info.hasHighRisk}');
/// ```
class DeviceSecurityInfo {
  /// Creates a new DeviceSecurityInfo instance.
  ///
  /// All check results are optional. If not provided, they will be null.
  /// The security score is automatically calculated based on the provided checks.
  /// The timestamp defaults to the current time if not provided.
  DeviceSecurityInfo({
    this.rootCheck,
    this.debuggerCheck,
    this.emulatorCheck,
    this.proxyCheck,
    this.vpnCheck,
    DateTime? timestamp,
  })  : securityScore = _calculateScore(
          rootCheck,
          debuggerCheck,
          emulatorCheck,
          proxyCheck,
          vpnCheck,
        ),
        timestamp = timestamp ?? DateTime.now();

  /// Creates a DeviceSecurityInfo instance from a JSON map.
  ///
  /// This factory constructor is useful for deserializing security information
  /// that was previously serialized to JSON.
  ///
  /// Example:
  /// ```dart
  /// final json = {
  ///   'rootCheck': {...},
  ///   'debuggerCheck': {...},
  ///   'timestamp': '2026-03-16T10:30:00.000Z'
  /// };
  /// final info = DeviceSecurityInfo.fromJson(json);
  /// ```
  factory DeviceSecurityInfo.fromJson(Map<String, dynamic> json) {
    return DeviceSecurityInfo(
      rootCheck: json['rootCheck'] != null
          ? SecurityCheckResult.fromJson(json['rootCheck'])
          : null,
      debuggerCheck: json['debuggerCheck'] != null
          ? SecurityCheckResult.fromJson(json['debuggerCheck'])
          : null,
      emulatorCheck: json['emulatorCheck'] != null
          ? SecurityCheckResult.fromJson(json['emulatorCheck'])
          : null,
      proxyCheck: json['proxyCheck'] != null
          ? SecurityCheckResult.fromJson(json['proxyCheck'])
          : null,
      vpnCheck: json['vpnCheck'] != null
          ? SecurityCheckResult.fromJson(json['vpnCheck'])
          : null,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }

  /// Root/越狱检测结果
  final SecurityCheckResult? rootCheck;

  /// 调试器检测结果
  final SecurityCheckResult? debuggerCheck;

  /// 模拟器检测结果
  final SecurityCheckResult? emulatorCheck;

  /// 代理检测结果
  final SecurityCheckResult? proxyCheck;

  /// VPN检测结果
  final SecurityCheckResult? vpnCheck;

  /// 整体安全评分 (0-100, 100最安全)
  final int securityScore;

  /// 检查时间
  final DateTime timestamp;

  /// 是否安全
  bool get isSecure => securityScore >= 70;

  /// 是否有高风险
  bool get hasHighRisk {
    return [rootCheck, debuggerCheck, emulatorCheck, proxyCheck, vpnCheck]
        .any((check) => check?.isHighRisk ?? false);
  }

  static int _calculateScore(
    SecurityCheckResult? root,
    SecurityCheckResult? debugger,
    SecurityCheckResult? emulator,
    SecurityCheckResult? proxy,
    SecurityCheckResult? vpn,
  ) {
    int totalRisk = 0;
    int checkCount = 0;

    void addRisk(SecurityCheckResult? check) {
      if (check != null) {
        totalRisk += check.riskLevel;
        checkCount++;
      }
    }

    addRisk(root);
    addRisk(debugger);
    addRisk(emulator);
    addRisk(proxy);
    addRisk(vpn);

    if (checkCount == 0) return 100;

    // 平均风险转换为安全分数
    final avgRisk = totalRisk / checkCount;
    return (100 - (avgRisk * 10)).clamp(0, 100).toInt();
  }

  /// Converts this DeviceSecurityInfo instance to a JSON map.
  ///
  /// This method serializes all security check results and metadata to a JSON
  /// representation that can be stored or transmitted.
  ///
  /// Returns a map containing all security information with ISO 8601 formatted
  /// timestamp.
  ///
  /// Example:
  /// ```dart
  /// final info = await security.getSecurityInfo();
  /// final json = info.toJson();
  /// final jsonString = jsonEncode(json);
  /// ```
  Map<String, dynamic> toJson() {
    return {
      'rootCheck': rootCheck?.toJson(),
      'debuggerCheck': debuggerCheck?.toJson(),
      'emulatorCheck': emulatorCheck?.toJson(),
      'proxyCheck': proxyCheck?.toJson(),
      'vpnCheck': vpnCheck?.toJson(),
      'securityScore': securityScore,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  @override
  String toString() {
    return 'DeviceSecurityInfo(score: $securityScore, secure: $isSecure)';
  }
}
