import 'package:flutter/material.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/ui/pages/all.dart';

class AlarmNavigator {
  final Map<String, Route<dynamic>> _routes = {};

  Future<T> _push<T extends Object>(
      BuildContext context, Route<T> route, String id) {
    final nav = Navigator.of(context);
    if (_routes.keys.isNotEmpty && _routes.keys.last == id) {
      return nav.pushReplacement(route);
    } else if (_routes.keys.contains(id)) {
      final removedRoute = _routes.remove(id);
      _routes.putIfAbsent(id, () => route);
      nav.removeRoute(removedRoute);
      return nav.push(route);
    } else {
      _routes.putIfAbsent(id, () => route);
      return nav.push(route);
    }
  }

  Future<T> pushAlarm<T extends Object>(
    BuildContext outerContext,
    NotificationAlarm alarm,
  ) async {
    Widget page;

    if (alarm is NewAlarm) {
      page = AlarmPage(activityDay: alarm.activityDay);
    } else if (alarm is NewReminder) {
      page = ReminderPage(reminder: alarm);
    } else {
      throw ArgumentError();
    }
    return await _push(
      outerContext,
      MaterialPageRoute(
        builder: (context) => page,
        fullscreenDialog: true,
      ),
      alarm.activityDay.activity.id,
    );
  }
}
