import 'security_check_result.dart';

/// 设备安全综合信息
class DeviceSecurityInfo {
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
