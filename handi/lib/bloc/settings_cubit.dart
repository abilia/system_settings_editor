import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:handi/db/settings_db.dart';
import 'package:handi/models/settings/handi_settings.dart';

class SettingsCubit extends Cubit<HandiSettings> {
  final SettingsDb _settingsDb;

  SettingsCubit({required SettingsDb settingsDb})
      : _settingsDb = settingsDb,
        super(HandiSettings.fromDb(settingsDb));

  Future<void> setTts(bool tts) async {
    emit(state.copyWith(tts: tts));
    await _settingsDb.setTts(tts);
  }
}
