import 'package:flutter_test/flutter_test.dart';
import 'package:device_security_kit/device_security_kit.dart';

void main() {
  test('DeviceSecurity instance', () {
    final security = DeviceSecurity();
    expect(security, isNotNull);
  });

  test('SecureStorage instance', () {
    final storage = SecureStorage();
    expect(storage, isNotNull);
  });

  test('SecurityCheckResult creation', () {
    final result = SecurityCheckResult(
      isSecure: true,
      checkType: 'test',
      details: 'Test check',
      riskLevel: 0,
    );

    expect(result.isSecure, true);
    expect(result.checkType, 'test');
    expect(result.riskLevel, 0);
    expect(result.isHighRisk, false);
    expect(result.isMediumRisk, false);
    expect(result.isLowRisk, false);
  });

  test('SecurityCheckResult risk levels', () {
    final highRisk = SecurityCheckResult(
      isSecure: false,
      checkType: 'test',
      riskLevel: 8,
    );
    expect(highRisk.isHighRisk, true);

    final mediumRisk = SecurityCheckResult(
      isSecure: false,
      checkType: 'test',
      riskLevel: 5,
    );
    expect(mediumRisk.isMediumRisk, true);

    final lowRisk = SecurityCheckResult(
      isSecure: false,
      checkType: 'test',
      riskLevel: 2,
    );
    expect(lowRisk.isLowRisk, true);
  });

  test('SecurityCheckResult serialization', () {
    final result = SecurityCheckResult(
      isSecure: true,
      checkType: 'test',
      details: 'Test details',
      riskLevel: 3,
    );

    final json = result.toJson();
    expect(json['isSecure'], true);
    expect(json['checkType'], 'test');
    expect(json['riskLevel'], 3);

    final restored = SecurityCheckResult.fromJson(json);
    expect(restored.isSecure, true);
    expect(restored.checkType, 'test');
    expect(restored.riskLevel, 3);
  });

  test('DeviceSecurityInfo score calculation', () {
    final info = DeviceSecurityInfo(
      rootCheck: SecurityCheckResult(
        isSecure: true,
        checkType: 'root',
        riskLevel: 0,
      ),
      debuggerCheck: SecurityCheckResult(
        isSecure: true,
        checkType: 'debugger',
        riskLevel: 0,
      ),
    );

    expect(info.securityScore, 100);
    expect(info.isSecure, true);
    expect(info.hasHighRisk, false);
  });

  test('SecureStorage key hash generation', () {
    final storage = SecureStorage();
    final hash1 = storage.generateKeyHash('test');
    final hash2 = storage.generateKeyHash('test');
    final hash3 = storage.generateKeyHash('different');

    expect(hash1, hash2);
    expect(hash1, isNot(hash3));
  });
}
