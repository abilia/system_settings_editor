import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class DeviceDb {
  static const String _serialIdRecord = 'serialIdRecord';
  static const String _clientIdRecord = 'clientIdRecord';
  final SharedPreferences prefs;

  const DeviceDb(this.prefs);

  Future<void> setSerialId(String serialId) =>
      prefs.setString(_serialIdRecord, serialId);

  String get serialId => prefs.getString(_serialIdRecord) ?? '';

  Future<String> getClientId() async {
    final clientId = prefs.getString(_clientIdRecord);
    if (clientId != null) return clientId;
    final newClientId = const Uuid().v4();
    await prefs.setString(_clientIdRecord, newClientId);
    return newClientId;
  }
}
