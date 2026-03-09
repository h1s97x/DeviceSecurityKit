// ignore_for_file: avoid_print

/// Benchmark utilities for device_security_kit.
///
/// This file can be imported into the example app or tests.
library;

import 'dart:async';
import 'package:device_security_kit/device_security_kit.dart';

/// Benchmark result for a single test
class BenchmarkResult {
  BenchmarkResult({
    required this.name,
    required this.averageMs,
    required this.iterations,
    required this.totalMs,
  });

  final String name;
  final double averageMs;
  final int iterations;
  final int totalMs;

  @override
  String toString() {
    return '$name: ${averageMs.toStringAsFixed(2)} ms/op ($iterations iterations, ${totalMs}ms total)';
  }
}

/// Benchmark runner for device security checks
class SecurityBenchmark {
  final DeviceSecurity security = DeviceSecurity();
  final SecureStorage storage = SecureStorage();
  final List<BenchmarkResult> results = [];

  /// Run all benchmarks
  Future<List<BenchmarkResult>> runAll() async {
    results.clear();

    print('=== device_security_kit Performance Benchmark ===\n');

    await benchmarkSecurityInfo();
    await benchmarkIndividualChecks();
    await benchmarkRepeatedChecks();
    await benchmarkConcurrentChecks();
    await benchmarkSecureStorage();
    await benchmarkStorageOperations();

    print('\n=== Benchmark Complete ===');
    print('Total tests: ${results.length}');

    return results;
  }

  /// Benchmark: Complete security info retrieval
  Future<void> benchmarkSecurityInfo() async {
    print('--- Security Info Retrieval Benchmark ---');

    const iterations = 50;
    final stopwatch = Stopwatch()..start();

    for (int i = 0; i < iterations; i++) {
      try {
        await security.getSecurityInfo();
      } catch (e) {
        // Ignore errors
      }
    }

    stopwatch.stop();
    final avgTime = stopwatch.elapsedMilliseconds / iterations;

    final result = BenchmarkResult(
      name: 'Get security info',
      averageMs: avgTime,
      iterations: iterations,
      totalMs: stopwatch.elapsedMilliseconds,
    );

    results.add(result);
    print('  $result');
    print('');
  }

  /// Benchmark: Individual security checks
  Future<void> benchmarkIndividualChecks() async {
    print('--- Individual Security Checks Benchmark ---');

    const iterations = 100;

    // Root Check
    await _benchmarkCheck('Root check', iterations, () => security.checkRoot());

    // Debugger Check
    await _benchmarkCheck(
        'Debugger check', iterations, () => security.checkDebugger());

    // Emulator Check
    await _benchmarkCheck(
        'Emulator check', iterations, () => security.checkEmulator());

    // Proxy Check
    await _benchmarkCheck(
        'Proxy check', iterations, () => security.checkProxy());

    // VPN Check
    await _benchmarkCheck('VPN check', iterations, () => security.checkVPN());

    print('');
  }

  /// Benchmark: Repeated calls
  Future<void> benchmarkRepeatedChecks() async {
    print('--- Repeated Checks Benchmark ---');

    const iterations = 500;
    final stopwatch = Stopwatch()..start();

    for (int i = 0; i < iterations; i++) {
      try {
        await security.checkDebugger();
      } catch (e) {
        // Ignore errors
      }
    }

    stopwatch.stop();
    final avgTime = stopwatch.elapsedMilliseconds / iterations;

    final result = BenchmarkResult(
      name: 'Repeated debugger checks',
      averageMs: avgTime,
      iterations: iterations,
      totalMs: stopwatch.elapsedMilliseconds,
    );

    results.add(result);
    print('  $result');
    print('');
  }

