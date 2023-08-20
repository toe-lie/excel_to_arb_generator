import 'package:excel/excel.dart';
import 'package:excel_to_arb_generator/src/excel_parser.dart';
import 'package:excel_to_arb_generator/src/models/translation.dart';
import 'package:test/test.dart';

void main() {
  late Excel excel;
  late Sheet sheet;
  late ExcelParser parser;
  const header = [
    'Feature',
    'Screen',
    'Name [name]',
    'Description [description]',
    'Remark',
    'English {en}',
    'Myanmar {my}',
    'Thai {th}',
    'Placeholders [placeholders]'
  ];

  setUp(() {
    excel = Excel.createExcel();
    sheet = excel['Sheet1'];
    parser = ExcelParser(sheet: sheet);
  });

  group('ExcelParser', () {
    group('chunkNameIndices', () {
      test('chunks valid input correctly', () {
        const header = [
          'Feature',
          'Screen',
          'Name [name]',
          'Description [description]',
          'Remark',
          'English {en}',
          'Myanmar {my}',
          'Thai {th}',
          'Placeholders [placeholders]'
        ];
        final result = parser.chunkNameIndices(header);
        final expected = {"name": 2, "description": 3, "placeholders": 8};
        expect(result, equals(expected));
      });
      test('chunks missing closing bracket input correctly', () {
        const header = [
          'Feature',
          'Screen',
          'Name [name',
          'Description [description]',
          'Remark',
          'English {en}',
          'Myanmar {my}',
          'Thai {th}',
          'Placeholders [placeholders]'
        ];
        final result = parser.chunkNameIndices(header);
        final expected = {"description": 3, "placeholders": 8};
        expect(result, equals(expected));
      });
      test('chunks missing opening bracket input correctly', () {
        const header = [
          'Feature',
          'Screen',
          'Name name]',
          'Description [description]',
          'Remark',
          'English {en}',
          'Myanmar {my}',
          'Thai {th}',
          'Placeholders [placeholders]'
        ];
        final result = parser.chunkNameIndices(header);
        final expected = {"description": 3, "placeholders": 8};
        expect(result, equals(expected));
      });
    });

    group('chunkLanguageIndices', () {
      test('chunks valid input correctly', () {
        const header = [
          'Feature',
          'Screen',
          'Name [name]',
          'Description [description]',
          'Remark',
          'English {en}',
          'Myanmar {my}',
          'Placeholders [placeholders]',
          'Thai {th}', // Test for out of order
        ];
        final result = parser.chunkLanguageIndices(header);
        final expected = {"en": 5, "my": 6, "th": 8};
        expect(result, equals(expected));
      });
    });

    test('parses valid sheet returns translations correctly', () async {
      final header = [
        'Feature',
        'Screen',
        'Name [name]',
        'Description [description]',
        'Remark',
        'English {en}',
        'Myanmar {my}',
        'Thai {th}',
        'Lao {lo}'
        'Placeholders [placeholders]'
      ];
      final row1 = [
        'Signin',
        'Company Code',
        'signinTitle',
        'Singin Title',
        'non-translatable',
        'Sign In',
        'ဝင်ရောက်ရန်',
        'เข้าสู่ระบบ',
        '',
        ''
      ];
      final nullEmptyRow = [
        '',
        null,
        '',
        null,
        '',
        '',
        '',
        null,
        '',
        ''
      ];
      final translations = [
        Translation(
          key: 'signinTitle',
          description: 'Singin Title',
          valuesByLanguageCode: {
            'en': 'Sign In',
            'my': 'ဝင်ရောက်ရန်',
            'th': 'เข้าสู่ระบบ',
            'lo': 'Sign In', // Test that it defaults to English
          },
        ),
      ];
      sheet.appendRow(header);
      sheet.appendRow(nullEmptyRow);
      sheet.appendRow(row1);

      ExcelParser parser = ExcelParser(sheet: sheet);
      List<dynamic> result = parser.parse();
      expect(result, equals(translations));
    });
  });
  group('parseRow', () {
    test('returns cells correctly', () {
      final header = ['Header0', 'Header1', 'Header2'];
      final row1 = ['Row1Col0', 'Row1Col1', 'Row1Col2'];
      sheet.appendRow(header);
      sheet.appendRow(row1);

      ExcelParser parser = ExcelParser(sheet: sheet);
      final resultHeaderRow = parser.parseRow(sheet, 0);
      final resultRow1 = parser.parseRow(sheet, 1);
      expect(resultHeaderRow, equals(header));
      expect(resultRow1, equals(row1));
    });
  });
  group('parseHeader', () {
    test('return header cells correctly', () {
      final header = ['Header0', 'Header1', 'Header2'];
      final row1 = ['Row1Col0', 'Row1Col1', 'Row1Col2'];
      sheet.appendRow(header);
      sheet.appendRow(row1);

      ExcelParser parser = ExcelParser(sheet: sheet);
      final resultHeaderRow = parser.parseHeader(sheet);
      expect(resultHeaderRow, equals(header));
    });
  });
  group('parseColumn', () {
    test('return column cells correctly', () {
      final row0 = ['Row0Col0', 'Row0Col0', 'Row0Col0'];
      final row1 = ['Row1Col0', 'Row1Col1', 'Row1Col2'];
      final row2 = ['Row2Col0', 'Row2Col1', 'Row2Col2'];
      sheet.appendRow(row0);
      sheet.appendRow(row1);
      sheet.appendRow(row2);
      final result = parseColumn(sheet, 1);
      expect(result, equals(['Row0Col0', 'Row1Col1', 'Row2Col1']));
    });
  });
}
