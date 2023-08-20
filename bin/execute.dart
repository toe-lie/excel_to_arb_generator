import 'package:excel2arb/excel2arb.dart';

void main(List<String> arguments) async {
  final usage = 'Usage: dart excel_to_arb_generator:execute <url_to_excel_file> <sheet_name> <path_to_output_directory>';
  if (arguments.isEmpty) {
    print(usage);
    return;
  }

  final excelUrl = arguments.firstOrNull ?? '';
  if (excelUrl.isEmpty) {
    print('Excel file url is missing!');
    print(usage);
    return;
  }

  final sheetName = arguments.elementAtOrNull(1) ?? 'Localization';
  final filePath = arguments.elementAtOrNull(2) ?? 'temp.xlsx';
  final outputDirectory = arguments.elementAtOrNull(3) ?? '.';

  final converter = ExcelToArbGenerator(
    excelUrl,
    tempExcelPath: filePath,
    outputArbDirectory: outputDirectory,
    sheetName: sheetName,
  );
  converter.convert();
}
