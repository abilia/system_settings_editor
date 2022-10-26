import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class DeviceDb {
  static const String _serialIdRecord = 'serialIdRecord';
  static const String _clientIdRecord = 'clientIdRecord';
  static const String _startGuideCompletedRecord = 'startGuideCompletedRecord';
  final SharedPreferences prefs;

  const DeviceDb(this.prefs);

  Future<void> setSerialId(String serialId) =>
      prefs.setString(_serialIdRecord, serialId);

  String get serialId => prefs.getString(_serialIdRecord) ?? '';

  Future<void> setStartGuideCompleted(bool completed) =>
      prefs.setBool(_startGuideCompletedRecord, completed);

  bool get startGuideCompleted =>
      prefs.getBool(_startGuideCompletedRecord) ?? false;

  Future<String> getClientId() async {
    final clientId = prefs.getString(_clientIdRecord);
    if (clientId != null) return clientId;
    final newClientId = const Uuid().v4();
    await prefs.setString(_clientIdRecord, newClientId);
    return newClientId;
  }
}
