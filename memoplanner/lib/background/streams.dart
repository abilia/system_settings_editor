import 'dart:async';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:memoplanner/logging/all.dart';
import 'package:memoplanner/models/all.dart';
import 'package:rxdart/rxdart.dart';

final _log = Logger('streams');

// Stream is created so that app can respond to notification-selected events
// since the plugin is initialized in the main function
ReplaySubject<NotificationAlarm> get selectNotificationSubject =>
    _selectNotificationSubject;
ReplaySubject<NotificationAlarm> _selectNotificationSubject =
    ReplaySubject<NotificationAlarm>();

void onNotification(NotificationResponse notificationResponse) {
  final payload = notificationResponse.payload;
  if (payload != null) {
    _log.fine('notification payload: $payload');
    try {
      selectNotificationSubject.add(NotificationAlarm.decode(payload));
    } catch (e) {
      _log.severe('Failed to parse selected notification payload: $payload', e);
    }
  } else {
    _log.warning('NotificationResponse does not contain payload: '
        '$notificationResponse');
  }
}

Future<void> clearNotificationSubject() async {
  await _selectNotificationSubject.close();
  _selectNotificationSubject = ReplaySubject<NotificationAlarm>();
}
