import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:seagull/bloc/all.dart';

import 'package:seagull/models/all.dart';
import 'package:seagull/repository/all.dart';
import 'package:seagull/utils/all.dart';

import '../../mocks/mocks.dart';

void main() {
  late ActivityRepository activityRepository;
  late UserFileRepository userFileRepository;
  late SortableRepository sortableRepository;
  late GenericRepository genericRepository;

  setUp(() {
    activityRepository = MockActivityRepository();
    userFileRepository = MockUserFileRepository();
    sortableRepository = MockSortableRepository();
    genericRepository = MockGenericRepository();
  });
  group('happy caseas', () {
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
        activityRepository: activityRepository,
        userFileRepository: userFileRepository,
        sortableRepository: sortableRepository,
        genericRepository: genericRepository,
        syncDelay: SyncDelays.zero,
      ),
      act: (SyncBloc syncBloc) => syncBloc.add(const ActivitySaved()),
      verify: (bloc) => verify(() => activityRepository.synchronize()),
    );

    blocTest(
      'FileSaved event calls synchronize on user file repository',
      build: () => SyncBloc(
        activityRepository: activityRepository,
        userFileRepository: userFileRepository,
        sortableRepository: sortableRepository,
        genericRepository: genericRepository,
        syncDelay: SyncDelays.zero,
      ),
      act: (SyncBloc syncBloc) => syncBloc.add(const FileSaved()),
      verify: (bloc) => verify(() => userFileRepository.synchronize()),
    );

    blocTest(
      'SortableSaved event calls synchronize on sortable repository',
      build: () => SyncBloc(
        activityRepository: activityRepository,
        userFileRepository: userFileRepository,
        sortableRepository: sortableRepository,
        genericRepository: genericRepository,
        syncDelay: SyncDelays.zero,
      ),
      act: (SyncBloc syncBloc) => syncBloc.add(const SortableSaved()),
      verify: (bloc) => verify(() => sortableRepository.synchronize()),
    );

    blocTest(
      'GenericSaved event calls synchronize on sortable repository',
      build: () => SyncBloc(
        activityRepository: activityRepository,
        userFileRepository: userFileRepository,
        sortableRepository: sortableRepository,
        genericRepository: genericRepository,
        syncDelay: SyncDelays.zero,
      ),
      act: (SyncBloc syncBloc) => syncBloc.add(const GenericSaved()),
      verify: (bloc) => verify(() => genericRepository.synchronize()),
    );

    blocTest('all event calls synchronize on all repository',
        build: () => SyncBloc(
              activityRepository: activityRepository,
              userFileRepository: userFileRepository,
              sortableRepository: sortableRepository,
              genericRepository: genericRepository,
              syncDelay: SyncDelays.zero,
            ),
        act: (SyncBloc syncBloc) => syncBloc
          ..add(const ActivitySaved())
          ..add(const FileSaved())
          ..add(const SortableSaved())
          ..add(const GenericSaved()),
        verify: (bloc) {
          verify(() => activityRepository.synchronize());
          verify(() => userFileRepository.synchronize());
          verify(() => sortableRepository.synchronize());
          verify(() => genericRepository.synchronize());
        });
  });

  group('Failed cases', () {
    final syncStallTime = 10.milliseconds();

    setUp(() {
      when(() => activityRepository.synchronize())
          .thenAnswer((_) => Future.value(false));
      when(() => userFileRepository.synchronize())
          .thenAnswer((_) => Future.value(false));
      when(() => sortableRepository.synchronize())
          .thenAnswer((_) => Future.value(false));
    });

    test('Failed ActivitySaved synchronize retrys to syncronize old', () async {
      final syncBloc = SyncBloc(
        activityRepository: activityRepository,
        userFileRepository: userFileRepository,
        sortableRepository: sortableRepository,
        genericRepository: genericRepository,
        syncDelay: SyncDelays(
            betweenSync: 10.milliseconds(), retryDelay: Duration.zero),
      );
      syncBloc.add(const ActivitySaved());
      await untilCalled(() => activityRepository.synchronize());
      when(() => activityRepository.synchronize())
          .thenAnswer((_) => Future.value(true));
      await Future.delayed(syncStallTime * 2);
      verify(() => activityRepository.synchronize()).called(2);
    });

    test('Failed FileSaved synchronize retrys to syncronize', () async {
      final syncBloc = SyncBloc(
        activityRepository: activityRepository,
        userFileRepository: userFileRepository,
        sortableRepository: sortableRepository,
        genericRepository: genericRepository,
        syncDelay: SyncDelays(
            betweenSync: 10.milliseconds(), retryDelay: Duration.zero),
      );
      syncBloc.add(const FileSaved());
      await untilCalled(() => userFileRepository.synchronize());
      when(() => userFileRepository.synchronize())
          .thenAnswer((_) => Future.value(true));
      await Future.delayed(syncStallTime * 2);
      verify(() => userFileRepository.synchronize()).called(2);
    });
    test('Failed SortableSaved synchronize retrys to syncronize', () async {
      final syncBloc = SyncBloc(
        activityRepository: activityRepository,
        userFileRepository: userFileRepository,
        sortableRepository: sortableRepository,
        genericRepository: genericRepository,
        syncDelay: SyncDelays(
            betweenSync: 10.milliseconds(), retryDelay: Duration.zero),
      );
      syncBloc.add(const SortableSaved());
      await untilCalled(() => sortableRepository.synchronize());
      when(() => sortableRepository.synchronize())
          .thenAnswer((_) => Future.value(true));
      await Future.delayed(syncStallTime * 2);
      verify(() => sortableRepository.synchronize()).called(2);
    });
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
      final syncBloc = SyncBloc(
          activityRepository: activityRepository,
          userFileRepository: userFileRepository,
          sortableRepository: sortableRepository,
          genericRepository: genericRepository,
          syncDelay: SyncDelays(
            betweenSync: stallTime,
            retryDelay: stallTime,
          ));
      syncBloc.add(const ActivitySaved());
      syncBloc.add(const FileSaved());
      syncBloc.add(const SortableSaved());
      syncBloc.add(const GenericSaved());
      await untilCalled(() => activityRepository.synchronize());
      await untilCalled(() => userFileRepository.synchronize());
      await untilCalled(() => sortableRepository.synchronize());
      await untilCalled(() => genericRepository.synchronize());
    });

    test('throttles invocations of event', () async {
      final syncBloc = SyncBloc(
          activityRepository: activityRepository,
          userFileRepository: userFileRepository,
          sortableRepository: sortableRepository,
          genericRepository: genericRepository,
          syncDelay: SyncDelays(
            betweenSync: stallTime,
            retryDelay: stallTime,
          ));
      syncBloc.add(const ActivitySaved());
      await untilCalled(() => activityRepository.synchronize());
      syncBloc.add(const ActivitySaved());
      syncBloc.add(const ActivitySaved());
      syncBloc.add(const ActivitySaved());
      syncBloc.add(const ActivitySaved());
      syncBloc.add(const FileSaved());
      syncBloc.add(const FileSaved());
      syncBloc.add(const FileSaved());
      syncBloc.add(const FileSaved());
      syncBloc.add(const SortableSaved());
      syncBloc.add(const SortableSaved());
      syncBloc.add(const SortableSaved());
      syncBloc.add(const SortableSaved());
      await Future.delayed(stallTime * 2);
      await untilCalled(() => userFileRepository.synchronize());
      await Future.delayed(stallTime * 2);
      await untilCalled(() => sortableRepository.synchronize());
      await Future.delayed(stallTime * 2);
      verify(() => activityRepository.synchronize()).called(2);
      verify(() => userFileRepository.synchronize()).called(2);
      verify(() => sortableRepository.synchronize()).called(2);
    });

    test(
        'Failed syncs with other events in queue should dequeue other events before retrying (no starvation)',
        () async {
      when(() => activityRepository.synchronize())
          .thenAnswer((_) => Future.value(false));
      final syncBloc = SyncBloc(
          activityRepository: activityRepository,
          userFileRepository: userFileRepository,
          sortableRepository: sortableRepository,
          genericRepository: genericRepository,
          syncDelay: SyncDelays(
            betweenSync: stallTime,
            retryDelay: stallTime,
          ));
      syncBloc.add(const ActivitySaved());
      await untilCalled(() => activityRepository.synchronize());
      syncBloc.add(const ActivitySaved());
      syncBloc.add(const ActivitySaved());
      syncBloc.add(const ActivitySaved());
      syncBloc.add(const ActivitySaved());
      syncBloc.add(const FileSaved());
      syncBloc.add(const FileSaved());
      syncBloc.add(const FileSaved());
      syncBloc.add(const FileSaved());
      syncBloc.add(const SortableSaved());
      syncBloc.add(const SortableSaved());
      syncBloc.add(const SortableSaved());
      syncBloc.add(const SortableSaved());
      await untilCalled(() => userFileRepository.synchronize());
      await untilCalled(() => sortableRepository.synchronize());
    });
  });
}
