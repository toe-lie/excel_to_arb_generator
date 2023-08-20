import 'dart:io';

import 'package:excel/excel.dart';

import 'arb_creator.dart';
import 'excel_downloader.dart';
import 'excel_parser.dart';

class ExcelToArbGenerator {
  ExcelToArbGenerator(
    this.excelFileUrl, {
    this.tempExcelPath = 'temp.xlsx',
    this.outputArbDirectory = '.',
    this.sheetName = 'Localization',
  });

  final String tempExcelPath;
  final String outputArbDirectory;
  final String excelFileUrl;
  final String sheetName;

  Future<void> convert() async {
    try {
      final file = File(tempExcelPath);
      final fileName = file.path.split(Platform.pathSeparator).last;
      print('Downloading excel file from $excelFileUrl...');
      final downloader = ExcelDownloader(url: excelFileUrl);
      await downloader.downloadAndCreateExcelFile(file);
      print('Excel file is downloaded!');

      final bytes = await file.readAsBytes();
      var excel = Excel.decodeBytes(bytes);
      final localizationSheet = excel.tables[sheetName];
      print('Looking for $sheetName sheet...');
      if (localizationSheet == null) {
        print('$sheetName sheet is missing!');
        return;
      }
      print('Found $sheetName sheet!');

      print('Parsing $sheetName sheet...');
      final parser = ExcelParser(sheet: localizationSheet);
      final translations = parser.parse();
      final languageCodes = parser.parseLanguageCodes();
      print('Parsed $sheetName sheet!');
      print('${languageCodes.length} translations, $languageCodes, found!');

      print('Creating ARB files in $outputArbDirectory ...');
      final creator = ArbCreator();
      creator.writeToFile(outputArbDirectory, languageCodes, translations);
      print('ARB files are created in $outputArbDirectory!');

      print('Deleting $fileName...');
      await downloader.deleteExcelFile(file);
      print('Deleted $fileName!');

      print('Localizations are ready!');
    } catch (e) {
      print('Error: $e');
    }
  }
}
