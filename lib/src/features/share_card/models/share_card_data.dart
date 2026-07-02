import '../../scan/domain/analyze_result.dart';
import 'share_card_template.dart';

class ShareCardData {
  const ShareCardData({
    required this.imageUrl,
    required this.englishWord,
    required this.chineseMeaning,
    required this.sentences,
    this.localImagePath,
    this.phoneticText = '',
    this.createdAt,
    this.template = ShareCardTemplate.postcard,
    this.selectedSentenceIndex = 0,
    this.showChineseMeaning = true,
    this.showPhoneticText = true,
    this.showSentence = true,
    this.showDate = true,
    this.showWatermark = true,
  });

  factory ShareCardData.fromAnalyzeResult({
    required AnalyzeResult result,
    required String targetLanguage,
    String? localImagePath,
  }) {
    return ShareCardData(
      imageUrl: result.imageUrl,
      localImagePath: localImagePath,
      englishWord: result.sourceWord,
      phoneticText: _phoneticText(result),
      chineseMeaning: _meaningText(result, targetLanguage),
      sentences: result.sentences
          .map(
            (sentence) => ShareCardSentence(
              english: sentence.english,
              translation: sentence.translation,
            ),
          )
          .toList(growable: false),
      createdAt: result.createdAt ?? DateTime.now(),
    );
  }

  final String imageUrl;
  final String? localImagePath;
  final String englishWord;
  final String phoneticText;
  final String chineseMeaning;
  final List<ShareCardSentence> sentences;
  final DateTime? createdAt;
  final ShareCardTemplate template;
  final int selectedSentenceIndex;
  final bool showChineseMeaning;
  final bool showPhoneticText;
  final bool showSentence;
  final bool showDate;
  final bool showWatermark;

  ShareCardSentence? get selectedSentence {
    if (sentences.isEmpty) {
      return null;
    }
    final index = selectedSentenceIndex.clamp(0, sentences.length - 1);
    return sentences[index];
  }

  String get safeFileWord {
    final word = englishWord
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
        .replaceAll(RegExp(r'(^-|-$)'), '');
    return word.isEmpty ? 'word-card' : word;
  }

  ShareCardData copyWith({
    String? imageUrl,
    String? localImagePath,
    String? englishWord,
    String? phoneticText,
    String? chineseMeaning,
    List<ShareCardSentence>? sentences,
    DateTime? createdAt,
    ShareCardTemplate? template,
    int? selectedSentenceIndex,
    bool? showChineseMeaning,
    bool? showPhoneticText,
    bool? showSentence,
    bool? showDate,
    bool? showWatermark,
  }) {
    return ShareCardData(
      imageUrl: imageUrl ?? this.imageUrl,
      localImagePath: localImagePath ?? this.localImagePath,
      englishWord: englishWord ?? this.englishWord,
      phoneticText: phoneticText ?? this.phoneticText,
      chineseMeaning: chineseMeaning ?? this.chineseMeaning,
      sentences: sentences ?? this.sentences,
      createdAt: createdAt ?? this.createdAt,
      template: template ?? this.template,
      selectedSentenceIndex:
          selectedSentenceIndex ?? this.selectedSentenceIndex,
      showChineseMeaning: showChineseMeaning ?? this.showChineseMeaning,
      showPhoneticText: showPhoneticText ?? this.showPhoneticText,
      showSentence: showSentence ?? this.showSentence,
      showDate: showDate ?? this.showDate,
      showWatermark: showWatermark ?? this.showWatermark,
    );
  }

  static String _phoneticText(AnalyzeResult result) {
    if (result.phonetics.us.isNotEmpty && result.phonetics.uk.isNotEmpty) {
      return 'US ${result.phonetics.us} · UK ${result.phonetics.uk}';
    }
    if (result.phonetics.us.isNotEmpty) {
      return result.phonetics.us;
    }
    return result.phonetics.uk;
  }

  static String _meaningText(AnalyzeResult result, String targetLanguage) {
    const chineseKeys = ['中文', '简体中文', 'Chinese', 'zh', 'zh-CN'];
    for (final key in chineseKeys) {
      final value = result.translations[key];
      if (value != null && value.trim().isNotEmpty) {
        return value;
      }
    }
    return result.translationFor(targetLanguage);
  }
}

class ShareCardSentence {
  const ShareCardSentence({required this.english, required this.translation});

  final String english;
  final String translation;
}
