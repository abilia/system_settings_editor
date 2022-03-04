import 'package:bloc_test/bloc_test.dart';
import 'package:seagull/bloc/all.dart';
export 'package:mocktail/mocktail.dart';

// Blocs
class MockActivitiesBloc extends MockBloc<ActivitiesEvent, ActivitiesState>
    implements ActivitiesBloc {}

class MockDayEventsCubit extends MockCubit<EventsState>
    implements DayEventsCubit {}

class MockSyncBloc extends MockBloc<SyncEvent, dynamic> implements SyncBloc {}

class MockPushCubit extends MockCubit<PushState> implements PushCubit {}

class MockGenericCubit extends MockCubit<GenericState> implements GenericCubit {
}

class MockSortableCubit extends MockBloc<SortableEvent, SortableState>
    implements SortableBloc {}

class MockMemoplannerSettingBloc
    extends MockBloc<MemoplannerSettingsEvent, MemoplannerSettingsState>
    implements MemoplannerSettingBloc {}

class MocktimepillarCubit extends MockCubit<TimepillarState>
    implements TimepillarCubit {}

class MockUserFileCubit extends MockCubit<UserFileState>
    implements UserFileCubit {}

class MockWakeLockCubit extends MockCubit<WakeLockState>
    implements WakeLockCubit {}

class MockTimerCubit extends MockCubit<TimerState> implements TimerCubit {}

class MockTimerAlarmBloc extends MockBloc<TimerAlarmEvent, TimerAlarmState>
    implements TimerAlarmBloc {}

class MockRecordSoundCubit extends MockCubit<RecordSoundState>
    implements RecordSoundCubit {}

class MockSoundCubit extends MockCubit<SoundState> implements SoundCubit {}
