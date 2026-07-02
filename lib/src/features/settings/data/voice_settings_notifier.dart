import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../domain/tts_voice_option.dart';

final voiceSettingsProvider =
    AsyncNotifierProvider<VoiceSettingsNotifier, VoiceSettings>(
      VoiceSettingsNotifier.new,
    );

class VoiceSettingsNotifier extends AsyncNotifier<VoiceSettings> {
  static const _sentenceVoiceKey = 'sentence_tts_voice_id';

  @override
  Future<VoiceSettings> build() async {
    final preferences = await SharedPreferences.getInstance();
    return VoiceSettings(
      sentenceVoice: SentenceTtsVoice.fromId(
        preferences.getString(_sentenceVoiceKey),
      ),
    );
  }

  Future<void> updateSentenceVoice(SentenceTtsVoice voice) async {
    final previous = state.value ?? const VoiceSettings();
    state = AsyncData(previous.copyWith(sentenceVoice: voice));

    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_sentenceVoiceKey, voice.id);
  }
}

class VoiceSettings {
  const VoiceSettings({this.sentenceVoice = SentenceTtsVoice.femaleUs});

  final SentenceTtsVoice sentenceVoice;

  VoiceSettings copyWith({SentenceTtsVoice? sentenceVoice}) {
    return VoiceSettings(sentenceVoice: sentenceVoice ?? this.sentenceVoice);
  }
}
