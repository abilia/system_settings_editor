import 'package:flutter/widgets.dart';
import 'package:logging/logging.dart';
import 'package:collection/collection.dart';
import 'package:memoplanner/bloc/all.dart';
import 'package:memoplanner/config.dart';

/// Always use [copiedAuthProviders] outside the builder callback
/// Otherwise hot reload might throw exception
List<BlocProvider> copiedAuthProviders(BuildContext blocContext) => [
      ...copiedTopLevelProviders(blocContext),
      _tryGetBloc<SyncBloc>(blocContext),
      _tryGetBloc<ActivitiesBloc>(blocContext),
      _tryGetBloc<UserFileCubit>(blocContext),
      _tryGetBloc<SortableBloc>(blocContext),
      _tryGetBloc<GenericCubit>(blocContext),
      _tryGetBloc<MemoplannerSettingsBloc>(blocContext),
      _tryGetBloc<DayPickerBloc>(blocContext),
      _tryGetBloc<DayEventsCubit>(blocContext),
      _tryGetBloc<AlarmCubit>(blocContext),
      _tryGetBloc<CalendarViewCubit>(blocContext),
      _tryGetBloc<LicenseCubit>(blocContext),
      _tryGetBloc<PermissionCubit>(blocContext),
      _tryGetBloc<TimepillarCubit>(blocContext),
      _tryGetBloc<TimepillarMeasuresCubit>(blocContext),
      _tryGetBloc<DayPartCubit>(blocContext),
      _tryGetBloc<TimerCubit>(blocContext),
      _tryGetBloc<NotificationBloc>(blocContext),
      _tryGetBloc<TimerAlarmBloc>(blocContext),
      _tryGetBloc<WeekCalendarCubit>(blocContext),
      _tryGetBloc<SessionsCubit>(blocContext),
      _tryGetBloc<FeatureToggleCubit>(blocContext),
      if (Config.isMP) ...[
        _tryGetBloc<WakeLockCubit>(blocContext),
        _tryGetBloc<InactivityCubit>(blocContext),
      ],
    ].whereNotNull().toList();

List<BlocProvider> copiedTopLevelProviders(BuildContext blocContext) => [
      _tryGetBloc<SpeechSettingsCubit>(blocContext),
      _tryGetBloc<StartupCubit>(blocContext),
      _tryGetBloc<ConnectivityCubit>(blocContext),
      if (Config.isMP) ...[
        _tryGetBloc<VoicesCubit>(blocContext),
      ],
    ].whereNotNull().toList();

final _copyBlocLog = Logger('CopiedProvider');

BlocProvider? _tryGetBloc<B extends BlocBase>(BuildContext context) {
  try {
    return BlocProvider<B>.value(value: context.read<B>());
  } catch (e) {
    _copyBlocLog.warning('Could not fetch provider of $B', e);
    return null;
  }
}
