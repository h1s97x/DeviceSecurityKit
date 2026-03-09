import 'security_check_result.dart';

/// 安全报告
class SecurityReport {
  SecurityReport({
    required this.checks,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  factory SecurityReport.fromJson(Map<String, dynamic> json) {
    return SecurityReport(
      checks: (json['checks'] as List)
          .map((c) => SecurityCheckResult.fromJson(c))
          .toList(),
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }

  /// 所有检查结果
  final List<SecurityCheckResult> checks;

  /// 生成时间
  final DateTime timestamp;

  /// 是否整体安全
  bool get isSecure => checks.every((check) => check.isSecure);

  /// 总风险级别
  int get totalRiskLevel {
    if (checks.isEmpty) return 0;
    return checks.map((c) => c.riskLevel).reduce((a, b) => a + b);
  }

  /// 平均风险级别
  double get averageRiskLevel {
    if (checks.isEmpty) return 0;
    return totalRiskLevel / checks.length;
  }

  /// 高风险检查
  List<SecurityCheckResult> get highRiskChecks {
    return checks.where((c) => c.isHighRisk).toList();
  }

  /// 中风险检查
  List<SecurityCheckResult> get mediumRiskChecks {
    return checks.where((c) => c.isMediumRisk).toList();
  }

  /// 低风险检查
  List<SecurityCheckResult> get lowRiskChecks {
    return checks.where((c) => c.isLowRisk).toList();
  }

  /// 失败的检查
  List<SecurityCheckResult> get failedChecks {
    return checks.where((c) => !c.isSecure).toList();
  }

  Map<String, dynamic> toJson() {
    return {
      'checks': checks.map((c) => c.toJson()).toList(),
      'timestamp': timestamp.toIso8601String(),
      'isSecure': isSecure,
      'totalRiskLevel': totalRiskLevel,
      'averageRiskLevel': averageRiskLevel,
    };
  }

  @override
  String toString() {
    return 'SecurityReport(checks: ${checks.length}, secure: $isSecure, risk: ${averageRiskLevel.toStringAsFixed(1)})';
  }
}
