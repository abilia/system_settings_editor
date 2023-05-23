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
  late MockLastSyncDb lastSyncDb;

  setUp(() {
    activityRepository = MockActivityRepository();
    userFileRepository = MockUserFileRepository();
    sortableRepository = MockSortableRepository();
    genericRepository = MockGenericRepository();
    lastSyncDb = MockLastSyncDb();
  });

  group('happy cases', () {
    setUp(() {
      when(() => activityRepository.synchronize())
          .thenAnswer((_) => Future.value(true));
      when(() => userFileRepository.synchronize())
          .thenAnswer((_) => Future.value(true));
      when(() => sortableRepository.synchronize())
          .thenAnswer((_) => Future.value(true));
      when(() => genericRepository.synchronize())
          .thenAnswer((_) => Future.value(true));
    });

    blocTest(
      'ActivitySaved event calls synchronize on activity repository',
      build: () => SyncBloc(
        pushCubit: FakePushCubit(),
        licenseCubit: FakeLicenseCubit(),
        activityRepository: activityRepository,
        userFileRepository: userFileRepository,
        sortableRepository: sortableRepository,
        genericRepository: genericRepository,
        lastSyncDb: lastSyncDb,
        clockBloc: ClockBloc.fixed(DateTime(2000)),
        syncDelay: SyncDelays.zero,
      ),
      act: (SyncBloc syncBloc) => syncBloc.add(const SyncActivities()),
      verify: (bloc) => verify(() => activityRepository.synchronize()),
    );

    blocTest(
      'FileSaved event calls synchronize on user file repository',
      build: () => SyncBloc(
        pushCubit: FakePushCubit(),
        licenseCubit: FakeLicenseCubit(),
        activityRepository: activityRepository,
        userFileRepository: userFileRepository,
        sortableRepository: sortableRepository,
        genericRepository: genericRepository,
        lastSyncDb: lastSyncDb,
        clockBloc: ClockBloc.fixed(DateTime(2000)),
        syncDelay: SyncDelays.zero,
      ),
      act: (SyncBloc syncBloc) => syncBloc.add(const SyncFiles()),
      verify: (bloc) => verify(() => userFileRepository.synchronize()),
    );

    blocTest(
      'SortableSaved event calls synchronize on sortable repository',
      build: () => SyncBloc(
        pushCubit: FakePushCubit(),
        licenseCubit: FakeLicenseCubit(),
        activityRepository: activityRepository,
        userFileRepository: userFileRepository,
        sortableRepository: sortableRepository,
        genericRepository: genericRepository,
        syncDelay: SyncDelays.zero,
        lastSyncDb: lastSyncDb,
        clockBloc: ClockBloc.fixed(DateTime(2000)),
      ),
      act: (SyncBloc syncBloc) => syncBloc.add(const SyncSortables()),
      verify: (bloc) => verify(() => sortableRepository.synchronize()),
    );

    blocTest(
      'GenericSaved event calls synchronize on sortable repository',
      build: () => SyncBloc(
        pushCubit: FakePushCubit(),
        licenseCubit: FakeLicenseCubit(),
        activityRepository: activityRepository,
        userFileRepository: userFileRepository,
        sortableRepository: sortableRepository,
        genericRepository: genericRepository,
        lastSyncDb: lastSyncDb,
        clockBloc: ClockBloc.fixed(DateTime(2000)),
        syncDelay: SyncDelays.zero,
      ),
      act: (SyncBloc syncBloc) => syncBloc.add(const SyncGenerics()),
      verify: (bloc) => verify(() => genericRepository.synchronize()),
    );

    blocTest('all event calls synchronize on all repository',
        wait: 1.milliseconds(),
        build: () => SyncBloc(
              pushCubit: FakePushCubit(),
              licenseCubit: FakeLicenseCubit(),
              activityRepository: activityRepository,
              userFileRepository: userFileRepository,
              sortableRepository: sortableRepository,
              genericRepository: genericRepository,
              lastSyncDb: lastSyncDb,
              clockBloc: ClockBloc.fixed(DateTime(2000)),
              syncDelay: SyncDelays.zero,
            ),
        act: (SyncBloc syncBloc) => syncBloc
          ..add(const SyncActivities())
          ..add(const SyncFiles())
          ..add(const SyncSortables())
          ..add(const SyncGenerics()),
        verify: (bloc) {
          verify(() => activityRepository.synchronize());
          verify(() => userFileRepository.synchronize());
          verify(() => sortableRepository.synchronize());
          verify(() => genericRepository.synchronize());
        });

    blocTest('last sync time is saved on sync',
        wait: 1.milliseconds(),
        build: () => SyncBloc(
              pushCubit: FakePushCubit(),
              licenseCubit: FakeLicenseCubit(),
              activityRepository: activityRepository,
              userFileRepository: userFileRepository,
              sortableRepository: sortableRepository,
              genericRepository: genericRepository,
              lastSyncDb: lastSyncDb,
              clockBloc: ClockBloc.fixed(DateTime(2000)),
              syncDelay: SyncDelays.zero,
            ),
        act: (SyncBloc syncBloc) => syncBloc..add(const SyncAll()),
        verify: (bloc) {
          verify(() => lastSyncDb.setSyncTime(DateTime(2000)));
        });
  });

  group('Failed cases', () {
    final retryDelay = 10.milliseconds();
    final betweenSync = 5.milliseconds();
    final syncDelays = SyncDelays(
      betweenSync: betweenSync,
      retryDelay: retryDelay,
    );
    late List<bool> responses;
    setUp(() {
      responses = [false, true];
    });

    Future<bool> failThenSucceed() {
      if (responses.length >= 2) {
        Future.value(responses.removeAt(0));
        throw SyncFailedException();
      }
      return Future.value(responses.removeAt(0));
    }

    blocTest<SyncBloc, dynamic>(
      'Failed ActivitySaved synchronize retrys to syncronize',
      setUp: () => when(() => activityRepository.synchronize())
          .thenAnswer((_) => failThenSucceed()),
      build: () => SyncBloc(
        pushCubit: FakePushCubit(),
        licenseCubit: FakeLicenseCubit(),
        activityRepository: activityRepository,
        userFileRepository: userFileRepository,
        sortableRepository: sortableRepository,
        genericRepository: genericRepository,
        lastSyncDb: FakeLastSyncDb(),
        clockBloc: ClockBloc.fixed(DateTime(2000)),
        syncDelay: syncDelays,
      ),
      act: (bloc) => bloc.add(const SyncActivities()),
      wait: retryDelay * 30,
      verify: (bloc) => verify(bloc.activityRepository.synchronize).called(2),
    );

    blocTest<SyncBloc, dynamic>(
      'Failed FileSaved synchronize retrys to syncronize',
      setUp: () => when(() => userFileRepository.synchronize())
          .thenAnswer((_) => failThenSucceed()),
      build: () => SyncBloc(
        pushCubit: FakePushCubit(),
        licenseCubit: FakeLicenseCubit(),
        activityRepository: activityRepository,
        userFileRepository: userFileRepository,
        sortableRepository: sortableRepository,
        genericRepository: genericRepository,
        lastSyncDb: FakeLastSyncDb(),
        clockBloc: ClockBloc.fixed(DateTime(2000)),
        syncDelay: syncDelays,
      ),
      act: (bloc) => bloc.add(const SyncFiles()),
      wait: retryDelay * 30,
      verify: (bloc) => verify(bloc.userFileRepository.synchronize).called(2),
    );

    blocTest<SyncBloc, dynamic>(
      'Failed SortableSaved synchronize retrys to syncronize',
      setUp: () => when(() => sortableRepository.synchronize())
          .thenAnswer((_) => failThenSucceed()),
      build: () => SyncBloc(
        pushCubit: FakePushCubit(),
        licenseCubit: FakeLicenseCubit(),
        activityRepository: activityRepository,
        userFileRepository: userFileRepository,
        sortableRepository: sortableRepository,
        genericRepository: genericRepository,
        lastSyncDb: FakeLastSyncDb(),
        clockBloc: ClockBloc.fixed(DateTime(2000)),
        syncDelay: syncDelays,
      ),
      act: (bloc) => bloc.add(const SyncSortables()),
      wait: retryDelay * 30,
      verify: (bloc) => verify(bloc.sortableRepository.synchronize).called(2),
    );

    blocTest<SyncBloc, dynamic>(
      'Failed GenericSaved synchronize retrys to syncronize',
      setUp: () => when(() => genericRepository.synchronize())
          .thenAnswer((_) => failThenSucceed()),
      build: () => SyncBloc(
        pushCubit: FakePushCubit(),
        licenseCubit: FakeLicenseCubit(),
        activityRepository: activityRepository,
        userFileRepository: userFileRepository,
        sortableRepository: sortableRepository,
        genericRepository: genericRepository,
        lastSyncDb: FakeLastSyncDb(),
        clockBloc: ClockBloc.fixed(DateTime(2000)),
        syncDelay: syncDelays,
      ),
      act: (bloc) => bloc.add(const SyncGenerics()),
      wait: retryDelay * 30,
      verify: (bloc) => verify(bloc.genericRepository.synchronize).called(2),
    );
  });

  group('queuing', () {
    final stallTime = 50.milliseconds();

    setUp(() {
      when(() => activityRepository.synchronize())
          .thenAnswer((_) => Future.value(true));
      when(() => userFileRepository.synchronize())
          .thenAnswer((_) => Future.value(true));
      when(() => sortableRepository.synchronize())
          .thenAnswer((_) => Future.value(true));
      when(() => genericRepository.synchronize())
          .thenAnswer((_) => Future.value(true));
    });

    test('calls all repositories', () async {
      SyncBloc(
        pushCubit: FakePushCubit(),
        licenseCubit: FakeLicenseCubit(),
        activityRepository: activityRepository,
        userFileRepository: userFileRepository,
        sortableRepository: sortableRepository,
        genericRepository: genericRepository,
        lastSyncDb: FakeLastSyncDb(),
        clockBloc: ClockBloc.fixed(DateTime(2000)),
        syncDelay: SyncDelays(
          betweenSync: stallTime,
          retryDelay: stallTime,
        ),
      )
        ..add(const SyncActivities())
        ..add(const SyncFiles())
        ..add(const SyncSortables())
        ..add(const SyncGenerics());
      await untilCalled(() => activityRepository.synchronize());
      await untilCalled(() => userFileRepository.synchronize());
      await untilCalled(() => sortableRepository.synchronize());
      await untilCalled(() => genericRepository.synchronize());
    });

    test('throttles invocations of event', () async {
      final syncBloc = SyncBloc(
        pushCubit: FakePushCubit(),
        licenseCubit: FakeLicenseCubit(),
        activityRepository: activityRepository,
        userFileRepository: userFileRepository,
        sortableRepository: sortableRepository,
        genericRepository: genericRepository,
        lastSyncDb: FakeLastSyncDb(),
        clockBloc: ClockBloc.fixed(DateTime(2000)),
        syncDelay: SyncDelays(
          betweenSync: stallTime,
          retryDelay: stallTime,
        ),
      )..add(const SyncActivities());
      await untilCalled(() => activityRepository.synchronize());
      syncBloc
        ..add(const SyncActivities())
        ..add(const SyncActivities())
        ..add(const SyncActivities())
        ..add(const SyncActivities())
        ..add(const SyncFiles())
        ..add(const SyncFiles())
        ..add(const SyncFiles())
        ..add(const SyncFiles())
        ..add(const SyncSortables())
        ..add(const SyncSortables())
        ..add(const SyncSortables())
        ..add(const SyncSortables());
      await Future.delayed(stallTime * 2);
      await untilCalled(() => userFileRepository.synchronize());
      await Future.delayed(stallTime * 2);
      await untilCalled(() => sortableRepository.synchronize());
      await Future.delayed(stallTime * 2);
      verify(() => activityRepository.synchronize()).called(2);
      verify(() => userFileRepository.synchronize()).called(1);
      verify(() => sortableRepository.synchronize()).called(1);
    });

    test(
        'Failed syncs with other events in queue should dequeue other events before retrying (no starvation)',
        () async {
      when(() => activityRepository.synchronize())
          .thenThrow((_) => SyncFailedException());
      final syncBloc = SyncBloc(
        pushCubit: FakePushCubit(),
        licenseCubit: FakeLicenseCubit(),
        activityRepository: activityRepository,
        userFileRepository: userFileRepository,
        sortableRepository: sortableRepository,
        genericRepository: genericRepository,
        lastSyncDb: FakeLastSyncDb(),
        clockBloc: ClockBloc.fixed(DateTime(2000)),
        syncDelay: SyncDelays(
          betweenSync: stallTime,
          retryDelay: stallTime,
        ),
      )..add(const SyncActivities());
      await untilCalled(() => activityRepository.synchronize());
      syncBloc
        ..add(const SyncActivities())
        ..add(const SyncActivities())
        ..add(const SyncActivities())
        ..add(const SyncActivities())
        ..add(const SyncFiles())
        ..add(const SyncFiles())
        ..add(const SyncFiles())
        ..add(const SyncFiles())
        ..add(const SyncSortables())
        ..add(const SyncSortables())
        ..add(const SyncSortables())
        ..add(const SyncSortables());
      await untilCalled(() => userFileRepository.synchronize());
      await untilCalled(() => sortableRepository.synchronize());
    });
  });
}
