import 'package:shared_preferences/shared_preferences.dart';

class DeviceDb {
  static const String _serialIdRecord = 'serialIdRecord';
  static const String _clientIdRecord = 'clientIdRecord';
  final SharedPreferences prefs;

  const DeviceDb(this.prefs);

  Future<void> setSerialId(String serialId) =>
      prefs.setString(_serialIdRecord, serialId);

  String? getSerialId() => prefs.getString(_serialIdRecord);

  Future<void> setClientId(String clientId) =>
      prefs.setString(_clientIdRecord, clientId);

  String? getClientId() => prefs.getString(_clientIdRecord);
}
