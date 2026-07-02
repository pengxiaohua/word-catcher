class AnalyzeResult {
  const AnalyzeResult({
    required this.id,
    required this.imageUrl,
    required this.sourceWord,
    required this.phonetics,
    required this.translations,
    required this.sentences,
    required this.audioLinks,
    this.createdAt,
  });

  final String id;
  final String imageUrl;
  final String sourceWord;
  final Phonetics phonetics;
  final Map<String, String> translations;
  final List<LearningSentence> sentences;
  final AudioLinks audioLinks;
  final DateTime? createdAt;

  factory AnalyzeResult.fromJson(Map<String, dynamic> json) {
    return AnalyzeResult(
      id: _stringValue(json['id'] ?? json['scanHistoryId']),
      imageUrl: _stringValue(json['imageUrl']),
      sourceWord: _stringValue(json['sourceWord'] ?? json['word']),
      phonetics: Phonetics.fromJson(_asMap(json['phonetics'])),
      translations: _stringMap(json['translations']),
      sentences: _sentences(json['sentences']),
      audioLinks: AudioLinks.fromJson(_asMap(json['audioLinks'])),
      createdAt: DateTime.tryParse(_stringValue(json['createdAt'])),
    );
  }

  String translationFor(String targetLanguage) {
    final direct = translations[targetLanguage];
    if (direct != null && direct.isNotEmpty) {
      return direct;
    }
    if (translations.isEmpty) {
      return '暂无翻译';
    }
    return translations.values.first;
  }

  static Map<String, dynamic> _asMap(Object? value) {
    if (value is Map) {
      return value.map((key, value) => MapEntry(key.toString(), value));
    }
    return <String, dynamic>{};
  }

  static Map<String, String> _stringMap(Object? value) {
    return _asMap(
      value,
    ).map((key, value) => MapEntry(key, _stringValue(value)));
  }

  static List<LearningSentence> _sentences(Object? value) {
    final rawItems = value is List ? value : _asMap(value)['items'];
    if (rawItems is! List) {
      return const [];
    }
    return rawItems
        .whereType<Map>()
        .map((item) => LearningSentence.fromJson(_asMap(item)))
        .toList(growable: false);
  }

  static String _stringValue(Object? value) => value?.toString() ?? '';
}

class Phonetics {
  const Phonetics({required this.uk, required this.us});

  final String uk;
  final String us;

  factory Phonetics.fromJson(Map<String, dynamic> json) {
    return Phonetics(
      uk: json['uk']?.toString() ?? json['british']?.toString() ?? '',
      us: json['us']?.toString() ?? json['american']?.toString() ?? '',
    );
  }
}

class LearningSentence {
  const LearningSentence({
    required this.english,
    required this.translation,
    this.audioUrl = '',
  });

  final String english;
  final String translation;
  final String audioUrl;

  factory LearningSentence.fromJson(Map<String, dynamic> json) {
    return LearningSentence(
      english: json['english']?.toString() ?? json['en']?.toString() ?? '',
      translation:
          json['translation']?.toString() ??
          json['target']?.toString() ??
          json['zh']?.toString() ??
          '',
      audioUrl:
          json['audioUrl']?.toString() ??
          json['audio']?.toString() ??
          json['ttsUrl']?.toString() ??
          '',
    );
  }
}

class AudioLinks {
  const AudioLinks({required this.uk, required this.us});

  final String uk;
  final String us;

  factory AudioLinks.fromJson(Map<String, dynamic> json) {
    return AudioLinks(
      uk: json['uk']?.toString() ?? json['british']?.toString() ?? '',
      us: json['us']?.toString() ?? json['american']?.toString() ?? '',
    );
  }

  String get preferred => us.isNotEmpty ? us : uk;
}
