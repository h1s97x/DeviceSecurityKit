/// 安全检查结果
class SecurityCheckResult {
  SecurityCheckResult({
    required this.isSecure,
    required this.checkType,
    required this.riskLevel,
    this.details,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

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
