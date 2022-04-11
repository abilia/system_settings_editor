import 'dart:convert';

import 'package:seagull/models/all.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CalendarDb {
  static const String _calendarIdRecord = 'calendarIdRecord';
  final SharedPreferences prefs;
  const CalendarDb(this.prefs);

  Future<void> setCalendarType(CalendarType calendarType) =>
      prefs.setString(_calendarIdRecord, jsonEncode(calendarType.toJson()));

  CalendarType? getCalendarType() {
    final calendarTypeJson = prefs.getString(_calendarIdRecord);
    if (calendarTypeJson != null) {
      return CalendarType.fromJson(jsonDecode(calendarTypeJson));
    }
    return null;
  }

  Future<bool> deleteCalendar() => prefs.remove(_calendarIdRecord);
}
