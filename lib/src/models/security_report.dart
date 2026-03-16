import 'security_check_result.dart';

/// Comprehensive security report aggregating multiple security checks.
///
/// This class collects and analyzes results from multiple security checks,
/// providing aggregate statistics and risk assessment. It's useful for
/// generating detailed security reports and analyzing overall device security.
///
/// The report includes:
/// - Individual check results
/// - Overall security status
/// - Risk level statistics
/// - Categorized check results (high/medium/low risk)
/// - Failed checks
///
/// Example:
/// ```dart
/// final report = SecurityReport(
///   checks: [rootCheck, debuggerCheck, emulatorCheck],
/// );
/// print('Overall Secure: ${report.isSecure}');
/// print('Average Risk: ${report.averageRiskLevel}');
/// print('High Risk Checks: ${report.highRiskChecks.length}');
/// ```
class SecurityReport {
  /// Creates a new SecurityReport instance.
  ///
  /// Parameters:
  /// - [checks]: List of security check results to include in the report
  /// - [timestamp]: Optional timestamp of when the report was generated
  SecurityReport({
    required this.checks,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  /// Creates a SecurityReport instance from a JSON map.
  ///
  /// This factory constructor deserializes a JSON representation of a
  /// security report.
  ///
  /// Example:
  /// ```dart
  /// final json = {
  ///   'checks': [...],
  ///   'timestamp': '2026-03-16T10:30:00.000Z'
  /// };
  /// final report = SecurityReport.fromJson(json);
  /// ```
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

  /// Converts this SecurityReport instance to a JSON map.
  ///
  /// This method serializes the security report to a JSON representation
  /// that can be stored or transmitted. The JSON includes all check results
  /// and aggregate statistics.
  ///
  /// Returns a map containing all report information with ISO 8601 formatted
  /// timestamp.
  ///
  /// Example:
  /// ```dart
  /// final report = SecurityReport(checks: [...]);
  /// final json = report.toJson();
  /// final jsonString = jsonEncode(json);
  /// ```
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
