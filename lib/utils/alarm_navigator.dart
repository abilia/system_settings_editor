import 'package:seagull/bloc/all.dart';
import 'package:seagull/listener/all.dart';
import 'package:seagull/logging.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/ui/all.dart';
import 'package:seagull/utils/all.dart';

class AlarmRoute<T> extends MaterialPageRoute<T> {
  AlarmRoute({
    required WidgetBuilder builder,
    bool fullscreenDialog = false,
  }) : super(builder: builder, fullscreenDialog: fullscreenDialog);
}

class AlarmNavigator {
  static const _fullScreenActivityKey = 'fullScreenActivity',
      _screenSaverKey = 'screenSaver';
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

  void _popRoute(String key) {
    final route = _routesOnStack.remove(key);
    if (route != null) {
      log.fine('route $route with key $key removed');
      route.navigator?.removeRoute(route);
    }
  }

  void addScreenSaver(MaterialPageRoute screenSaverRoute) =>
      _routesOnStack['screenSaver'] = screenSaverRoute;

  Future pushAlarm(
    BuildContext context,
    NotificationAlarm alarm,
  ) async {
    _popRoute(_screenSaverKey);
    final authProviders = copiedAuthProviders(context);
    log.fine('pushAlarm: $alarm');
    final route = AlarmRoute(
      builder: (_) => MultiBlocProvider(
        providers: authProviders,
        child: _alarmPage(alarm),
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

  MaterialPageRoute? removedFromRoutes(NotificationAlarm alarm) {
    log.info('removedFromRoutes: $alarm');
    return _routesOnStack.remove(alarm.stackId);
  }
}
