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
      BuildContext context, NotificationAlarm alarm) async {
    if (alarm is NewAlarm) {
      final alarmId = '${alarm.activity.id}${alarm.alarmOnStart}}';
      return await _push(
          context,
          MaterialPageRoute(
            builder: (context) => AlarmPage(
              activity: alarm.activity,
              atStartTime: alarm.alarmOnStart,
              atEndTime: !alarm.alarmOnStart,
            ),
            fullscreenDialog: true,
          ),
          alarmId);
    } else if (alarm is NewReminder) {
      final reminderId = '${alarm.activity.id}${alarm.reminder.inMinutes}';
      return await _push(
        context,
        MaterialPageRoute(
          builder: (context) => ReminderPage(
            activity: alarm.activity,
            reminderTime: alarm.reminder.inMinutes,
          ),
          fullscreenDialog: true,
        ),
        reminderId,
      );
    } else {
      throw ArgumentError();
    }
  }

  bool pop<T extends Object>(BuildContext context) {
    if (_routes.keys.isNotEmpty) {
      _routes.remove(_routes.keys.last);
    }
    return Navigator.of(context).pop();
  }
}
