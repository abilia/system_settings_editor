import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/ui/pages/all.dart';

class AlarmNavigator {
  final Map<String, Route<dynamic>> _routes = LinkedHashMap();

  Future<T> _push<T extends Object>(
      BuildContext context, Route<T> route, String id) {
    if (_routes.keys.isNotEmpty && _routes.keys.last == id) {
      return Future(() => null);
    } else if (_routes.keys.contains(id)) {
      final removedRoute = _routes.remove(id);
      _routes.putIfAbsent(id, () => route);
      Navigator.of(context).removeRoute(removedRoute);
      return Navigator.of(context).push(route);
    } else {
      _routes.putIfAbsent(id, () => route);
      return Navigator.of(context).push(route);
    }
  }

  Future<T> pushAlarm<T extends Object>(
    BuildContext outerContext,
    NotificationAlarm alarm,
  ) async {
    String id;
    Widget page;

    if (alarm is NewAlarm) {
      id = '${alarm.activity.id}${alarm.alarmOnStart}}';
      page = AlarmPage(
        activity: alarm.activity,
        day: alarm.day,
        atStartTime: alarm.alarmOnStart,
        atEndTime: !alarm.alarmOnStart,
      );
    } else if (alarm is NewReminder) {
      id = '${alarm.activity.id}${alarm.reminder.inMinutes}';
      page = ReminderPage(
        activity: alarm.activity,
        day: alarm.day,
        reminderTime: alarm.reminder.inMinutes,
      );
    } else {
      throw ArgumentError();
    }
    return await _push(
      outerContext,
      MaterialPageRoute(
        builder: (context) => page,
        fullscreenDialog: true,
      ),
      id,
    );
  }

  bool pop<T extends Object>(BuildContext context) {
    if (_routes.keys.isNotEmpty) {
      _routes.remove(_routes.keys.last);
    }
    return Navigator.of(context).pop();
  }
}
