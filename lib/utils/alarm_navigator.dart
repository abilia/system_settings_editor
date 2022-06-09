import 'package:seagull/bloc/all.dart';
import 'package:seagull/listener/all.dart';
import 'package:seagull/logging.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/repository/all.dart';
import 'package:seagull/ui/all.dart';
import 'package:seagull/utils/all.dart';

class AlarmRoute<T> extends MaterialPageRoute<T> {
  AlarmRoute({
    required WidgetBuilder builder,
    bool fullscreenDialog = false,
  }) : super(builder: builder, fullscreenDialog: fullscreenDialog);
}

class AlarmNavigator {
  final _alarmRoutesOnStack = <String, AlarmRoute>{};
  static final log = Logger((AlarmNavigator).toString());

  Route getFullscreenAlarmRoute({
    required NotificationAlarm alarm,
    required Authenticated authenticatedState,
  }) {
    log.fine('pushFullscreenAlarm: $alarm');
    final route = AlarmRoute(
      builder: (_) => AuthenticatedBlocsProvider(
        authenticatedState: authenticatedState,
        child: AlarmListener(child: _alarmPage(alarm)),
      ),
    );
    _alarmRoutesOnStack[alarm.stackId] = route;
    return route;
  }

  void popFullscreenRoute() {
    final route = _alarmRoutesOnStack['fullScreenActivity'];
    if (route != null) {
      final navigator = route.navigator;
      _alarmRoutesOnStack.remove('fullScreenActivity');
      navigator?.removeRoute(route);
    }
  }

  Future pushAlarm(
    BuildContext context,
    NotificationAlarm alarm,
  ) async {
    final authProviders = copiedAuthProviders(context);
    final activityRepository = context.read<ActivityRepository>();
    log.fine('pushAlarm: $alarm');
    final route = AlarmRoute(
      builder: (_) => RepositoryProvider.value(
        value: activityRepository,
        child: MultiBlocProvider(
          providers: authProviders,
          child: _alarmPage(alarm),
        ),
      ),
      fullscreenDialog: true,
    );
    final routeOnStack = _alarmRoutesOnStack[alarm.stackId];
    final navigator = Navigator.of(context);
    if (routeOnStack != null) {
      if (alarm is ActivityAlarm && alarm.fullScreenActivity) {
        navigator.removeRoute(routeOnStack);
        _alarmRoutesOnStack[alarm.stackId] = route;
        await navigator.push(route);
        return;
      }
      log.fine('pushed alarm exists on stack');
      if (navigator.canPop()) {
        log.finer('alarm is not root, removes');
        navigator.removeRoute(routeOnStack);
      } else {
        log.finer('alarm is root, replacing');
        return navigator.pushAndRemoveUntil(route, (_) => false);
      }
    }
    _alarmRoutesOnStack[alarm.stackId] = route;
    return navigator.push(route);
  }

  Widget _alarmPage(NotificationAlarm alarm) => PopAwareAlarmPage(
        alarm: alarm,
        alarmNavigator: this,
        child: (alarm is NewAlarm)
            ? AlarmPage(alarm: alarm)
            : (alarm is NewReminder)
                ? ReminderPage(reminder: alarm)
                : (alarm is TimerAlarm)
                    ? TimerAlarmPage(timerAlarm: alarm)
                    : throw UnsupportedError('$alarm not supported'),
      );

  MaterialPageRoute? removedFromRoutes(NotificationAlarm alarm) {
    log.info('removedFromRoutes: $alarm');
    return _alarmRoutesOnStack.remove(alarm.stackId);
  }
}
