import 'package:bloc_test/bloc_test.dart';
import 'package:seagull/bloc/all.dart';
export 'package:mocktail/mocktail.dart';

// Blocs
class MockActivitiesBloc extends MockBloc<ActivitiesEvent, ActivitiesState>
    implements ActivitiesBloc {}

class MockActivitiesOccasionCubit extends MockCubit<ActivitiesOccasionState>
    implements ActivitiesOccasionCubit {}

class MockSyncBloc extends MockBloc<SyncEvent, SyncState> implements SyncBloc {}

class MockPushBloc extends MockBloc<PushEvent, PushState> implements PushBloc {}

class MockGenericBloc extends MockBloc<GenericEvent, GenericState>
    implements GenericBloc {}

class MockSortableBloc extends MockBloc<SortableEvent, SortableState>
    implements SortableBloc {}

class MockMemoplannerSettingBloc
    extends MockBloc<MemoplannerSettingsEvent, MemoplannerSettingsState>
    implements MemoplannerSettingBloc {}

class MocktimepillarCubit extends MockCubit<TimepillarState>
    implements TimepillarCubit {}

class MockUserFileBloc extends MockBloc<UserFileEvent, UserFileState>
    implements UserFileBloc {}

class MockWakeLockCubit extends MockCubit<WakeLockState>
    implements WakeLockCubit {}
