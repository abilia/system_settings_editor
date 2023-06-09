import 'package:handi/db/settings_db.dart';

class HandiSettings {
  final bool textToSpeech;

  const HandiSettings._({
    this.textToSpeech = false,
  });

  factory HandiSettings.fromDb(SettingsDb settingsDb) =>
      HandiSettings._(textToSpeech: settingsDb.tts);

  HandiSettings copyWith({
    bool? tts,
  }) =>
      HandiSettings._(
        textToSpeech: tts ?? this.textToSpeech,
      );
}
