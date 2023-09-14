import 'package:logging/logging.dart';
import 'package:memoplanner/bloc/all.dart';
import 'package:memoplanner/getit.dart';
import 'package:memoplanner/listener/all.dart';
import 'package:memoplanner/models/all.dart';
import 'package:memoplanner/repository/all.dart';
import 'package:memoplanner/ui/all.dart';
import 'package:memoplanner/utils/all.dart';

class AlarmNavigator {
  static const fullScreenActivityKey = 'fullScreenActivity',
      _screensaverKey = 'screensaver';
  final _routesOnStack = <String, MaterialPageRoute>{};
  static final log = Logger((AlarmNavigator).toString());

  bool get hasRoutesOnStack => _routesOnStack.isNotEmpty;

  @visibleForTesting
  void addRouteOnStack(MaterialPageRoute route) {
    _routesOnStack[fullScreenActivityKey] = route;
  }

  Route getFullscreenAlarmRoute({
    required NotificationAlarm alarm,
    required Authenticated authenticatedState,
  }) {
    log.info('pushFullscreenAlarm: $alarm');
    final alarmPage = _alarmPage(alarm);
    final route = AlarmRoute(
      builder: (_) => AuthenticatedBlocsProvider(
        authenticatedState: authenticatedState,
        child: AlarmListener(
          alarm: alarm,
          child: PopAwareAlarmPage(
            alarm: alarm,
            alarmNavigator: this,
            stopRemoteSoundDelay: GetIt.I<Delays>().stopRemoteSoundDelay,
            child: alarmPage,
          ),
        ),
      ),
      settings: alarmPage.runtimeType
          .routeSetting(properties: _alarmProperties(alarm)),
    );
    _routesOnStack[alarm.stackId] = route;
    return route;
  }

  void popFullscreenRoute() => _popRoute(fullScreenActivityKey);
  void popScreensaverRoute() => _popRoute(_screensaverKey);

  void _popRoute(String key) {
    final route = _routesOnStack.remove(key);
    if (route != null) {
      log.info('route $route with key $key removed');
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
    log.info('pushAlarm: $alarm');
    final alarmPage = _alarmPage(alarm);
    final route = AlarmRoute(
      builder: (_) => RepositoryProvider.value(
        value: activityRepository,
        child: MultiBlocProvider(
          providers: authProviders,
          child: PopAwareAlarmPage(
            alarm: alarm,
            alarmNavigator: this,
            stopRemoteSoundDelay: GetIt.I<Delays>().stopRemoteSoundDelay,
            child: alarmPage,
          ),
        ),
      ),
      fullscreenDialog: true,
      settings: alarmPage.runtimeType
          .routeSetting(properties: _alarmProperties(alarm)),
    );
    final routeOnStack = _routesOnStack[alarm.stackId];
    final navigator = Navigator.of(context);
    if (routeOnStack != null) {
      if (alarm is ActivityAlarm && alarm.fullScreenActivity) {
        navigator.removeRoute(routeOnStack);
        _routesOnStack[alarm.stackId] = route;
        return navigator.push(route);
      }
      log.info('pushed alarm exists on stack');
      if (navigator.canPop()) {
        log.info('alarm is not root, removes');
        navigator.removeRoute(routeOnStack);
      } else {
        log.severe('alarm is root!');
        // navigator.pushAndRemoveUntil(route, (_) => false);
        // TODO(@bornold) We cannot pop root because we close all the blocs
        // created in `getFullscreenAlarmRoute()` ln 20
        // Need to find a better way to take care of replacing the root screen
        // without closing the blocs
      }
    }
    _routesOnStack[alarm.stackId] = route;
    return navigator.push(route);
  }

  Map<String, dynamic> _alarmProperties(NotificationAlarm alarm) {
    final properties = alarm.properties;
    properties['Alarm Type'] = alarm.runtimeType.toString();
    return properties;
  }

  Widget _alarmPage(NotificationAlarm alarm) => (alarm is NewAlarm)
      ? AlarmPage(alarm: alarm)
      : (alarm is NewReminder)
          ? ReminderPage(reminder: alarm)
          : (alarm is TimerAlarm)
              ? TimerAlarmPage(timerAlarm: alarm)
              : throw UnsupportedError('$alarm not supported');

  MaterialPageRoute? removedFromRoutes(String stackId) {
    log.info('removedFromRoutes: $stackId');
    return _routesOnStack.remove(stackId);
  }
}
