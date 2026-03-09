# 如何在 Example 应用中集成 Benchmark

## 方法一：添加 Benchmark 按钮到 Example 应用

在 `example/lib/main.dart` 中添加以下代码：

```dart
import 'package:flutter/material.dart';
import '../../benchmark/benchmark_utils.dart'; // 导入 benchmark 工具

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  List<BenchmarkResult>? _benchmarkResults;
  bool _isRunning = false;

  Future<void> _runBenchmark() async {
    setState(() {
      _isRunning = true;
      _benchmarkResults = null;
    });

    try {
      final benchmark = SecurityBenchmark();
      final results = await benchmark.runAll();
      
      setState(() {
        _benchmarkResults = results;
        _isRunning = false;
      });
    } catch (e) {
      print('Benchmark error: $e');
      setState(() {
        _isRunning = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Device Security Kit Example'),
        ),
        body: Column(
          children: [
            // 其他功能按钮...
            
            // Benchmark 按钮
            ElevatedButton(
              onPressed: _isRunning ? null : _runBenchmark,
              child: _isRunning
                  ? CircularProgressIndicator()
                  : Text('Run Performance Benchmark'),
            ),
            
            // 显示结果
            if (_benchmarkResults != null)
              Expanded(
                child: ListView.builder(
                  itemCount: _benchmarkResults!.length,
                  itemBuilder: (context, index) {
                    final result = _benchmarkResults![index];
                    return ListTile(
                      title: Text(result.name),
                      subtitle: Text(
                        '${result.averageMs.toStringAsFixed(2)} ms/op',
                      ),
                      trailing: Text(
                        '${result.iterations} iterations',
                        style: TextStyle(fontSize: 12),
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
```

## 方法二：创建独立的 Benchmark 页面

创建 `example/lib/benchmark_page.dart`:

```dart
import 'package:flutter/material.dart';
import '../../benchmark/benchmark_utils.dart';

class BenchmarkPage extends StatefulWidget {
  @override
  _BenchmarkPageState createState() => _BenchmarkPageState();
}

class _BenchmarkPageState extends State<BenchmarkPage> {
  List<BenchmarkResult>? _results;
  bool _isRunning = false;
  String _status = 'Ready to run benchmark';

  Future<void> _runBenchmark() async {
    setState(() {
      _isRunning = true;
      _status = 'Running benchmark...';
      _results = null;
    });

    try {
      final benchmark = SecurityBenchmark();
      final results = await benchmark.runAll();
      
      setState(() {
        _results = results;
        _status = 'Benchmark completed';
        _isRunning = false;
      });
    } catch (e) {
      setState(() {
        _status = 'Error: $e';
        _isRunning = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Performance Benchmark'),
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                Text(
                  _status,
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _isRunning ? null : _runBenchmark,
                  child: _isRunning
                      ? Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                            SizedBox(width: 8),
                            Text('Running...'),
                          ],
                        )
                      : Text('Run Benchmark'),
                ),
              ],
            ),
          ),
          if (_results != null)
            Expanded(
              child: ListView.builder(
                itemCount: _results!.length,
                itemBuilder: (context, index) {
                  final result = _results![index];
                  return Card(
                    margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    child: ListTile(
                      title: Text(result.name),
                      subtitle: Text(
                        '${result.iterations} iterations in ${result.totalMs}ms',
                      ),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '${result.averageMs.toStringAsFixed(2)} ms',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'per operation',
                            style: TextStyle(fontSize: 10),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
```

然后在主应用中添加导航：

```dart
Navigator.push(
  context,
  MaterialPageRoute(builder: (context) => BenchmarkPage()),
);
```

## 方法三：使用 Flutter Test

创建 `example/test/benchmark_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import '../../benchmark/benchmark_utils.dart';

void main() {
  testWidgets('Run security benchmark', (WidgetTester tester) async {
    final benchmark = SecurityBenchmark();
    final results = await benchmark.runAll();
    
    expect(results.isNotEmpty, true);
    
    for (final result in results) {
      print(result);
      // 可以添加性能断言
      // expect(result.averageMs, lessThan(100));
    }
  });
}
```

运行测试：

```bash
cd example
flutter test test/benchmark_test.dart
```

## 方法四：命令行工具

创建 `benchmark/run_benchmark.dart`:

```dart
import 'package:flutter/widgets.dart';
import 'benchmark_utils.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  final benchmark = SecurityBenchmark();
  await benchmark.runAll();
}
```

然后在 example 目录运行：

```bash
flutter run -t ../../benchmark/run_benchmark.dart --release
```

## 注意事项

1. 建议在 Release 模式下运行以获得准确的性能数据
2. 首次运行可能较慢，建议运行多次取平均值
3. 不同设备的性能差异很大，建议在目标设备上测试
4. 某些检查可能需要特定权限或在特定平台上才能运行
