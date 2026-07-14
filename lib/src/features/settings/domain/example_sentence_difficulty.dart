enum ExampleSentenceDifficulty {
  a1(
    id: 'A1',
    label: 'A1-小学',
    shortLabel: 'A1',
    stageLabel: '小学',
    description: '短句、常见词和基础现在时，适合刚开始跟读。',
  ),
  a2(
    id: 'A2',
    label: 'A2-初中',
    shortLabel: 'A2',
    stageLabel: '初中',
    description: '日常短句，可加入简单过去或将来表达。',
  ),
  b1(
    id: 'B1',
    label: 'B1-高中',
    shortLabel: 'B1',
    stageLabel: '高中',
    description: '自然表达，允许原因、时间或对比关系。',
  ),
  b2(
    id: 'B2',
    label: 'B2-大学',
    shortLabel: 'B2',
    stageLabel: '大学',
    description: '更丰富的搭配和复合句，适合进阶朗读。',
  );

  const ExampleSentenceDifficulty({
    required this.id,
    required this.label,
    required this.shortLabel,
    required this.stageLabel,
    required this.description,
  });

  final String id;
  final String label;
  final String shortLabel;
  final String stageLabel;
  final String description;

  static ExampleSentenceDifficulty fromId(String? id) {
    final normalized = id?.trim().toUpperCase();
    for (final difficulty in values) {
      if (difficulty.id == normalized) {
        return difficulty;
      }
    }
    return ExampleSentenceDifficulty.a1;
  }
}
