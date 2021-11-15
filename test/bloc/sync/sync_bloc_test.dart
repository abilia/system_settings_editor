import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:seagull/bloc/all.dart';

import 'package:seagull/bloc/sync/sync_bloc.dart';
import 'package:seagull/utils/all.dart';

import '../../fakes/fake_db_and_repository.dart';
import '../../mocks/mocks.dart';

void main() {
  final activityRepository = MockActivityRepository();
  final userFileRepository = MockUserFileRepository();
  final sortableRepository = MockSortableRepository();

  group('happy caseas', () {
    final syncBloc = SyncBloc(
      activityRepository: activityRepository,
      userFileRepository: userFileRepository,
      sortableRepository: sortableRepository,
      genericRepository: FakeGenericRepository(),
      syncDelay: SyncDelays.zero,
    );
    setUp(() {
      when(() => activityRepository.synchronize())
          .thenAnswer((_) => Future.value(true));
      when(() => userFileRepository.synchronize())
          .thenAnswer((_) => Future.value(true));
      when(() => sortableRepository.synchronize())
          .thenAnswer((_) => Future.value(true));
    });
    test('ActivitySaved event calls synchronize on activity repository ',
        () async {
      syncBloc.add(SyncEvent.activitySaved);
      await untilCalled(() => activityRepository.synchronize());
    });
    test('FileSaved event calls synchronize on user file repository', () async {
      syncBloc.add(SyncEvent.fileSaved);
      await untilCalled(() => userFileRepository.synchronize());
    });
    test('SortableSaved event calls synchronize on sortable repository',
        () async {
      syncBloc.add(SyncEvent.sortableSaved);
      await untilCalled(() => sortableRepository.synchronize());
    });
  });
  group('Failed cases', () {
    final syncStallTime = 10.milliseconds();
    final syncBloc = SyncBloc(
      activityRepository: activityRepository,
      userFileRepository: userFileRepository,
      sortableRepository: sortableRepository,
      genericRepository: FakeGenericRepository(),
      syncDelay:
          SyncDelays(betweenSync: 10.milliseconds(), retryDelay: Duration.zero),
    );
    setUp(() {
      when(() => activityRepository.synchronize())
          .thenAnswer((_) => Future.value(false));
      when(() => userFileRepository.synchronize())
          .thenAnswer((_) => Future.value(false));
      when(() => sortableRepository.synchronize())
          .thenAnswer((_) => Future.value(false));
    });
    test('Failed ActivitySaved synchronize retrys to syncronize', () async {
      syncBloc.add(SyncEvent.activitySaved);
      await untilCalled(() => activityRepository.synchronize());
      when(() => activityRepository.synchronize())
          .thenAnswer((_) => Future.value(true));
      await Future.delayed(syncStallTime * 2);
      verify(() => activityRepository.synchronize()).called(2);
    });
    test('Failed FileSaved synchronize retrys to syncronize', () async {
      syncBloc.add(SyncEvent.fileSaved);
      await untilCalled(() => userFileRepository.synchronize());
      when(() => userFileRepository.synchronize())
          .thenAnswer((_) => Future.value(true));
      await Future.delayed(syncStallTime * 2);
      verify(() => userFileRepository.synchronize()).called(2);
    });
    test('Failed SortableSaved synchronize retrys to syncronize', () async {
      syncBloc.add(SyncEvent.sortableSaved);
      await untilCalled(() => sortableRepository.synchronize());
      when(() => sortableRepository.synchronize())
          .thenAnswer((_) => Future.value(true));
      await Future.delayed(syncStallTime * 2);
      verify(() => sortableRepository.synchronize()).called(2);
    });
  });

  group('queuing', () {
    final stallTime = 50.milliseconds();
    final syncBloc = SyncBloc(
        activityRepository: activityRepository,
        userFileRepository: userFileRepository,
        sortableRepository: sortableRepository,
        genericRepository: FakeGenericRepository(),
        syncDelay: SyncDelays(
          betweenSync: stallTime,
          retryDelay: stallTime,
        ));
    setUp(() {
      when(() => activityRepository.synchronize())
          .thenAnswer((_) => Future.value(true));
      when(() => userFileRepository.synchronize())
          .thenAnswer((_) => Future.value(true));
      when(() => sortableRepository.synchronize())
          .thenAnswer((_) => Future.value(true));
    });
    test('calls all repositories', () async {
      syncBloc.add(SyncEvent.activitySaved);
      syncBloc.add(SyncEvent.fileSaved);
      syncBloc.add(SyncEvent.sortableSaved);
      await untilCalled(() => activityRepository.synchronize());
      await untilCalled(() => userFileRepository.synchronize());
      await untilCalled(() => sortableRepository.synchronize());
    });

    test('throttles invocations of event', () async {
      syncBloc.add(SyncEvent.activitySaved);
      await untilCalled(() => activityRepository.synchronize());
      syncBloc.add(SyncEvent.activitySaved);
      syncBloc.add(SyncEvent.activitySaved);
      syncBloc.add(SyncEvent.activitySaved);
      syncBloc.add(SyncEvent.activitySaved);
      syncBloc.add(SyncEvent.fileSaved);
      syncBloc.add(SyncEvent.fileSaved);
      syncBloc.add(SyncEvent.fileSaved);
      syncBloc.add(SyncEvent.fileSaved);
      syncBloc.add(SyncEvent.sortableSaved);
      syncBloc.add(SyncEvent.sortableSaved);
      syncBloc.add(SyncEvent.sortableSaved);
      syncBloc.add(SyncEvent.sortableSaved);
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
          .thenAnswer((_) => Future.value(false));
      syncBloc.add(SyncEvent.activitySaved);
      await untilCalled(() => activityRepository.synchronize());
      syncBloc.add(SyncEvent.activitySaved);
      syncBloc.add(SyncEvent.activitySaved);
      syncBloc.add(SyncEvent.activitySaved);
      syncBloc.add(SyncEvent.activitySaved);
      syncBloc.add(SyncEvent.fileSaved);
      syncBloc.add(SyncEvent.fileSaved);
      syncBloc.add(SyncEvent.fileSaved);
      syncBloc.add(SyncEvent.fileSaved);
      syncBloc.add(SyncEvent.sortableSaved);
      syncBloc.add(SyncEvent.sortableSaved);
      syncBloc.add(SyncEvent.sortableSaved);
      syncBloc.add(SyncEvent.sortableSaved);
      await untilCalled(() => userFileRepository.synchronize());
      await untilCalled(() => sortableRepository.synchronize());
    });
  });
  tearDown(() {
    clearInteractions(activityRepository);
    clearInteractions(userFileRepository);
    clearInteractions(sortableRepository);
  });
}
