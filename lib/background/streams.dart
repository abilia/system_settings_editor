import 'dart:async';

import 'package:rxdart/rxdart.dart';
import 'package:seagull/logging.dart';
import 'package:seagull/models/all.dart';

final _log = Logger('streams');

// Stream is created so that app can respond to notification-selected events
// since the plugin is initialized in the main function
ReplaySubject<NotificationAlarm> get selectNotificationSubject =>
    _selectNotificationSubject;
ReplaySubject<NotificationAlarm> _selectNotificationSubject =
    ReplaySubject<NotificationAlarm>();

void onNotification(String? payload) async {
  if (payload != null) {
    _log.fine('notification payload: $payload');
    try {
      selectNotificationSubject.add(NotificationAlarm.decode(payload));
    } catch (e) {
      _log.severe('Failed to parse selected notification payload: $payload', e);
    }
  }
}

Future<void> clearNotificationSubject() async {
  await _selectNotificationSubject.close();
  _selectNotificationSubject = ReplaySubject<NotificationAlarm>();
}
