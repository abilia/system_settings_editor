import 'package:memoplanner/bloc/all.dart';
import 'package:memoplanner/listener/all.dart';
import 'package:memoplanner/logging.dart';
import 'package:memoplanner/models/all.dart';
import 'package:memoplanner/repository/all.dart';
import 'package:memoplanner/ui/all.dart';
import 'package:memoplanner/utils/all.dart';

class AlarmNavigator {
  static const _fullScreenActivityKey = 'fullScreenActivity',
      _screensaverKey = 'screensaver';
  final _routesOnStack = <String, MaterialPageRoute>{};
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
    _routesOnStack[alarm.stackId] = route;
    return route;
  }

  void popFullscreenRoute() => _popRoute(_fullScreenActivityKey);
  void popScreensaverRoute() => _popRoute(_screensaverKey);

  void _popRoute(String key) {
    final route = _routesOnStack.remove(key);
    if (route != null) {
      log.fine('route $route with key $key removed');
      route.navigator?.removeRoute(route);
    }
  }

  void addScreensaver(MaterialPageRoute screensaverRoute) =>
      _routesOnStack[_screensaverKey] = screensaverRoute;

  Future pushAlarm(
    BuildContext context,
    NotificationAlarm alarm,
  ) async {
    popScreensaverRoute();
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
    final routeOnStack = _routesOnStack[alarm.stackId];
    final navigator = Navigator.of(context);
    if (routeOnStack != null) {
      if (alarm is ActivityAlarm && alarm.fullScreenActivity) {
        navigator.removeRoute(routeOnStack);
        _routesOnStack[alarm.stackId] = route;
        return navigator.push(route);
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
    _routesOnStack[alarm.stackId] = route;
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

  MaterialPageRoute? removedFromRoutes(String stackId) {
    log.info('removedFromRoutes: $stackId');
    return _routesOnStack.remove(stackId);
  }

  void clearAlarmStack() => _routesOnStack.clear();
}