  /// Benchmark: Concurrent calls
  Future<void> benchmarkConcurrentChecks() async {
    print('--- Concurrent Checks Benchmark ---');

    const concurrentCalls = 10;
    final stopwatch = Stopwatch()..start();

    try {
      await Future.wait([
        for (int i = 0; i < concurrentCalls; i++) security.getSecurityInfo(),
      ]);
    } catch (e) {
      // Ignore errors
    }

    stopwatch.stop();
    final avgTime = stopwatch.elapsedMilliseconds / concurrentCalls;

    final result = BenchmarkResult(
      name: 'Concurrent security checks',
      averageMs: avgTime,
      iterations: concurrentCalls,
      totalMs: stopwatch.elapsedMilliseconds,
    );

    results.add(result);
    print('  $result');
    print('  Total time: ${stopwatch.elapsedMilliseconds} ms');
    print('');
  }

  /// Benchmark: Secure storage basic operations
  Future<void> benchmarkSecureStorage() async {
    print('--- Secure Storage Benchmark ---');

    const iterations = 100;
    const testKey = 'benchmark_test_key';
    const testValue = 'benchmark_test_value_with_some_data';

    // Write
    await _benchmarkStorageOp(
      'Storage write',
      iterations,
      (i) => storage.write(key: '$testKey$i', value: testValue),
    );

    // Read
    await _benchmarkStorageOp(
      'Storage read',
      iterations,
      (i) => storage.read(key: '$testKey$i'),
    );

    // Delete
    await _benchmarkStorageOp(
      'Storage delete',
      iterations,
      (i) => storage.delete(key: '$testKey$i'),
    );

    print('');
  }

  /// Benchmark: Storage operations (JSON, encryption)
  Future<void> benchmarkStorageOperations() async {
    print('--- Storage Operations Benchmark ---');

    const iterations = 50;

    final testJson = {
      'id': 12345,
      'name': 'Test User',
      'email': 'test@example.com',
      'data': List.generate(10, (i) => 'item_$i'),
    };

    // JSON write
    await _benchmarkStorageOp(
      'JSON write',
      iterations,
      (i) => storage.writeJson(key: 'json_test_$i', value: testJson),
    );

    // JSON read
    await _benchmarkStorageOp(
      'JSON read',
      iterations,
      (i) => storage.readJson(key: 'json_test_$i'),
    );

    // Encrypted write
    const encryptedValue = 'sensitive_data_that_needs_encryption';
    await _benchmarkStorageOp(
      'Encrypted write',
      iterations,
      (i) => storage.write(
        key: 'encrypted_test_$i',
        value: encryptedValue,
        encrypt: true,
      ),
    );

    // Encrypted read
    await _benchmarkStorageOp(
      'Encrypted read',
      iterations,
      (i) => storage.read(key: 'encrypted_test_$i', decrypt: true),
    );

    // Cleanup
    try {
      for (int i = 0; i < iterations; i++) {
        await storage.delete(key: 'json_test_$i');
        await storage.delete(key: 'encrypted_test_$i');
      }
    } catch (e) {
      // Ignore errors
    }

    print('');
  }

  /// Helper: Benchmark a security check
  Future<void> _benchmarkCheck(
    String name,
    int iterations,
    Future<SecurityCheckResult> Function() check,
  ) async {
    final stopwatch = Stopwatch()..start();

    for (int i = 0; i < iterations; i++) {
      try {
        await check();
      } catch (e) {
        // Ignore errors
      }
    }

    stopwatch.stop();
    final avgTime = stopwatch.elapsedMilliseconds / iterations;

    final result = BenchmarkResult(
      name: name,
      averageMs: avgTime,
      iterations: iterations,
      totalMs: stopwatch.elapsedMilliseconds,
    );

    results.add(result);
    print('  $result');
  }

  /// Helper: Benchmark a storage operation
  Future<void> _benchmarkStorageOp(
    String name,
    int iterations,
    Future<void> Function(int) operation,
  ) async {
    final stopwatch = Stopwatch()..start();

    for (int i = 0; i < iterations; i++) {
      try {
        await operation(i);
      } catch (e) {
        // Ignore errors
      }
    }

    stopwatch.stop();
    final avgTime = stopwatch.elapsedMilliseconds / iterations;

    final result = BenchmarkResult(
      name: name,
      averageMs: avgTime,
      iterations: iterations,
      totalMs: stopwatch.elapsedMilliseconds,
    );

    results.add(result);
    print('  $result');
  }
}
