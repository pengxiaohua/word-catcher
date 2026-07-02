import '../../scan/domain/analyze_result.dart';

class ScanHistoryItem {
  const ScanHistoryItem({
    required this.id,
    required this.imageUrl,
    required this.sourceWord,
    required this.audioLinks,
    required this.createdAt,
  });

  final String id;
  final String imageUrl;
  final String sourceWord;
  final AudioLinks audioLinks;
  final DateTime createdAt;

  factory ScanHistoryItem.fromJson(Map<String, dynamic> json) {
    return ScanHistoryItem(
      id: json['id']?.toString() ?? '',
      imageUrl: json['imageUrl']?.toString() ?? '',
      sourceWord: (json['sourceWord'] ?? json['word'])?.toString() ?? '',
      audioLinks: AudioLinks.fromJson(_asMap(json['audioLinks'])),
      createdAt:
          DateTime.tryParse(json['createdAt']?.toString() ?? '') ??
          DateTime.now(),
    );
  }

  static Map<String, dynamic> _asMap(Object? value) {
    if (value is Map) {
      return value.map((key, value) => MapEntry(key.toString(), value));
    }
    return <String, dynamic>{};
  }
}
