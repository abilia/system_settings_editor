import 'package:shared_preferences/shared_preferences.dart';

class SessionsDb {
  static const String _hasMP4record = 'hasMP4record';

  final SharedPreferences preferences;

  SessionsDb(this.preferences);

  Future<void> setHasMP4Session(bool mp4Session) =>
      preferences.setBool(_hasMP4record, mp4Session);

  bool get hasMP4Session {
    final mp4Session = preferences.getBool(_hasMP4record);
    return mp4Session ?? false;
  }
}
