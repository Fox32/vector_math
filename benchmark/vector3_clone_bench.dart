import 'package:benchmark_harness/benchmark_harness.dart';
import 'package:vector_math/vector_math_x.dart';

const isAotCompiled = bool.fromEnvironment('dart.vm.product');
const isJsCompiled = identical(1.0, 1);
const benchmarkSuffix = isJsCompiled
    ? '(Dart2JS)'
    : isAotCompiled
        ? '(AoT)'
        : '(VM)';

class Vector3CloneBenchmark extends BenchmarkBase {
  const Vector3CloneBenchmark() : super('Vector3Clone$benchmarkSuffix');

  @override
  void run() {
    for (double i = -500; i <= 500; i += 0.75) {
      for (double j = -500; j <= 500; j += 0.75) {
        final _ = Vector3(j, i, 0).clone();
      }
    }
  }
}

class Vector3AddBenchmark extends BenchmarkBase {
  const Vector3AddBenchmark() : super('Vector3Add$benchmarkSuffix');

  @override
  void run() {
    final vec = Vector3.zero();
    for (double i = -500; i <= 500; i += 0.75) {
      for (double j = -500; j <= 500; j += 0.75) {
        vec.add(Vector3(i, j, i + j));
      }
    }
  }
}

void main() {
  const Vector3CloneBenchmark().report();
  const Vector3AddBenchmark().report();
}
