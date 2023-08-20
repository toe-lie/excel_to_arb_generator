# Excel to ARB Generator

A Dart package that allows you to download an Excel file from a given URL and generate ARB (Application Resource Bundle) files.

## Installation

To use this package, add `excel_to_arb_generator` as a dependency in your `pubspec.yaml` file:

```yaml
dependencies:
  excel_to_arb_generator: ^1.0.0
```

## Usage
You can use this package to download an Excel file from a URL and generate ARB files. Here's an example of how to use it in a Dart script:
```dart
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
```

## Excel Sheet Format
The supported Excel sheet format should have the following columns in the first row:

- `Feature` (Optional)
- `Screen` (Optional)
- `Name [name]`
- `Description [description]`
- `Remark` (Optional)
- Add localization columns using the local code in curly brackets,<br/>e.g., `English {en}`, `Myanmar {my}`, `Thai {th}`
- `Placeholders [placeholders]` in `Json format` (Optional)

Make sure to provide the necessary information in these columns for localization.

You can download and check the sample Excel sheet [here](https://shorturl.at/aP146).

## Features
- Download Excel files from URLs
- Generate ARB files for localization

## Contributing
Contributions are welcome! Feel free to open issues or pull requests on the [GitHub repository](https://github.com/toe-lie/excel_to_arb_generator).
