import 'dart:async';
import 'package:bloc_test/bloc_test.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memoplanner/bloc/all.dart';
import 'package:memoplanner/models/all.dart';
import 'package:memoplanner/repository/all.dart';
import '../../fakes/all.dart';
import '../../mocks/mocks.dart';

void main() {
  late ActivityRepository activityRepository;
  late UserFileRepository userFileRepository;
  late SortableRepository sortableRepository;
  late GenericRepository genericRepository;
  late MockActivityDb activityDb;
  late MockSortableDb sortableDb;
  late MockUserFileDb userFileDb;
  late MockGenericDb genericDb;
  late MockLastSyncDb lastSyncDb;
  late SyncBloc syncBloc;
  late StreamController<ConnectivityResult> connectivityStream;

  const noDirtyItems = DirtyItems(
    activities: 0,
    activityTemplates: 0,
    timerTemplate: 0,
    photos: 0,
    settingsData: false,
  );

  setUp(() {
    activityRepository = MockActivityRepository();
    userFileRepository = MockUserFileRepository();
    sortableRepository = MockSortableRepository();
    genericRepository = MockGenericRepository();
    activityDb = MockActivityDb();
    lastSyncDb = MockLastSyncDb();
    sortableDb = MockSortableDb();
    userFileDb = MockUserFileDb();
    genericDb = MockGenericDb();
    syncBloc = SyncBloc(
      pushCubit: FakePushCubit(),
      licenseCubit: FakeLicenseCubit(),
      activityRepository: activityRepository,
      userFileRepository: userFileRepository,
      sortableRepository: sortableRepository,
      genericRepository: genericRepository,
      lastSyncDb: lastSyncDb,
      clockBloc: ClockBloc.fixed(DateTime(2000)),
      syncDelay: SyncDelays.zero,
    );
    connectivityStream = StreamController<ConnectivityResult>();

    when(() => activityRepository.synchronize())
        .thenAnswer((_) => Future.value(true));
    when(() => userFileRepository.synchronize())
        .thenAnswer((_) => Future.value(true));
    when(() => sortableRepository.synchronize())
        .thenAnswer((_) => Future.value(true));
    when(() => genericRepository.synchronize())
        .thenAnswer((_) => Future.value(true));

    when(() => activityRepository.db).thenReturn(activityDb);
    when(() => userFileRepository.db).thenReturn(userFileDb);
    when(() => sortableRepository.db).thenReturn(sortableDb);
    when(() => genericRepository.db).thenReturn(genericDb);
  });

  tearDown(() {
    connectivityStream.close();
  });

  setUp(() {
    when(() => activityDb.getAllDirty()).thenAnswer((_) => Future.value([]));
    when(() => userFileDb.getAllDirty()).thenAnswer((_) => Future.value([]));
    when(() => sortableDb.getAllDirty()).thenAnswer((_) => Future.value([]));
    when(() => genericDb.getAllDirty()).thenAnswer((_) => Future.value([]));
    when(() => activityDb.countAllDirty()).thenAnswer((_) => Future.value(0));
    when(() => userFileDb.countAllDirty()).thenAnswer((_) => Future.value(0));
    when(() => sortableDb.countAllDirty()).thenAnswer((_) => Future.value(0));
    when(() => genericDb.countAllDirty()).thenAnswer((_) => Future.value(0));
  });

  group('No dirty items', () {
    test('initial state is first warning and sync failed', () {
      final logoutSyncCubit = LogoutSyncCubit(
        syncBloc: syncBloc,
        connectivity: connectivityStream.stream,
      );

      expect(
        logoutSyncCubit.state,
        const LogoutSyncState(
          warningSyncState: WarningSyncState.syncFailed,
          warningStep: WarningStep.firstWarning,
        ),
      );
    });

    blocTest(
      'can change to second warning step',
      build: () => LogoutSyncCubit(
        syncBloc: syncBloc,
        connectivity: connectivityStream.stream,
      ),
      act: (LogoutSyncCubit cubit) =>
          cubit.setWarningStep(WarningStep.secondWarning),
      expect: () => [
        const LogoutSyncState(
          warningSyncState: WarningSyncState.syncFailed,
          warningStep: WarningStep.secondWarning,
        ),
        const LogoutSyncState(
          warningSyncState: WarningSyncState.syncFailed,
          warningStep: WarningStep.secondWarning,
          dirtyItems: noDirtyItems,
        ),
      ],
    );

    test('when Connectivity changes to anything other than none, emits syncing',
        () async {
      Future<void> testConnectivityChange(ConnectivityResult cr) async {
        final crStream = StreamController<ConnectivityResult>();
        final logoutSyncCubit = LogoutSyncCubit(
          syncBloc: syncBloc,
          connectivity: crStream.stream,
        );

        crStream.add(cr);

        expectLater(
          logoutSyncCubit.stream,
          emitsAnyOf(
            [
              const LogoutSyncState(
                warningSyncState: WarningSyncState.syncing,
                warningStep: WarningStep.firstWarning,
              ),
              const LogoutSyncState(
                dirtyItems: noDirtyItems,
                warningSyncState: WarningSyncState.syncing,
                warningStep: WarningStep.firstWarning,
              ),
            ],
          ),
        );

        crStream.close();
      }

      for (var cr in ConnectivityResult.values) {
        if (cr != ConnectivityResult.none) {
          await testConnectivityChange(cr);
        }
      }
    });

    test('Connectivity changes to none does not emit syncing', () async {
      final logoutSyncCubit = LogoutSyncCubit(
        syncBloc: syncBloc,
        connectivity: connectivityStream.stream,
      );

      connectivityStream.add(ConnectivityResult.none);

      final expect = expectLater(
        logoutSyncCubit.stream,
        neverEmits(
          [
            const LogoutSyncState(
              warningSyncState: WarningSyncState.syncing,
              warningStep: WarningStep.firstWarning,
            ),
            const LogoutSyncState(
              dirtyItems: noDirtyItems,
              warningSyncState: WarningSyncState.syncing,
              warningStep: WarningStep.firstWarning,
            ),
          ],
        ),
      );

      logoutSyncCubit.close();
      await expect;
    });
  });

  group('Dirty items', () {
    test('correct number of dirty activities', () async {
      when(() => activityDb.countAllDirty()).thenAnswer((_) => Future.value(3));

      final logoutSyncCubit = LogoutSyncCubit(
        syncBloc: syncBloc,
        connectivity: connectivityStream.stream,
      );

      expectLater(
        logoutSyncCubit.stream,
        emits(
          LogoutSyncState(
            warningSyncState: WarningSyncState.syncFailed,
            warningStep: WarningStep.firstWarning,
            dirtyItems: noDirtyItems.copyWith(activities: 3),
          ),
        ),
      );
    });

    test('correct number of dirty activity templates', () async {
      final basicActivity = Sortable.createNew(
              data: BasicActivityDataItem.createNew(title: 'dirty'))
          .wrapWithDbModel() as DbModel<Sortable<SortableData>>;

      when(() => sortableDb.getAllDirty()).thenAnswer((_) => Future.value(
          [basicActivity, basicActivity, basicActivity, basicActivity]));

      final logoutSyncCubit = LogoutSyncCubit(
        syncBloc: syncBloc,
        connectivity: connectivityStream.stream,
      );

      expectLater(
        logoutSyncCubit.stream,
        emits(
          LogoutSyncState(
            warningSyncState: WarningSyncState.syncFailed,
            warningStep: WarningStep.firstWarning,
            dirtyItems: noDirtyItems.copyWith(activityTemplates: 4),
          ),
        ),
      );
    });

    test('correct number of dirty timer templates', () async {
      final basicTimer =
          Sortable.createNew(data: BasicTimerDataItem.createNew())
              .wrapWithDbModel() as DbModel<Sortable<SortableData>>;

      when(() => sortableDb.getAllDirty()).thenAnswer((_) => Future.value(
          [basicTimer, basicTimer, basicTimer, basicTimer, basicTimer]));

      final logoutSyncCubit = LogoutSyncCubit(
        syncBloc: syncBloc,
        connectivity: connectivityStream.stream,
      );

      expectLater(
        logoutSyncCubit.stream,
        emits(
          LogoutSyncState(
            warningSyncState: WarningSyncState.syncFailed,
            warningStep: WarningStep.firstWarning,
            dirtyItems: noDirtyItems.copyWith(timerTemplate: 5),
          ),
        ),
      );
    });

    test('correct number of dirty photos', () async {
      final photo = UserFile(
              id: 'id',
              sha1: 'sha1',
              md5: 'md5',
              path: 'path.${UserFile.imageEndings.first}',
              fileSize: 1,
              deleted: false,
              fileLoaded: true)
          .wrapWithDbModel();

      when(() => userFileDb.getAllDirty()).thenAnswer(
          (_) => Future.value([photo, photo, photo, photo, photo, photo]));

      final logoutSyncCubit = LogoutSyncCubit(
        syncBloc: syncBloc,
        connectivity: connectivityStream.stream,
      );

      expectLater(
        logoutSyncCubit.stream,
        emits(
          LogoutSyncState(
            warningSyncState: WarningSyncState.syncFailed,
            warningStep: WarningStep.firstWarning,
            dirtyItems: noDirtyItems.copyWith(photos: 6),
          ),
        ),
      );
    });

    test('correct value for settingsData', () async {
      when(() => genericDb.countAllDirty()).thenAnswer((_) => Future.value(1));

      final logoutSyncCubit = LogoutSyncCubit(
        syncBloc: syncBloc,
        connectivity: connectivityStream.stream,
      );

      expectLater(
        logoutSyncCubit.stream,
        emits(
          LogoutSyncState(
            warningSyncState: WarningSyncState.syncFailed,
            warningStep: WarningStep.firstWarning,
            dirtyItems: noDirtyItems.copyWith(settingsData: true),
          ),
        ),
      );
    });
  });
}
