import 'package:flutter/widgets.dart';
import 'package:logging/logging.dart';
import 'package:collection/collection.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/config.dart';

/// Always use [copiedAuthProviders] outside the builder callback
/// Otherwise hot reload might throw exception
List<BlocProvider> copiedAuthProviders(BuildContext blocContext) => [
      _tryGetBloc<SyncBloc>(blocContext),
      _tryGetBloc<ActivitiesBloc>(blocContext),
      _tryGetBloc<UserFileCubit>(blocContext),
      _tryGetBloc<SortableBloc>(blocContext),
      _tryGetBloc<GenericBloc>(blocContext),
      _tryGetBloc<MemoplannerSettingBloc>(blocContext),
      _tryGetBloc<DayPickerBloc>(blocContext),
      _tryGetBloc<DayEventsCubit>(blocContext),
      _tryGetBloc<AlarmCubit>(blocContext),
      _tryGetBloc<CalendarViewCubit>(blocContext),
      _tryGetBloc<LicenseBloc>(blocContext),
      _tryGetBloc<PermissionCubit>(blocContext),
      _tryGetBloc<TimepillarCubit>(blocContext),
      _tryGetBloc<TimerCubit>(blocContext),
      _tryGetBloc<TimerAlarmBloc>(blocContext),
      if (Config.isMP) _tryGetBloc<MonthCalendarCubit>(blocContext),
      if (Config.isMP) _tryGetBloc<WeekCalendarCubit>(blocContext),
      if (Config.isMP) _tryGetBloc<WakeLockCubit>(blocContext),
      if (Config.isMP) _tryGetBloc<InactivityCubit>(blocContext),
    ].whereNotNull().toList();

final _copyBlocLog = Logger('CopiedAuthProvider');

BlocProvider? _tryGetBloc<B extends BlocBase>(BuildContext context) {
  try {
    return BlocProvider<B>.value(value: context.read<B>());
  } catch (e) {
    _copyBlocLog.warning('Could not fetch provider of $B', e);
    return null;
  }
}
