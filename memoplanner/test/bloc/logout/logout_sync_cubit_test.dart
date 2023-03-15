import 'dart:async';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memoplanner/bloc/all.dart';
import 'package:memoplanner/models/all.dart';
import 'package:memoplanner/repository/all.dart';
import 'package:memoplanner/utils/all.dart';
import 'package:seagull_fakes/all.dart';
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
  late LicenseCubit licenseCubit;
  final mockAuthenticationBloc = MockAuthenticationBloc();
  late MyAbiliaConnection myAbiliaConnection;
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
    licenseCubit = MockLicenseCubit();
    myAbiliaConnection = MockMyAbiliaConnection();
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

    when(() => activityDb.getAllDirty()).thenAnswer((_) => Future.value([]));
    when(() => userFileDb.getAllDirty()).thenAnswer((_) => Future.value([]));
    when(() => sortableDb.getAllDirty()).thenAnswer((_) => Future.value([]));
    when(() => genericDb.getAllDirty()).thenAnswer((_) => Future.value([]));

    when(() => activityDb.countAllDirty()).thenAnswer((_) => Future.value(0));
    when(() => userFileDb.countAllDirty()).thenAnswer((_) => Future.value(0));
    when(() => sortableDb.countAllDirty()).thenAnswer((_) => Future.value(0));
    when(() => genericDb.countAllDirty()).thenAnswer((_) => Future.value(0));

    when(() => licenseCubit.validLicense).thenReturn(true);
    when(() => licenseCubit.reloadLicenses()).thenAnswer((_) => Future.value());
    when(() => myAbiliaConnection.hasConnection())
        .thenAnswer((_) => Future.value(false));
  });

  tearDown(() {
    connectivityStream.close();
  });

  group('Steps', () {
    test('initial state is first warning and sync failed', () {
      final logoutSyncCubit = LogoutSyncCubit(
        authenticationBloc: mockAuthenticationBloc,
        myAbiliaConnection: myAbiliaConnection,
        licenseCubit: licenseCubit,
        syncBloc: syncBloc,
        syncDelay: SyncDelays.zero,
        connectivity: connectivityStream.stream,
      );

      expect(
        logoutSyncCubit.state,
        const LogoutSyncState(
          logoutWarning: LogoutWarning.firstWarningSyncFailed,
        ),
      );
    });

    blocTest(
      'can go to second warning step',
      setUp: () {
        when(() => activityDb.countAllDirty())
            .thenAnswer((_) => Future.value(1));
      },
      build: () => LogoutSyncCubit(
        authenticationBloc: mockAuthenticationBloc,
        myAbiliaConnection: myAbiliaConnection,
        licenseCubit: licenseCubit,
        syncBloc: syncBloc,
        syncDelay: SyncDelays.zero,
        connectivity: connectivityStream.stream,
      ),
      act: (LogoutSyncCubit cubit) => cubit.next(),
      expect: () => [
        const LogoutSyncState(
          logoutWarning: LogoutWarning.firstWarningSyncFailed,
        ),
        const LogoutSyncState(
          logoutWarning: LogoutWarning.secondWarningSyncFailed,
        ),
        LogoutSyncState(
          logoutWarning: LogoutWarning.secondWarningSyncFailed,
          dirtyItems: noDirtyItems.copyWith(activities: 1),
        ),
      ],
    );

    blocTest(
      'can go to invalid license warning',
      setUp: () {
        when(() => activityDb.countAllDirty())
            .thenAnswer((_) => Future.value(1));
        when(() => licenseCubit.validLicense).thenReturn(false);
        when(() => myAbiliaConnection.hasConnection())
            .thenAnswer((_) => Future.value(true));
      },
      build: () {
        return LogoutSyncCubit(
          authenticationBloc: mockAuthenticationBloc,
          myAbiliaConnection: myAbiliaConnection,
          licenseCubit: licenseCubit,
          syncBloc: syncBloc,
          syncDelay: SyncDelays.zero,
          connectivity: connectivityStream.stream,
        );
      },
      act: (LogoutSyncCubit cubit) => cubit
        ..next()
        ..next(),
      expect: () => [
        const LogoutSyncState(
          logoutWarning: LogoutWarning.firstWarningSyncFailed,
          isOnline: false,
        ),
        const LogoutSyncState(
          logoutWarning: LogoutWarning.firstWarningSyncFailed,
          isOnline: true,
        ),
        const LogoutSyncState(
          logoutWarning: LogoutWarning.licenseExpiredWarning,
          isOnline: true,
        ),
        LogoutSyncState(
          logoutWarning: LogoutWarning.licenseExpiredWarning,
          dirtyItems: noDirtyItems.copyWith(activities: 1),
          isOnline: true,
        ),
      ],
      tearDown: () {
        reset(licenseCubit);
        reset(myAbiliaConnection);
      },
    );
  });

  group('Connectivity', () {
    test(
        'when Connectivity changes to anything other than none, emits syncing if has myAbilia connection',
        () async {
      when(() => myAbiliaConnection.hasConnection())
          .thenAnswer((_) => Future.value(true));
      when(() => activityDb.countAllDirty()).thenAnswer((_) => Future.value(1));

      Future<void> testConnectivityChange(ConnectivityResult cr) async {
        final crStream = StreamController<ConnectivityResult>();
        final logoutSyncCubit = LogoutSyncCubit(
          authenticationBloc: mockAuthenticationBloc,
          myAbiliaConnection: myAbiliaConnection,
          licenseCubit: licenseCubit,
          syncBloc: syncBloc,
          syncDelay: SyncDelays.zero,
          connectivity: crStream.stream,
        );

        crStream.add(cr);

        await expectLater(
          logoutSyncCubit.stream,
          emitsThrough(
            predicate<LogoutSyncState>(
              (state) =>
                  state.logoutWarning == LogoutWarning.firstWarningSyncing,
            ),
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

    test(
        'when Connectivity changes to anything other than none, does not emit syncing if do not have myAbilia connection',
        () async {
      when(() => myAbiliaConnection.hasConnection())
          .thenAnswer((_) => Future.value(false));
      when(() => activityDb.countAllDirty()).thenAnswer((_) => Future.value(1));

      Future<void> testConnectivityChange(
        ConnectivityResult cr,
        LogoutSyncCubit cubit,
        StreamController<ConnectivityResult> streamController,
      ) async {
        streamController.add(cr);

        expectLater(
          cubit.stream,
          neverEmits(
            [
              const LogoutSyncState(
                logoutWarning: LogoutWarning.firstWarningSyncing,
                isOnline: false,
              ),
              const LogoutSyncState(
                dirtyItems: noDirtyItems,
                logoutWarning: LogoutWarning.firstWarningSyncing,
                isOnline: false,
              ),
            ],
          ),
        );

        streamController.close();
      }

      for (var cr in ConnectivityResult.values) {
        if (cr != ConnectivityResult.none) {
          final crStream = StreamController<ConnectivityResult>();

          final logoutSyncCubit = LogoutSyncCubit(
            authenticationBloc: mockAuthenticationBloc,
            myAbiliaConnection: myAbiliaConnection,
            licenseCubit: licenseCubit,
            syncBloc: syncBloc,
            syncDelay: SyncDelays.zero,
            connectivity: crStream.stream,
          );

          logoutSyncCubit.close();
          await testConnectivityChange(cr, logoutSyncCubit, crStream);
        }
      }
    });

    test('Connectivity changes to none does not emit syncing', () async {
      when(() => activityDb.countAllDirty()).thenAnswer((_) => Future.value(1));
      final logoutSyncCubit = LogoutSyncCubit(
        authenticationBloc: mockAuthenticationBloc,
        myAbiliaConnection: myAbiliaConnection,
        licenseCubit: licenseCubit,
        syncBloc: syncBloc,
        syncDelay: SyncDelays.zero,
        connectivity: connectivityStream.stream,
      );

      connectivityStream.add(ConnectivityResult.none);

      final expect = expectLater(
        logoutSyncCubit.stream,
        neverEmits([
          const LogoutSyncState(
            logoutWarning: LogoutWarning.firstWarningSyncing,
          ),
          const LogoutSyncState(
            dirtyItems: noDirtyItems,
            logoutWarning: LogoutWarning.firstWarningSyncing,
          ),
        ]),
      );

      logoutSyncCubit.close();
      await expect;
    });
  });

  group('Dirty items', () {
    setUp(() {
      when(() => myAbiliaConnection.hasConnection())
          .thenAnswer((_) => Future.value(false));
    });

    test('correct number of dirty activities', () async {
      when(() => activityDb.countAllDirty()).thenAnswer((_) => Future.value(3));

      final logoutSyncCubit = LogoutSyncCubit(
        authenticationBloc: mockAuthenticationBloc,
        myAbiliaConnection: myAbiliaConnection,
        licenseCubit: licenseCubit,
        syncBloc: syncBloc,
        syncDelay: SyncDelays.zero,
        connectivity: connectivityStream.stream,
      );

      await expectLater(
        logoutSyncCubit.stream,
        emitsThrough(
          LogoutSyncState(
            logoutWarning: LogoutWarning.firstWarningSyncFailed,
            dirtyItems: noDirtyItems.copyWith(activities: 3),
            isOnline: false,
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
      when(() => sortableDb.countAllDirty()).thenAnswer((_) => Future.value(4));

      final logoutSyncCubit = LogoutSyncCubit(
        authenticationBloc: mockAuthenticationBloc,
        myAbiliaConnection: myAbiliaConnection,
        licenseCubit: licenseCubit,
        syncBloc: syncBloc,
        syncDelay: SyncDelays.zero,
        connectivity: connectivityStream.stream,
      );

      await expectLater(
        logoutSyncCubit.stream,
        emitsThrough(
          LogoutSyncState(
            logoutWarning: LogoutWarning.firstWarningSyncFailed,
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
      when(() => sortableDb.countAllDirty()).thenAnswer((_) => Future.value(5));

      final logoutSyncCubit = LogoutSyncCubit(
        authenticationBloc: mockAuthenticationBloc,
        myAbiliaConnection: myAbiliaConnection,
        licenseCubit: licenseCubit,
        syncBloc: syncBloc,
        syncDelay: SyncDelays.zero,
        connectivity: connectivityStream.stream,
      );

      expectLater(
        logoutSyncCubit.stream,
        emitsThrough(
          LogoutSyncState(
            logoutWarning: LogoutWarning.firstWarningSyncFailed,
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
      when(() => userFileDb.countAllDirty()).thenAnswer((_) => Future.value(6));

      final logoutSyncCubit = LogoutSyncCubit(
        authenticationBloc: mockAuthenticationBloc,
        myAbiliaConnection: myAbiliaConnection,
        licenseCubit: licenseCubit,
        syncBloc: syncBloc,
        syncDelay: SyncDelays.zero,
        connectivity: connectivityStream.stream,
      );

      expectLater(
        logoutSyncCubit.stream,
        emitsThrough(
          LogoutSyncState(
            logoutWarning: LogoutWarning.firstWarningSyncFailed,
            dirtyItems: noDirtyItems.copyWith(photos: 6),
          ),
        ),
      );
    });

    test('correct value for settingsData', () async {
      when(() => genericDb.countAllDirty()).thenAnswer((_) => Future.value(1));

      final logoutSyncCubit = LogoutSyncCubit(
        authenticationBloc: mockAuthenticationBloc,
        myAbiliaConnection: myAbiliaConnection,
        licenseCubit: licenseCubit,
        syncBloc: syncBloc,
        syncDelay: SyncDelays.zero,
        connectivity: connectivityStream.stream,
      );

      expectLater(
        logoutSyncCubit.stream,
        emitsThrough(
          LogoutSyncState(
            logoutWarning: LogoutWarning.firstWarningSyncFailed,
            dirtyItems: noDirtyItems.copyWith(settingsData: true),
          ),
        ),
      );
    });
  });

  group('License validation', () {
    test('Calls reloadLicenses when coming online and having invalid license',
        () async {
      when(() => genericDb.countAllDirty()).thenAnswer((_) => Future.value(1));
      when(() => myAbiliaConnection.hasConnection())
          .thenAnswer((_) => Future.value(true));
      when(() => licenseCubit.validLicense).thenReturn(false);
      when(() => licenseCubit.reloadLicenses()).thenAnswer((_) async {});

      final _ = LogoutSyncCubit(
        authenticationBloc: mockAuthenticationBloc,
        myAbiliaConnection: myAbiliaConnection,
        licenseCubit: licenseCubit,
        syncBloc: syncBloc,
        syncDelay: SyncDelays.zero,
        connectivity: connectivityStream.stream,
      );

      connectivityStream.add(ConnectivityResult.wifi);

      await untilCalled(() => licenseCubit.reloadLicenses());
    });

    test(
        'Does not call reloadLicenses when coming online and having valid license',
        () async {
      when(() => genericDb.countAllDirty()).thenAnswer((_) => Future.value(1));
      when(() => myAbiliaConnection.hasConnection())
          .thenAnswer((_) => Future.value(true));
      when(() => licenseCubit.validLicense).thenReturn(true);
      when(() => licenseCubit.reloadLicenses()).thenAnswer((_) async {});

      final logoutSyncCubit = LogoutSyncCubit(
        authenticationBloc: mockAuthenticationBloc,
        myAbiliaConnection: myAbiliaConnection,
        licenseCubit: licenseCubit,
        syncBloc: syncBloc,
        syncDelay: SyncDelays.zero,
        connectivity: connectivityStream.stream,
      );

      connectivityStream.add(ConnectivityResult.wifi);

      await expectLater(
        logoutSyncCubit.stream,
        emitsThrough(
          predicate<LogoutSyncState>(
            (state) => state.logoutWarning == LogoutWarning.firstWarningSyncing,
          ),
        ),
      );

      logoutSyncCubit.close();

      verifyNever(() => licenseCubit.reloadLicenses());
    });
  });
}
