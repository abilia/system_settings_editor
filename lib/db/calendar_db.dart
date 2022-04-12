import 'package:seagull/models/all.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CalendarDb {
  static const String _calendarIdRecord = 'calendarIdRecord',
      _calendarTypeRecord = 'calendarTypeRecord',
      _calendarOwnerRecord = 'calendarOwnerRecord',
      _calendarMainRecord = 'calendarMainRecord';

  final SharedPreferences prefs;
  const CalendarDb(this.prefs);

  Future setCalendar(Calendar calendar) => Future.wait([
        prefs.setString(_calendarIdRecord, calendar.id),
        prefs.setString(_calendarTypeRecord, calendar.type),
        prefs.setInt(_calendarOwnerRecord, calendar.owner),
        prefs.setBool(_calendarMainRecord, calendar.main),
      ]);

  String? getCalendarId() => prefs.getString(_calendarIdRecord);

  Future deleteCalendar() => Future.wait([
        prefs.remove(_calendarIdRecord),
        prefs.remove(_calendarTypeRecord),
        prefs.remove(_calendarOwnerRecord),
        prefs.remove(_calendarMainRecord),
      ]);
}
