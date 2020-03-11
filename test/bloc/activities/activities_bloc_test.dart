import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/fakes/all.dart';
import 'package:seagull/models/all.dart';

import '../../mocks.dart';

void main() {
  group('ActivitiesBloc', () {
    ActivitiesBloc activitiesBloc;
    MockActivityRepository mockActivityRepository;
    MockPushBloc mockPushBloc;
    setUp(() {
      mockActivityRepository = MockActivityRepository();
      mockPushBloc = MockPushBloc();
      activitiesBloc = ActivitiesBloc(
        activityRepository: mockActivityRepository,
        pushBloc: mockPushBloc,
        syncBloc: MockSyncBloc(),
      );
    });

    test('initial state is ActivitiesNotLoaded', () {
      expect(activitiesBloc.initialState, ActivitiesNotLoaded());
    });

    test('load activities calls load activities on mockActivityRepostitory',
        () async {
      activitiesBloc.add(LoadActivities());
      await untilCalled(mockActivityRepository.load());
      verify(mockActivityRepository.load());
    });

    test('LoadActivities event returns ActivitiesLoaded state', () {
      final expected = [ActivitiesNotLoaded(), ActivitiesLoaded([])];
      when(mockActivityRepository.load())
          .thenAnswer((_) => Future.value(<Activity>[]));

      expectLater(
        activitiesBloc,
        emitsInOrder(expected),
      );
      activitiesBloc.add(LoadActivities());
    });

    test('LoadActivities event returns ActivitiesLoaded state with Activity',
        () {
      final exptectedActivity = Activity.createNew(
          title: 'title',
          startTime: 1,
          duration: 2,
          reminderBefore: [],
          alarmType: ALARM_SILENT_ONLY_ON_START,
          category: 0);
      final expectedStates = [
        ActivitiesNotLoaded(),
        ActivitiesLoaded([exptectedActivity])
      ];
      when(mockActivityRepository.load())
          .thenAnswer((_) => Future.value(<Activity>[exptectedActivity]));

      expectLater(
        activitiesBloc,
        emitsInOrder(expectedStates),
      );
      activitiesBloc.add(LoadActivities());
    });

    test('calls add activities on mockActivityRepostitory', () async {
      when(mockActivityRepository.load())
          .thenAnswer((_) => Future.value(<Activity>[]));
      final anActivity = FakeActivity.startsNow();
      activitiesBloc.add(LoadActivities());
      await activitiesBloc.firstWhere((s) => s is ActivitiesLoaded);
      activitiesBloc.add(AddActivity(anActivity));
      await untilCalled(mockActivityRepository.save(any));

      verify(mockActivityRepository.save([anActivity]));
    });

    test('AddActivity calls add activities on mockActivityRepostitory',
        () async {
      when(mockActivityRepository.load())
          .thenAnswer((_) => Future.value(<Activity>[]));
      final anActivity = FakeActivity.startsNow();
      activitiesBloc.add(LoadActivities());
      await activitiesBloc.firstWhere((s) => s is ActivitiesLoaded);
      activitiesBloc.add(AddActivity(anActivity));

      await untilCalled(mockActivityRepository.save(any));
    });

    test('UpdateActivities calls save activities on mockActivityRepostitory',
        () async {
      final anActivity = FakeActivity.startsNow();

      when(mockActivityRepository.load())
          .thenAnswer((_) => Future.value(<Activity>[anActivity]));
      activitiesBloc.add(LoadActivities());

      final updatedActivity = anActivity.copyWith(title: 'new title');
      activitiesBloc.add(UpdateActivity(updatedActivity));

      await untilCalled(mockActivityRepository.save([updatedActivity]));
    });

    test('DeleteActivities calls save activities on mockActivityRepostitory',
        () async {
      // Arrange
      final anActivity = FakeActivity.startsNow();
      when(mockActivityRepository.load())
          .thenAnswer((_) => Future.value(<Activity>[anActivity]));
      activitiesBloc.add(LoadActivities());
      final deletedActivity = anActivity.copyWith(deleted: true);

      // Act
      activitiesBloc.add(DeleteActivity(anActivity));

      // Assert
      await untilCalled(mockActivityRepository.save([deletedActivity]));
    });

    test('DeleteActivities does not yeild the deleted activity', () async {
      // Arrange
      final activity1 = FakeActivity.startsNow();
      final activity2 = FakeActivity.startsNow();
      final activity3 = FakeActivity.startsNow();
      final activity4 = FakeActivity.startsNow();
      final fullActivityList = [
        activity1,
        activity2,
        activity3,
        activity4,
      ];
      final activityListDeleted = [
        activity1,
        activity2,
        activity4,
      ].followedBy({});
      when(mockActivityRepository.load())
          .thenAnswer((_) => Future.value(fullActivityList));

      activitiesBloc.add(LoadActivities());

      // Act
      activitiesBloc.add(DeleteActivity(activity3));

      // Assert
      final expectedResponse = [
        ActivitiesNotLoaded(),
        ActivitiesLoaded(fullActivityList),
        ActivitiesLoaded(activityListDeleted),
      ];

      await expectLater(
        activitiesBloc,
        emitsInOrder(expectedResponse),
      );
    });

    test('UpdateActivities state order', () async {
      // Arrange
      final anActivity = FakeActivity.startsNow();
      final activityList = [anActivity];
      final updatedActivity = anActivity.copyWith(title: 'new title');
      final updatedActivityList = [updatedActivity];

      when(mockActivityRepository.load())
          .thenAnswer((_) => Future.value(activityList));
      when(mockActivityRepository.save(updatedActivityList))
          .thenAnswer((_) => Future.value(updatedActivityList));

      // Act
      activitiesBloc.add(LoadActivities());
      activitiesBloc.add(UpdateActivity(updatedActivity));

      // Assert
      final expectedResponse = [
        ActivitiesNotLoaded(),
        ActivitiesLoaded(activityList),
        ActivitiesLoaded(updatedActivityList.followedBy([])),
      ];

      await expectLater(
        activitiesBloc,
        emitsInOrder(expectedResponse),
      );
    });

    tearDown(() {
      activitiesBloc.close();
      mockPushBloc.close();
    });
  });
}
