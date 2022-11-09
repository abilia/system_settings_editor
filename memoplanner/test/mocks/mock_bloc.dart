import 'package:bloc_test/bloc_test.dart';
import 'package:memoplanner/bloc/all.dart';
import 'package:memoplanner/models/all.dart';
export 'package:mocktail/mocktail.dart';

// Blocs
class MockActivitiesBloc extends MockBloc<ActivitiesEvent, ActivitiesChanged>
    implements ActivitiesBloc {}

class MockDayEventsCubit extends MockCubit<EventsState>
    implements DayEventsCubit {}

class MockSyncBloc extends MockBloc<SyncEvent, SyncState> implements SyncBloc {}

class MockPushCubit extends MockCubit<RemoteMessage> implements PushCubit {}

class MockGenericCubit extends MockCubit<GenericState> implements GenericCubit {
}

class MockSortableBloc extends MockBloc<SortableEvent, SortableState>
    implements SortableBloc {}

class MockMemoplannerSettingBloc
    extends MockBloc<MemoplannerSettingsEvent, MemoplannerSettings>
    implements MemoplannerSettingsBloc {}

class MockTimepillarCubit extends MockCubit<TimepillarState>
    implements TimepillarCubit {}

class MockNotificationBloc extends MockCubit<String>
    implements NotificationBloc {}

class MockTimepillarMeasuresCubit extends MockCubit<TimepillarMeasures>
    implements TimepillarMeasuresCubit {}

class MockUserFileCubit extends MockCubit<UserFileState>
    implements UserFileCubit {}

class MockWakeLockCubit extends MockCubit<WakeLockState>
    implements WakeLockCubit {}

class MockTimerCubit extends MockCubit<TimerState> implements TimerCubit {}

class MockTimerAlarmBloc extends MockBloc<TimerAlarmEvent, TimerAlarmState>
    implements TimerAlarmBloc {}

class MockRecordSoundCubit extends MockCubit<RecordSoundState>
    implements RecordSoundCubit {}

class MockSoundBloc extends MockBloc<SoundEvent, SoundState>
    implements SoundBloc {}

class MockLicenseCubit extends MockCubit<LicenseState> implements LicenseCubit {
}
