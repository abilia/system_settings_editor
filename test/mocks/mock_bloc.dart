import 'package:bloc_test/bloc_test.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/bloc/settings/screen_timeout/wake_lock_cubit.dart';

// Blocs
class MockActivitiesBloc extends MockBloc<ActivitiesEvent, ActivitiesState>
    implements ActivitiesBloc {}

class MockActivitiesOccasionBloc
    extends MockBloc<ActivitiesOccasionEvent, ActivitiesOccasionState>
    implements ActivitiesOccasionBloc {}

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
