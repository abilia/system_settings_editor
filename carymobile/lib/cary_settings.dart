import 'package:carymessenger/db/settings_db.dart';

class CarySettings {
  final bool textToSpeech;

  const CarySettings._({
    this.textToSpeech = false,
  });

  factory CarySettings.fromDb(SettingsDb settingsDb) =>
      CarySettings._(textToSpeech: settingsDb.tts);

  CarySettings copyWith({
    bool? textToSpeech,
  }) =>
      CarySettings._(
        textToSpeech: textToSpeech ?? this.textToSpeech,
      );
}
