enum SentenceTtsVoice {
  femaleUs(
    id: 'English_Upbeat_Woman',
    label: '女声-美式',
    accentLabel: '美式',
    description: '清亮轻快，适合日常例句跟读。',
  ),
  maleUs(
    id: 'English_magnetic_voiced_man',
    label: '男声-美式',
    accentLabel: '美式',
    description: '低沉稳定，适合慢速模仿节奏。',
  ),
  femaleUk(
    id: 'English_compelling_lady1',
    label: '女声-英式',
    accentLabel: '英式',
    description: '咬字清晰，适合练习英式语调。',
  ),
  maleUk(
    id: 'English_expressive_narrator',
    label: '男声-英式',
    accentLabel: '英式',
    description: '抑扬明显，适合朗读型例句。',
  );

  const SentenceTtsVoice({
    required this.id,
    required this.label,
    required this.accentLabel,
    required this.description,
  });

  final String id;
  final String label;
  final String accentLabel;
  final String description;

  static SentenceTtsVoice fromId(String? id) {
    for (final voice in values) {
      if (voice.id == id) {
        return voice;
      }
    }
    return SentenceTtsVoice.femaleUs;
  }
}
