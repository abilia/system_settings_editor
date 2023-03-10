import 'dart:convert';

import 'package:memoplanner/models/all.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class DeviceDb {
  static const String _serialIdRecord = 'serialIdRecord',
      _clientIdRecord = 'clientIdRecord',
      _supportIdRecord = 'clientIdRecord',
      _startGuideCompletedRecord = 'startGuideCompletedRecord',
      _deviceLicenseRecord = 'deviceLicenseRecord';
  final SharedPreferences prefs;

  const DeviceDb(this.prefs);

  Future<void> setSerialId(String serialId) =>
      prefs.setString(_serialIdRecord, serialId);

  String get serialId => prefs.getString(_serialIdRecord) ?? '';

  Future<void> setStartGuideCompleted(bool completed) =>
      prefs.setBool(_startGuideCompletedRecord, completed);

  bool get startGuideCompleted =>
      prefs.getBool(_startGuideCompletedRecord) ?? false;

  Future<String> getClientId() => _getOrSetUuid(_clientIdRecord);

  Future<String> getSupportId() => _getOrSetUuid(_supportIdRecord);

  Future<String> _getOrSetUuid(String record) async {
    final id = prefs.getString(record);
    if (id != null) return id;
    final newId = const Uuid().v4();
    await prefs.setString(_clientIdRecord, newId);
    return newId;
  }

  Future<void> setDeviceLicense(DeviceLicense license) =>
      prefs.setString(_deviceLicenseRecord, json.encode(license));

  Future<void> clearDeviceLicense() =>
      prefs.setString(_deviceLicenseRecord, '');

  DeviceLicense? getDeviceLicense() {
    final licenseJson = prefs.getString(_deviceLicenseRecord);
    if (licenseJson == null || licenseJson.isEmpty) {
      return null;
    }
    return DeviceLicense.fromJson(json.decode(licenseJson));
  }
}
