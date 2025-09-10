import 'package:excel/excel.dart';

import 'models/translation.dart';

class ExcelParser {
  static const String keyName = "name";

  static const String keyDescription = "description";

  static const String keyPlaceholders = "placeholders";

  const ExcelParser({required this.sheet});

  final Sheet sheet;

  List<String> parseLanguageCodes() {
    final headerRow = parseHeader(sheet);

    final indicesByLanguage = chunkLanguageIndices(headerRow);

    return indicesByLanguage.keys.toList();
  }

  List<Translation> parse() {
    final headerRow = parseHeader(sheet);

    final indicesByName = chunkNameIndices(headerRow);

    final indicesByLanguage = chunkLanguageIndices(headerRow);

    final translations = <Translation>[];

    for (final (index, row) in sheet.rows.indexed) {
      if (index == 0) continue;

      if (isEmptyRow(row)) {
        continue;
      }

      final name = extractValue('name', indicesByName, row);

      final description =
          extractOptionalValue('description', indicesByName, row);

      final placeholders =
          extractOptionalValue('placeholders', indicesByName, row);

      final valuesByLanugaes = extractValuesByLanguage(indicesByLanguage, row);

      final translation = Translation(
        valuesByLanguageCode: valuesByLanugaes,
        key: name,
        description: description,
        placeholders: placeholders,
      );

      translations.add(translation);
    }

    return translations;
  }

  bool isEmptyRow(List<Data?> row) => row.every((cell) {
        final value = cellLikeToString(cell);
        return value == null || value.isEmpty;
      });

  String extractValue(
      String key, Map<String, int> indicesByName, List<Data?> row) {
    final keyIndex = indicesByName[key];

    if (keyIndex == null) {
      throw Exception('$key Column not found!');
    }

    final value = getCellValue(row, keyIndex) ?? '';

    return value;
  }

  String extractOptionalValue(
      String key, Map<String, int> indicesByName, List<Data?> row) {
    final keyIndex = indicesByName[key];
    if (keyIndex == null) {
      return '';
    }
    return getCellValue(row, keyIndex) ?? '';
  }

  Map<String, String> extractValuesByLanguage(
      Map<String, int> indicesByLanguage, List<Data?> row) {
    final valuesByLanguage = <String, String>{};

    final enIndex = indicesByLanguage['en'];

    if (enIndex == null) {
      throw Exception('en column is missing');
    }

    final defaultValue = getCellValue(row, enIndex) ?? '';

    indicesByLanguage.forEach((languageCode, index) {
      final value = getCellValue(row, index) ?? '';

      if (value.isNotEmpty) {
        valuesByLanguage.putIfAbsent(languageCode, () => value);
      } else {
        valuesByLanguage.putIfAbsent(languageCode, () => defaultValue);
      }
    });

    return valuesByLanguage;
  }

  List<String?> parseRow(Sheet sheet, int rowIndex) {
    final row = sheet.rows[rowIndex];
    return row.map((cell) => cellLikeToString(cell)).toList();
  }

  List<String?> parseHeader(Sheet sheet, [int headerRowIndex = 0]) {
    return parseRow(sheet, headerRowIndex);
  }

  Map<String, int> chunkNameIndices(List<String?> cells) {
    final result = <String, int>{};

    final regex = RegExp(r'\[(.*?)\]');

    for (final (index, cell) in cells.indexed) {
      if (cell == null) continue;

      final match = regex.firstMatch(cell);

      if (match != null) {
        final cellName = match.group(1) ?? "";

        if (cellName.isNotEmpty) {
          result.putIfAbsent(cellName, () => index);
        }
      }
    }

    return result;
  }

  Map<String, int> chunkLanguageIndices(List<String?> cells) {
    final result = <String, int>{};

    final regex = RegExp(r'\{(.*?)\}');

    for (final (index, cell) in cells.indexed) {
      if (cell == null) continue;

      final match = regex.firstMatch(cell);

      if (match != null) {
        final cellName = match.group(1) ?? "";

        if (cellName.isNotEmpty) {
          result.putIfAbsent(cellName, () => index);
        }
      }
    }

    return result;
  }
}

String? getCellValue(List<Data?> row, int index) {
  return cellLikeToString(row.elementAt(index));
}

List<String?> parseColumn(Sheet sheet, int columnIndex) {
  final cells = <String?>[];

  for (var row in sheet.rows) {
    cells.add(cellLikeToString(row.elementAt(columnIndex)));
  }

  return cells;
}

String? cellLikeToString(Object? cell) {
  if (cell == null) return null;
  try {
    final dynamic dynamicCell = cell as dynamic;
    final dynamic raw = dynamicCell.value;
    return raw?.toString();
  } catch (_) {
    return cell.toString();
  }
}

Map<String, dynamic> parseExcel() {
  return {};
}
