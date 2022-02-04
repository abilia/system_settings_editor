import 'package:shared_preferences/shared_preferences.dart';

class SerialIdDb {
  static const String _serialIdRecord = 'serialIdRecord';
  final SharedPreferences prefs;

  const SerialIdDb(this.prefs);

  Future setSerialId(String serialId) =>
      prefs.setString(_serialIdRecord, serialId);

  String? getSerialId() => prefs.getString(_serialIdRecord);

  Future deleteSerialId() => prefs.remove(_serialIdRecord);
}
