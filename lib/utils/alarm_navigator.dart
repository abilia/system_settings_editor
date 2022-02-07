import 'package:seagull/bloc/all.dart';
import 'package:seagull/listener/all.dart';
import 'package:seagull/logging.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/ui/all.dart';
import 'package:seagull/ui/pages/fullscreen_activity_page.dart';
import 'package:seagull/utils/all.dart';

class AlarmNavigator {
  final _alarmRoutesOnStack = <String, MaterialPageRoute>{};
  static final log = Logger((AlarmNavigator).toString());
  static const _ongoingFullscreenActivityId = 'fullscreenActivity';

  Route getFullscreenAlarmRoute({
    required NotificationAlarm alarm,
    required Authenticated authenticatedState,
  }) {
    log.fine('pushFullscreenAlarm: $alarm');
    final route = MaterialPageRoute(
      builder: (_) => AuthenticatedBlocsProvider(
        authenticatedState: authenticatedState,
        child: AlarmListener(child: _alarmPage(alarm, true)),
      ),
    );
    _alarmRoutesOnStack[alarm.activity.id] = route;
    return route;
  }

  Future pushAlarm(
    BuildContext context,
    NotificationAlarm alarm,
    bool fullScreenActivity,
  ) async {
    final authProviders = copiedAuthProviders(context);
    log.fine('pushAlarm: $alarm');
    final route = MaterialPageRoute(
      builder: (_) => MultiBlocProvider(
        providers: authProviders,
        child: _alarmPage(alarm, fullScreenActivity),
      ),
      fullscreenDialog: true,
    );
    final id = fullScreenActivity && alarm is StartAlarm
        ? _ongoingFullscreenActivityId
        : alarm.activity.id;
    final routeOnStack = _alarmRoutesOnStack[id];
    final navigator = Navigator.of(context);
    if (routeOnStack != null) {
      log.fine('pushed alarm exists on stack');
      if (navigator.canPop()) {
        log.finer('alarm is not root, removes');
        navigator.removeRoute(routeOnStack);
      } else {
        log.finer('alarm is root, replacing');
        return navigator.pushAndRemoveUntil(route, (_) => false);
      }
    }
    _alarmRoutesOnStack[id] = route;
    return navigator.push(route);
  }

  Widget _alarmPage(NotificationAlarm alarm, bool fullscreenActivity) =>
      PopAwareAlarmPage(
        alarm: alarm,
        alarmNavigator: this,
        child: (alarm is NewAlarm)
            ? fullscreenActivity
                ? FullScreenActivityPage(activityDay: alarm.activityDay)
                : AlarmPage(alarm: alarm)
            : (alarm is NewReminder)
                ? ReminderPage(reminder: alarm)
                : throw UnsupportedError('$alarm not supported'),
      );

  MaterialPageRoute? removedFromRoutes(NotificationAlarm alarm) {
    log.info('removedFromRoutes: $alarm');
    return _alarmRoutesOnStack.remove(alarm.activity.id);
  }

  MaterialPageRoute? removeFullScreenActivity() {
    log.info('removedFromRoutes: fullscreen');
    return _alarmRoutesOnStack.remove(_ongoingFullscreenActivityId);
  }
}
