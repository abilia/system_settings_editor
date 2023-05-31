import 'package:shared_preferences/shared_preferences.dart';
import 'package:utils/utils.dart';

class LastSyncDb {
  static const String _lastSyncKey = 'lastSync';
  final SharedPreferences prefs;

  const LastSyncDb(this.prefs);

  Future<void> setSyncTime(DateTime syncTime) =>
      prefs.setInt(_lastSyncKey, syncTime.millisecondsSinceEpoch);

  DateTime? getLastSyncTime() =>
      prefs.getInt(_lastSyncKey).fromMillisecondsSinceEpoch();
}
