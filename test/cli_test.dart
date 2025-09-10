import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

import 'support/local_server.dart';

void main() {
  late LocalPythonHttpServer server;
  late Uri serverUri;
  final projectRoot = Directory.current.path;
  final outputDir = Directory(p.join(projectRoot, 'tmp_output_test'));
  final goldensDir = Directory(p.join(projectRoot, 'test', 'goldens'));

  void requireFile(String path, String hint) {
    final file = File(path);
    if (!file.existsSync()) {
      throw StateError('Required file not found: $path\nHint: $hint');
    }
  }

  setUpAll(() async {
    goldensDir.createSync(recursive: true);
    server = LocalPythonHttpServer(rootDir: projectRoot);
    await server.start();
    serverUri = server.uri;
  });

  tearDownAll(() async {
    await server.stop();
  });

  setUp(() async {
    if (outputDir.existsSync()) {
      outputDir.deleteSync(recursive: true);
    }
    outputDir.createSync(recursive: true);
  });

  Future<ProcessResult> runCli(List<String> args) {
    return Process.run(
      'dart',
      ['run', 'bin/excel2arb.dart', ...args],
      workingDirectory: projectRoot,
    );
  }

  Future<Map<String, String>> readDirFiles(Directory dir) async {
    final result = <String, String>{};
    await for (final file in dir.list(recursive: false)) {
      if (file is File && file.path.endsWith('.arb')) {
        result[p.basename(file.path)] = await file.readAsString();
      }
    }
    return result;
  }

  test('generates ARB files and matches goldens', () async {
    final excelUrl = serverUri.resolve('test/fixtures/basic.xlsx').toString();
    final result = await runCli(
        ['-u', excelUrl, '-s', 'Localization', '-o', outputDir.path]);
    expect(result.exitCode, 0,
        reason: 'CLI exited with non-zero exit code: ${result.stderr}');
    requireFile(p.join(goldensDir.path, 'app_en.arb'),
        'Generate via CLI and move to test/goldens/app_en.arb');
    requireFile(p.join(goldensDir.path, 'app_my.arb'),
        'Generate via CLI and move to test/goldens/app_my.arb');
    final outputFiles = await readDirFiles(outputDir);
    final goldenFiles = await readDirFiles(goldensDir);
    expect(outputFiles.keys, unorderedEquals(goldenFiles.keys));
    for (final key in goldenFiles.keys) {
      expect(outputFiles[key], goldenFiles[key], reason: 'Mismatch in $key');
    }
  });

  test('idempotency: running twice produces same output', () async {
    final excelUrl = serverUri.resolve('test/fixtures/basic.xlsx').toString();
    // First run
    var result = await runCli(
        ['-u', excelUrl, '-s', 'Localization', '-o', outputDir.path]);
    expect(result.exitCode, 0);
    final firstRun = await readDirFiles(outputDir);
    // Second run
    result = await runCli(
        ['-u', excelUrl, '-s', 'Localization', '-o', outputDir.path]);
    expect(result.exitCode, 0);
    final secondRun = await readDirFiles(outputDir);
    expect(secondRun, firstRun);
  });

  test('--help output matches golden snapshot', () async {
    final result = await runCli(['--help']);
    expect([0, 2].contains(result.exitCode), isTrue,
        reason:
            'Unexpected exit code for --help: ${result.exitCode}\nSTDOUT:\n${result.stdout}\nSTDERR:\n${result.stderr}');
    requireFile(p.join(goldensDir.path, 'help.txt'),
        'Run: dart run bin/excel2arb.dart --help > test/goldens/help.txt');
    final helpGolden =
        File(p.join(goldensDir.path, 'help.txt')).readAsStringSync();
    final normalizedStdout = result.stdout.replaceAll('\r\n', '\n');
    final normalizedGolden = helpGolden.replaceAll('\r\n', '\n');
    expect(normalizedStdout, normalizedGolden);
  });
}
