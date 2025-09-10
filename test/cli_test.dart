import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

import 'support/local_server.dart';

/// Normalizes help output for reliable comparison:
/// - Converts Windows line endings to Unix
/// - Converts Windows line endings to Unix
/// - Replaces common mojibake and Unicode punctuation with ASCII equivalents
/// - Trims trailing whitespace from each line
String normalizeHelp(String s) {
  // Normalize line endings
  s = s.replaceAll('\r\n', '\n');

  // Fix common mojibake from UTF-8 -> CP1252 misinterpretation on Windows
  s = s
      .replaceAll('â€”', '-') // em dash mojibake
      .replaceAll('â€“', '-') // en dash mojibake
      .replaceAll('â†’', '->') // right arrow mojibake
      .replaceAll('â€¢', '*'); // bullet mojibake

  // Replace fancy Unicode punctuation with ASCII for cross-platform stability
  const map = {
    '—': '-', '–': '-',
    '→': '->',
    '•': '*', '·': '*',
    '‘': "'", '’': "'",
    '“': '"', '”': '"',
    '\u00A0': ' ', // non-breaking space
  };
  map.forEach((k, v) => s = s.replaceAll(k, v));

  // Trim trailing whitespace at end to avoid EOF newline mismatches
  return s.trimRight();
}

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

  test('creates output directory if it does not exist', () async {
    final nonExistentDir =
        Directory(p.join(projectRoot, 'tmp_output_nonexistent'));
    if (nonExistentDir.existsSync()) {
      nonExistentDir.deleteSync(recursive: true);
    }

    final excelUrl = serverUri.resolve('test/fixtures/basic.xlsx').toString();
    final result = await runCli(
        ['-u', excelUrl, '-s', 'Localization', '-o', nonExistentDir.path]);

    expect(result.exitCode, 0,
        reason:
            'CLI should succeed when output directory does not exist: ${result.stderr}');
    expect(nonExistentDir.existsSync(), isTrue,
        reason: 'Output directory should be created');

    final outputFiles = await readDirFiles(nonExistentDir);
    expect(outputFiles.keys, isNotEmpty,
        reason: 'ARB files should be generated in created directory');

    // Cleanup
    if (nonExistentDir.existsSync()) {
      nonExistentDir.deleteSync(recursive: true);
    }
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
    final normalizedStdout = normalizeHelp(result.stdout.toString());
    final normalizedGolden = normalizeHelp(helpGolden);
    expect(normalizedStdout, normalizedGolden);
  });
}
