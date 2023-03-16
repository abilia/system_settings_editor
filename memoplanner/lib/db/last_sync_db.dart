import 'package:memoplanner/utils/all.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LastSyncDb {
  static const String _lastSyncKey = 'lastSync';
  final SharedPreferences prefs;

  const LastSyncDb(this.prefs);

  Future<void> setSyncTime(DateTime syncTime) =>
      prefs.setInt(_lastSyncKey, syncTime.millisecondsSinceEpoch);

  DateTime? getLastSyncTime() =>
      prefs.getInt(_lastSyncKey).fromMillisecondsSinceEpoch();
}
