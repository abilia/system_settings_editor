import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:seagull/bloc.dart';
import 'package:seagull/fakes/fake_activities.dart';
import 'package:seagull/models.dart';
import 'package:seagull/utils/datetime_utils.dart';

import '../../../mocks.dart';

void main() {
  DayActivitiesBloc dayActivitiesBloc;
  DayPickerBloc dayPickerBloc;
  ActivitiesBloc activitiesBloc;
  DateTime today = onlyDays(DateTime.now());
  MockActivityRepository mockActivityRepository;
  group('DayActivitiesBloc', () {
    setUp(() {
      Stream<DateTime> stream = Stream.empty();
      dayPickerBloc = DayPickerBloc(clockBloc: ClockBloc(stream));
      mockActivityRepository = MockActivityRepository();
      activitiesBloc =
          ActivitiesBloc(activitiesRepository: mockActivityRepository);
      dayActivitiesBloc = DayActivitiesBloc(
          dayPickerBloc: dayPickerBloc, activitiesBloc: activitiesBloc);
    });

    test('initial state is DayActivitiesLoading', () {
      expect(dayActivitiesBloc.initialState, DayActivitiesLoading(today));
      expect(dayActivitiesBloc.state, DayActivitiesLoading(today));
      expectLater(
        dayActivitiesBloc,
        emitsInOrder([DayActivitiesLoading(today)]),
      );
    });

    test('initial state is DayActivitiesLoaded if started with loaded activity', () async {
      when(mockActivityRepository.loadActivities())
          .thenAnswer((_) => Future.value([]));
      activitiesBloc.add(LoadActivities());
      final dayActivitiesBloc2 = DayActivitiesBloc(
          dayPickerBloc: dayPickerBloc, activitiesBloc: activitiesBloc);
      await dayActivitiesBloc.any((s) => s is DayActivitiesLoaded);
      expect(dayActivitiesBloc.initialState, DayActivitiesLoaded(Iterable<Activity>.empty(), today));
      expect(dayActivitiesBloc.state, DayActivitiesLoaded(Iterable<Activity>.empty(), today));
      dayActivitiesBloc2.close();
    });

    test('state is DayActivitiesLoaded when ActivitiesBloc loadeds activities',
        () {
      final activities = Iterable<Activity>.empty();
      final expectedResponse = [
        DayActivitiesLoading(today),
        DayActivitiesLoaded(activities, today),
      ];
      when(mockActivityRepository.loadActivities())
          .thenAnswer((_) => Future.value(activities));

      activitiesBloc.add(LoadActivities());
      expectLater(
        dayActivitiesBloc,
        emitsInOrder(expectedResponse),
      );
    });

    test('DayActivitiesLoaded only loads todays activities', () {
      final activitiesNow = <Activity>[FakeActivity.onTime()]
          .followedBy({}); // followedBy to make list iterable
      final activitiesTomorrow = <Activity>[FakeActivity.dayAfter()]
          .followedBy({}); // followedBy to make list iterable
      final expectedResponse = [
        DayActivitiesLoading(today),
        DayActivitiesLoaded(activitiesNow, today),
      ];

      when(mockActivityRepository.loadActivities()).thenAnswer(
          (_) => Future.value(activitiesNow.followedBy(activitiesTomorrow)));
      expectLater(
        dayActivitiesBloc,
        emitsInOrder(expectedResponse),
      );

      activitiesBloc.add(LoadActivities());
    });

    test('next day loads next days activities', () async {
      final activitiesNow = <Activity>[FakeActivity.onTime()]
          .followedBy({}); // followedBy to make list iterable
      final activitiesTomorrow = <Activity>[FakeActivity.dayAfter()]
          .followedBy({}); // followedBy to make list iterable
      final expectedResponse = [
        DayActivitiesLoading(today),
        DayActivitiesLoaded(activitiesNow, today),
        DayActivitiesLoaded(activitiesTomorrow, today.add(Duration(days: 1))),
      ];

      when(mockActivityRepository.loadActivities()).thenAnswer(
          (_) => Future.value(activitiesNow.followedBy(activitiesTomorrow)));
      expectLater(
        dayActivitiesBloc,
        emitsInOrder(expectedResponse),
      );

      activitiesBloc.add(LoadActivities());
      await dayActivitiesBloc.any((s) => s is DayActivitiesLoaded);
      dayPickerBloc.add(NextDay());
    });

    test('previous day loads previous days activities', () async {
      final activitiesNow = <Activity>[(FakeActivity.onTime())]
          .followedBy({}); // followedBy to make list iterable
      final activitiesYesterDay = <Activity>[FakeActivity.dayBefore()]
          .followedBy({}); // followedBy to make list iterable

      final expectedResponse = [
        DayActivitiesLoading(today),
        DayActivitiesLoaded(activitiesNow, today),
        DayActivitiesLoaded(
            activitiesYesterDay, today.subtract(Duration(days: 1))),
      ];

      when(mockActivityRepository.loadActivities()).thenAnswer(
          (_) => Future.value(activitiesNow.followedBy(activitiesYesterDay)));
      expectLater(
        dayActivitiesBloc,
        emitsInOrder(expectedResponse),
      );

      activitiesBloc.add(LoadActivities());
      await dayActivitiesBloc.any((s) => s is DayActivitiesLoaded);
      dayPickerBloc.add(PreviousDay());
    });

    test('does not show next years activities', () async {
      final nextYear = today.add(Duration(days: 365));
      final activitiesNextYear = <Activity>[
        FakeActivity.startsAt(nextYear),
        FakeActivity.dayAfter(nextYear),
        FakeActivity.dayBefore(nextYear),
      ].followedBy({}); // followedBy to make list iterable
      final expectedResponse = [
        DayActivitiesLoading(today),
        DayActivitiesLoaded(Iterable.empty(), today),
        DayActivitiesLoaded(Iterable.empty(), today.add(Duration(days: 1))),
        DayActivitiesLoaded(Iterable.empty(), today),
        DayActivitiesLoaded(
            Iterable.empty(), today.subtract(Duration(days: 1))),
      ];

      when(mockActivityRepository.loadActivities())
          .thenAnswer((_) => Future.value(activitiesNextYear));
      expectLater(
        dayActivitiesBloc,
        emitsInOrder(expectedResponse),
      );

      activitiesBloc.add(LoadActivities());
      await dayActivitiesBloc.any((s) => s is DayActivitiesLoaded);
      dayPickerBloc.add(NextDay());
      dayPickerBloc.add(PreviousDay());
      dayPickerBloc.add(PreviousDay());
    });

    test('adding activities shows', () async {
      final todayActivity = <Activity>[FakeActivity.startsAt(today)].followedBy({}); // followedBy to make list iterable
      final activitiesAdded = todayActivity.followedBy([
        FakeActivity.dayAfter(today),
        FakeActivity.dayBefore(today),
      ]).followedBy({}); // followedBy to make list iterable
      final expectedResponse = [
        DayActivitiesLoading(today),
        DayActivitiesLoaded(Iterable.empty(), today),
        DayActivitiesLoaded(todayActivity, today),
      ];

      when(mockActivityRepository.loadActivities())
          .thenAnswer((_) => Future.value(Iterable.empty()));

      expectLater(
        dayActivitiesBloc,
        emitsInOrder(expectedResponse),
      );

      activitiesBloc.add(LoadActivities());
      await dayActivitiesBloc.any((s) => s is DayActivitiesLoaded);

      when(mockActivityRepository.loadActivities())
          .thenAnswer((_) => Future.value(activitiesAdded));
      activitiesBloc.add(LoadActivities());
    });

    tearDown(() {
      dayPickerBloc.close();
      activitiesBloc.close();
    });
  });
}
