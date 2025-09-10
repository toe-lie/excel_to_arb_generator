import 'package:equatable/equatable.dart';

class Translation extends Equatable {
  const Translation({
    required this.valuesByLanguageCode,
    required this.key,
    this.description = '',
    this.placeholders = '',
  });

  final Map<String, String> valuesByLanguageCode;
  final String key;
  final String description;
  final String placeholders;

  @override
  List<Object> get props =>
      [valuesByLanguageCode, key, description, placeholders];
}
