import 'package:flutter/widgets.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/repository/all.dart';

import 'fake_db_and_repository.dart';
import 'fakes_blocs.dart';

class FakeAuthenticatedBlocsProvider extends StatelessWidget {
  final Widget child;

  const FakeAuthenticatedBlocsProvider({Key? key, required this.child})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return RepositoryProvider<UserRepository>(
      create: (context) => FakeUserRepository(),
      child: MultiBlocProvider(providers: [
        BlocProvider<AuthenticationBloc>(
            create: (context) => FakeAuthenticationBloc()),
        BlocProvider<ActivitiesBloc>(create: (context) => FakeActivitiesBloc()),
        BlocProvider<SettingsCubit>(create: (context) => FakeSettingsBloc()),
        BlocProvider<PermissionCubit>(create: (context) => PermissionCubit()),
        BlocProvider<SyncBloc>(create: (context) => FakeSyncBloc()),
        BlocProvider<UserFileCubit>(create: (context) => FakeUserFileCubit()),
        BlocProvider<SortableBloc>(create: (context) => FakeSortableBloc()),
        BlocProvider<GenericCubit>(create: (context) => FakeGenericCubit()),
        BlocProvider<MemoplannerSettingBloc>(
            create: (context) => FakeMemoplannerSettingsBloc()),
        BlocProvider<DayPickerBloc>(create: (context) => FakeDayPickerBloc()),
        BlocProvider<DayEventsCubit>(create: (context) => FakeDayEventsCubit()),
        BlocProvider<AlarmCubit>(create: (context) => FakeAlarmCubit()),
        BlocProvider<CalendarViewCubit>(
            create: (context) => FakeCalendarViewBloc()),
        BlocProvider<LicenseCubit>(create: (context) => FakeLicenseCubit()),
      ], child: child),
    );
  }
}
