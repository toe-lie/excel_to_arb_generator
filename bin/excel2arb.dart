import 'dart:convert';
import 'dart:io';

import 'package:excel2arb/excel2arb.dart';
import 'package:args/args.dart';

const argExcelUrl = 'excel-url';
const argLocalizationSheetName = 'sheet-name';
const argOutputDirectory = 'output-directory';
const argGenerateL10n = 'gen-l10n';

void main(List<String> arguments) async {
  exitCode = 0; // presume success
  final usage =
      'Usage: excel2arb -u <excel-file-url> -s <sheet_name_to_parse> -o <path_to_arb_output_directory> -g <generate_l10n>\n'
      '-u, --excel-ur\tExcel file url (https://example.com/sample.xlsx)\n'
      '-s, --sheet-name\tSheet name to parse (default: Localization)\n'
      '-o, --output-directory\tPath to arb files output directory (default: current directory)\n'
      '-g, --gen-l10n\tGenerate l10n files (default: false)\n';

  if (arguments.isEmpty) {
    print(usage);
    exitCode = 1;
    return;
  }

  try {
    final argParser = ArgParser()
      ..addOption(
        argExcelUrl,
        abbr: 'u',
        help: 'Excel file url',
      )
      ..addOption(
        argLocalizationSheetName,
        abbr: 's',
        help: 'Sheet name to parse (default: Localization)',
        defaultsTo: 'Localization',
      )
      ..addOption(
        argOutputDirectory,
        abbr: 'o',
        help: 'Path to arb files output directory (default: current directory)',
        defaultsTo: '.',
      )
      ..addFlag(
        argGenerateL10n,
        abbr: 'g',
        help: 'Generate l10n files',
        defaultsTo: false,
        negatable: false,
      );

    final argResults = argParser.parse(arguments);
    final excelUrl = argResults[argExcelUrl] ?? '';
    if (excelUrl.isEmpty) {
      print('Excel file url is missing!');
      print(usage);
      return;
    }

    final sheetName = argResults[argLocalizationSheetName] ?? 'Localization';
    final outputDirectory = argResults[argOutputDirectory] ?? '.';

    final converter = ExcelToArbGenerator(
      excelUrl,
      tempExcelPath: 'temp.xlsx',
      outputArbDirectory: outputDirectory,
      sheetName: sheetName,
    );
    await converter.convert();

    final genL10n = argResults[argGenerateL10n];
    if (genL10n) {
      executeCommand('flutter gen-l10n');
    }

    exitCode = 0;
  } catch (e) {
    print('Error: $e');
    exitCode = 2;
  }
}

void executeCommand(String command) async {
  print('Executing command: $command');

  final process = await Process.start(
    command.split(' ')[0],
    command.split(' ').sublist(1),
    runInShell: true,
  );

  process.stdout.transform(utf8.decoder).listen((data) {
    print(data);
  });

  process.stderr.transform(utf8.decoder).listen((data) {
    print(data);
  });

  final exitCode = await process.exitCode;
  if (exitCode == 0) {
    print('Command executed successfully!');
  } else {
    print('Command failed with exit code: $exitCode');
  }
}
