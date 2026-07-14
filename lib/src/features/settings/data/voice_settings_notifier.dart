import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../domain/example_sentence_difficulty.dart';
import '../domain/tts_voice_option.dart';

final voiceSettingsProvider =
    AsyncNotifierProvider<VoiceSettingsNotifier, VoiceSettings>(
      VoiceSettingsNotifier.new,
    );

class VoiceSettingsNotifier extends AsyncNotifier<VoiceSettings> {
  static const _sentenceVoiceKey = 'sentence_tts_voice_id';
  static const _sentenceDifficultyKey = 'example_sentence_difficulty';

  @override
  Future<VoiceSettings> build() async {
    final preferences = await SharedPreferences.getInstance();
    return VoiceSettings(
      sentenceVoice: SentenceTtsVoice.fromId(
        preferences.getString(_sentenceVoiceKey),
      ),
      sentenceDifficulty: ExampleSentenceDifficulty.fromId(
        preferences.getString(_sentenceDifficultyKey),
      ),
    );
  }

  Future<void> updateSentenceVoice(SentenceTtsVoice voice) async {
    final previous = state.value ?? const VoiceSettings();
    state = AsyncData(previous.copyWith(sentenceVoice: voice));

    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_sentenceVoiceKey, voice.id);
  }

  Future<void> updateSentenceDifficulty(
    ExampleSentenceDifficulty difficulty,
  ) async {
    final previous = state.value ?? const VoiceSettings();
    state = AsyncData(previous.copyWith(sentenceDifficulty: difficulty));

    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_sentenceDifficultyKey, difficulty.id);
  }
}

class VoiceSettings {
  const VoiceSettings({
    this.sentenceVoice = SentenceTtsVoice.femaleUs,
    this.sentenceDifficulty = ExampleSentenceDifficulty.a1,
  });

  final SentenceTtsVoice sentenceVoice;
  final ExampleSentenceDifficulty sentenceDifficulty;

  VoiceSettings copyWith({
    SentenceTtsVoice? sentenceVoice,
    ExampleSentenceDifficulty? sentenceDifficulty,
  }) {
    return VoiceSettings(
      sentenceVoice: sentenceVoice ?? this.sentenceVoice,
      sentenceDifficulty: sentenceDifficulty ?? this.sentenceDifficulty,
    );
  }
}
