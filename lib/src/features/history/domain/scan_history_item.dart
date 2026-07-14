import '../../settings/domain/example_sentence_difficulty.dart';
import '../../scan/domain/analyze_result.dart';
import '../../scan/domain/word_category.dart';

class ScanHistoryItem {
  const ScanHistoryItem({
    required this.id,
    required this.imageUrl,
    required this.sourceWord,
    required this.wordCategory,
    required this.sentenceDifficulty,
    required this.audioLinks,
    required this.createdAt,
    this.phonetics = const Phonetics(uk: '', us: ''),
    this.translations = const <String, String>{},
    this.sentences = const <LearningSentence>[],
  });

  final String id;
  final String imageUrl;
  final String sourceWord;
  final WordCategory wordCategory;
  final ExampleSentenceDifficulty sentenceDifficulty;
  final AudioLinks audioLinks;
  final DateTime createdAt;
  final Phonetics phonetics;
  final Map<String, String> translations;
  final List<LearningSentence> sentences;

  factory ScanHistoryItem.fromJson(Map<String, dynamic> json) {
    final translations = _translations(json);
    return ScanHistoryItem(
      id: json['id']?.toString() ?? '',
      imageUrl: json['imageUrl']?.toString() ?? '',
      sourceWord: (json['sourceWord'] ?? json['word'])?.toString() ?? '',
      wordCategory: WordCategory.fromId(json['wordCategory']?.toString()),
      sentenceDifficulty: ExampleSentenceDifficulty.fromId(
        json['sentenceDifficulty']?.toString(),
      ),
      phonetics: Phonetics.fromJson(_asMap(json['phonetics'])),
      translations: translations,
      sentences: _sentences(json['sentences']),
      audioLinks: AudioLinks.fromJson(_asMap(json['audioLinks'])),
      createdAt:
          DateTime.tryParse(json['createdAt']?.toString() ?? '') ??
          DateTime.now(),
    );
  }

  String translationFor(String targetLanguage) {
    final direct = translations[targetLanguage];
    if (direct != null && direct.trim().isNotEmpty) {
      return direct;
    }
    if (translations.isEmpty) {
      return '';
    }
    return translations.values.first;
  }

  String get phoneticText {
    if (phonetics.us.isNotEmpty && phonetics.uk.isNotEmpty) {
      return 'US ${phonetics.us} · UK ${phonetics.uk}';
    }
    if (phonetics.us.isNotEmpty) {
      return phonetics.us;
    }
    return phonetics.uk;
  }

  static Map<String, String> _translations(Map<String, dynamic> json) {
    final values = _stringMap(json['translations']);
    if (values.isNotEmpty) {
      return values;
    }

    final fallback =
        json['chineseMeaning'] ?? json['meaning'] ?? json['translation'];
    final fallbackText = fallback?.toString().trim() ?? '';
    if (fallbackText.isEmpty) {
      return const <String, String>{};
    }
    return <String, String>{'中文': fallbackText};
  }

  static Map<String, String> _stringMap(Object? value) {
    return _asMap(
      value,
    ).map((key, value) => MapEntry(key, value?.toString() ?? ''));
  }

  static List<LearningSentence> _sentences(Object? value) {
    final rawItems = value is List ? value : _asMap(value)['items'];
    if (rawItems is! List) {
      return const <LearningSentence>[];
    }
    return rawItems
        .whereType<Map>()
        .map((item) => LearningSentence.fromJson(_asMap(item)))
        .toList(growable: false);
  }

  static Map<String, dynamic> _asMap(Object? value) {
    if (value is Map) {
      return value.map((key, value) => MapEntry(key.toString(), value));
    }
    return <String, dynamic>{};
  }
}
