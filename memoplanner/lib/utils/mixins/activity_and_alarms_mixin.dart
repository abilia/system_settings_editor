import 'package:flutter/services.dart';
import 'package:logging/logging.dart';
import 'package:memoplanner/background/all.dart';
import 'package:memoplanner/bloc/all.dart';
import 'package:memoplanner/models/all.dart';
import 'package:memoplanner/repository/all.dart';
import 'package:memoplanner/ui/all.dart';
import 'package:memoplanner/utils/all.dart';

mixin ActivityAndAlarmsMixin {
  static final _log = Logger((ActivityAndAlarmsMixin).toString());

  Future<bool?> checkConfirmation(
    BuildContext context,
    ActivityDay activityDay, {
    String? message,
  }) async {
    final activitiesCubit = context.read<ActivitiesCubit>();
    final check = await showViewDialog<bool>(
      context: context,
      builder: (_) => CheckActivityConfirmDialog(
        activityDay: activityDay,
        message: message,
      ),
      routeSettings: (CheckActivityConfirmDialog).routeSetting(),
    );
    if (check == true) {
      await activitiesCubit.updateActivity(
        activityDay.activity.signOff(activityDay.day),
      );
    }
    return check;
  }

  Future<void> checkConfirmationAndRemoveAlarm(
    BuildContext context,
    ActivityDay activityDay, {
    ActivityAlarm? alarm,
    String? message,
  }) async {
    final activityRepository =
        alarm != null && context.read<LicenseCubit>().validLicense
            ? context.read<ActivityRepository>()
            : null;

    final checked = await checkConfirmation(
      context,
      activityDay,
      message: message,
    );
    if (checked == true && alarm != null) {
      await cancelNotifications(uncheckedReminders(alarm.activityDay));
      if (context.mounted) {
        await syncActivitiesAndPopAlarm(
          context: context,
          alarm: alarm,
          activityRepository: activityRepository,
        );
      }
    }
  }

  Future<void> syncActivitiesAndPopAlarm({
    required BuildContext context,
    required NotificationAlarm alarm,
    ActivityRepository? activityRepository,
  }) async {
    await activityRepository?.synchronize();
    if (context.mounted) {
      _log.fine('Popping alarm: $alarm');
      await _popAlarmPageOrCloseApp(context);
    }
  }

  Future<void> _popAlarmPageOrCloseApp(BuildContext context) =>
      _popOrRemoveRouteOrCloseApp(context);

  Future<void> removeRouteOrCloseApp(
          BuildContext context, MaterialPageRoute route) =>
      _popOrRemoveRouteOrCloseApp(context, route: route);

  Future<void> _popOrRemoveRouteOrCloseApp(
    BuildContext context, {
    MaterialPageRoute? route,
  }) async {
    final navigator = Navigator.of(context);
    final removeRoute = route != null;
    if (navigator.canPop()) {
      if (removeRoute) return navigator.removeRoute(route);
      await navigator.maybePop();
      return;
    }
    if (Config.isMPGO) {
      _log.info(
          'Could not ${removeRoute ? 'remove' : 'pop'} route, root? -> Will close app');
      return closeApp();
    }
    _log.warning('Could not pop route, root?');
  }

  Future<void> closeApp() async {
    if (Config.isMPGO) {
      _log.info('Using SystemNavigator.pop');
      return SystemNavigator.pop();
    }
    _log.warning('Attempted to use SystemNavigator.pop on MP');
  }
}
