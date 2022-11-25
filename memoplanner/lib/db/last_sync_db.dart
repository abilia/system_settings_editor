import 'package:shared_preferences/shared_preferences.dart';

class LastSyncDb {
  static const String _lastSyncKey = 'lastSync';
  final SharedPreferences prefs;

  const LastSyncDb(this.prefs);

  Future<void> setSyncTime(DateTime syncTime) =>
      prefs.setInt(_lastSyncKey, syncTime.millisecondsSinceEpoch);

  int? getLastSyncTime() => prefs.getInt(_lastSyncKey);

  Future<void> delete() => prefs.remove(_lastSyncKey);
}
