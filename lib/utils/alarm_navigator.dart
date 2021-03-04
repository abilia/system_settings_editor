import 'package:flutter/material.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/ui/pages/all.dart';

class AlarmNavigator {
  final alarmRouteObserver = RouteObserver<MaterialPageRoute>();
  final _alarmRoutesOnStack = <String, AlarmPageRoute>{};

  Future pushAlarm(
    BuildContext context,
    NotificationAlarm alarm,
  ) async {
    final route = AlarmPageRoute(
      alarm,
      builder: (_) => CopiedAuthProviders(
        blocContext: context,
        child: (alarm is NewAlarm)
            ? NavigatableAlarmPage(alarm: alarm, alarmNavigator: this)
            : NavigatableReminderPage(reminder: alarm, alarmNavigator: this),
      ),
      fullscreenDialog: true,
    );

    final id = alarm.activity.id;
    final routeOnStack = _alarmRoutesOnStack[id];
    final navigator = Navigator.of(context);
    if (routeOnStack != null) {
      navigator.removeRoute(routeOnStack);
    }
    _alarmRoutesOnStack[id] = route;
    return navigator.push(route);
  }

  AlarmPageRoute removedFromRoutes(NotificationAlarm alarm) {
    return _alarmRoutesOnStack.remove(alarm.activity.id);
  }
}

class AlarmPageRoute<T> extends MaterialPageRoute<T> {
  final NotificationAlarm alarm;
  AlarmPageRoute(
    this.alarm, {
    @required WidgetBuilder builder,
    RouteSettings settings,
    bool maintainState = true,
    bool fullscreenDialog = false,
  }) : super(
          builder: builder,
          settings: settings,
          maintainState: maintainState,
          fullscreenDialog: fullscreenDialog,
        );
  @override
  String get debugLabel => '${super.debugLabel}($alarm)';
}
