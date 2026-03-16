/// Result of a single security check.
///
/// This class represents the outcome of a specific security check performed
/// on the device. It includes information about whether the check passed,
/// the type of check, risk level, and additional details.
///
/// Risk levels range from 0 (most secure) to 10 (most dangerous).
/// - 0: No risk
/// - 1-3: Low risk
/// - 4-6: Medium risk
/// - 7-10: High risk
///
/// Example:
/// ```dart
/// final result = SecurityCheckResult(
///   isSecure: true,
///   checkType: 'root',
///   riskLevel: 0,
///   details: 'No root detected',
/// );
/// print('High Risk: ${result.isHighRisk}');
/// ```
class SecurityCheckResult {
  /// Creates a new SecurityCheckResult instance.
  ///
  /// Parameters:
  /// - [isSecure]: Whether the check passed (device is secure for this check)
  /// - [checkType]: The type of security check (e.g., 'root', 'debugger')
  /// - [riskLevel]: The risk level (0-10)
  /// - [details]: Optional additional details about the check result
  /// - [timestamp]: Optional timestamp of when the check was performed
  SecurityCheckResult({
    required this.isSecure,
    required this.checkType,
    required this.riskLevel,
    this.details,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  /// Creates a SecurityCheckResult instance from a JSON map.
  ///
  /// This factory constructor deserializes a JSON representation of a
  /// security check result.
  ///
  /// Example:
  /// ```dart
  /// final json = {
  ///   'isSecure': true,
  ///   'checkType': 'root',
  ///   'riskLevel': 0,
  ///   'details': 'No root detected',
  ///   'timestamp': '2026-03-16T10:30:00.000Z'
  /// };
  /// final result = SecurityCheckResult.fromJson(json);
  /// ```
  factory SecurityCheckResult.fromJson(Map<String, dynamic> json) {
    return SecurityCheckResult(
      isSecure: json['isSecure'] as bool,
      checkType: json['checkType'] as String,
      riskLevel: json['riskLevel'] as int,
      details: json['details'] as String?,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }

  /// 是否安全
  final bool isSecure;

  /// 检查类型
  final String checkType;

  /// 详细信息
  final String? details;

  /// 风险级别 (0-10, 0最安全)
  final int riskLevel;

  /// 检查时间
  final DateTime timestamp;

  /// 是否高风险 (>= 7)
  bool get isHighRisk => riskLevel >= 7;

  /// 是否中风险 (4-6)
  bool get isMediumRisk => riskLevel >= 4 && riskLevel < 7;

  /// 是否低风险 (1-3)
  bool get isLowRisk => riskLevel > 0 && riskLevel < 4;

  /// Converts this SecurityCheckResult instance to a JSON map.
  ///
  /// This method serializes the security check result to a JSON representation
  /// that can be stored or transmitted.
  ///
  /// Returns a map containing all check information with ISO 8601 formatted
  /// timestamp.
  ///
  /// Example:
  /// ```dart
  /// final result = await security.checkRoot();
  /// final json = result.toJson();
  /// final jsonString = jsonEncode(json);
  /// ```
  Map<String, dynamic> toJson() {
    return {
      'isSecure': isSecure,
      'checkType': checkType,
      'details': details,
      'riskLevel': riskLevel,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  @override
  String toString() {
    return 'SecurityCheckResult(type: $checkType, secure: $isSecure, risk: $riskLevel)';
  }
}
