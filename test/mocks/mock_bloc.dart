import 'package:bloc_test/bloc_test.dart';
import 'package:seagull/bloc/all.dart';

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

class MockTimepillarBloc extends MockBloc<TimepillarEvent, TimepillarState>
    implements TimepillarBloc {}

class MockUserFileBloc extends MockBloc<UserFileEvent, UserFileState>
    implements UserFileBloc {}

class MockBatteryCubit extends MockCubit<BatteryCubitState>
    implements BatteryCubit {}
