import 'dart:io';
import 'dart:convert';

import 'package:path/path.dart';

import 'models/translation.dart';

class ArbCreator {
  const ArbCreator();

  Future<void> writeToFile(String directory, List<String> languageCodes, List<Translation> translations) async {
    for (final languageCode in languageCodes) {
      final file = File(join(directory, 'app_$languageCode.arb'));
      final data = <String, dynamic>{};
      for (final translation in translations) {
        data.putIfAbsent(translation.key, () => translation.valuesByLanguageCode[languageCode] ?? '');
        if (translation.description.isNotEmpty || translation.placeholders.isNotEmpty) {
          final extraMap = <String, dynamic>{};
          if (translation.description.isNotEmpty) {
            extraMap.putIfAbsent('description', () => translation.description);
          }
          if (translation.placeholders.isNotEmpty) {
            final placeholders = jsonDecode(translation.placeholders);
            extraMap.putIfAbsent('placeholders', () => placeholders);
          }
          data.putIfAbsent('@${translation.key}', () => extraMap);
        }
      }
      file.writeAsString(jsonEncode(data));
    }
  }

}