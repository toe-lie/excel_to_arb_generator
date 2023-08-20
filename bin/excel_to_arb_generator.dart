import 'package:excel_to_arb_generator/excel_to_arb_generator.dart';

void main(List<String> arguments) async {
  if (arguments.length != 4) {
    print(
        'Usage: dart bin/excel_to_arb_generator.dart <url_to_excel_file> <sheet_name> <path_to_save_temp_excel_file> <path_to_output_directory>');
    return;
  }

  final excelUrl = arguments[0];
  final sheetName = arguments[1];
  final filePath = arguments[2];
  final outputDirectory = arguments[3];

  final converter = ExcelToArbGenerator(
    excelUrl,
    tempExcelPath: filePath,
    outputArbDirectory: outputDirectory,
    sheetName: sheetName,
  );
  converter.convert();
}
