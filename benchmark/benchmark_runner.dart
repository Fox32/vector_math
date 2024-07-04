import 'dart:async';
import 'dart:convert';
import 'dart:io';

Future<void> main(List<String> arguments) async {
  final fileName = arguments[0];

  try {
    await runBenchmarkVM(fileName);
  } catch (err) {
    print(err);
  }

  await runBenchmarkAoT(fileName);
  await runBenchmarkDart2JS(fileName);
}

Future<void> runBenchmarkVM(String fileName) async {
  final process = await Process.start('dart', [fileName]);
  unawaited(process.stdout.transform(const Utf8Decoder()).forEach(print));
  unawaited(process.stderr.transform(const Utf8Decoder()).forEach(print));
  await process.exitCode;
}

Future<void> runBenchmarkAoT(String fileName) async {
  final result = await Process.run('dart', ['compile', 'exe', fileName]);
  final executablePath = RegExp(r'^Generated: (.*)$')
      .firstMatch(result.stdout.toString().trim())
      ?.group(1);

  if (executablePath == null) {
    throw StateError(
        'Failed to compile AoT: ${result.stdout} ${result.stderr}');
  }

  final process = await Process.start(executablePath, []);
  unawaited(process.stdout.transform(const Utf8Decoder()).forEach(print));
  unawaited(process.stderr.transform(const Utf8Decoder()).forEach(print));
  await process.exitCode;
}

Future<void> runBenchmarkDart2JS(String fileName) async {
  final outputPath = '$fileName.js';
  final result = await Process.run(
      'dart', ['compile', 'js', '--output', outputPath, fileName]);

  if (result.exitCode != 0) {
    throw StateError(
        'Failed to compile Dart2JS: ${result.stdout} ${result.stderr}');
  }

  final process = await Process.start('node', [outputPath]);
  unawaited(process.stdout.transform(const Utf8Decoder()).forEach(print));
  unawaited(process.stderr.transform(const Utf8Decoder()).forEach(print));
  await process.exitCode;
}
