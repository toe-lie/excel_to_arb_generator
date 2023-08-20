import 'package:excel2arb/excel2arb.dart';

void main(List<String> arguments) async {
  final usage = 'Usage: excel2arb <url_to_excel_file> <sheet_name_to_parse> <path_to_output_directory>';
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
  final outputDirectory = arguments.elementAtOrNull(2) ?? '.';

  final converter = ExcelToArbGenerator(
    excelUrl,
    tempExcelPath: 'temp.xlsx',
    outputArbDirectory: outputDirectory,
    sheetName: sheetName,
  );
  converter.convert();
}
