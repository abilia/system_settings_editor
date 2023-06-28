import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:support_persons/support_persons.dart';

class SupportPersonsDb {
  SupportPersonsDb(this.prefs);

  final SharedPreferences prefs;

  final String _supportUsersRecord = 'supportUsers';

  Future insertAll(Iterable<SupportPerson> supportUsers) => prefs.setStringList(
        _supportUsersRecord,
        supportUsers.map((e) => jsonEncode(e.toJson())).toList(),
      );

  Set<SupportPerson> getAll() {
    final userString = prefs.getStringList(_supportUsersRecord);
    return userString == null
        ? const {}
        : userString.map((e) => SupportPerson.fromJson(json.decode(e))).toSet();
  }
}
