// ignore_for_file: avoid_print

/// Benchmark tests for device_security_kit.
///
/// Note: This file cannot be run directly with `dart run` because
/// device_security_kit is a Flutter plugin that requires Flutter framework.
///
/// To run benchmarks:
/// 1. Import benchmark_utils.dart into your example app
/// 2. Use SecurityBenchmark class to run tests
/// 3. Or integrate into Flutter tests
///
/// See benchmark/README.md for detailed instructions.
library;

import 'benchmark_utils.dart';

void main() async {
  print('ERROR: This benchmark requires Flutter framework to run.');
  print('');
  print('Please use one of the following methods:');
  print('1. Import benchmark_utils.dart into the example app');
  print('2. Run: cd example && flutter run --release');
  print('3. See benchmark/README.md for more options');
  print('');

  // This will fail in pure Dart environment, but shows the intended usage
  try {
    final benchmark = SecurityBenchmark();
    await benchmark.runAll();
  } catch (e) {
    print('Expected error: $e');
    print('');
    print('This confirms that Flutter framework is required.');
  }
}
