import 'dart:convert';

import 'package:memoplanner/models/all.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SessionDb {
  static const String _sessionRecord = 'sessionRecord';

  final SharedPreferences preferences;

  SessionDb(this.preferences);

  Future<void> setSession(Session? session) =>
      preferences.setString(_sessionRecord, json.encode(session?.toJson()));

  Session get session {
    final sessionString = preferences.getString(_sessionRecord);
    if (sessionString != null) {
      return Session.fromJson(json.decode(sessionString));
    }
    return Session.empty();
  }

  Future<void> clear() => preferences.remove(_sessionRecord);
}
