import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:seagull/bloc.dart';
import 'package:seagull/fakes/fake_activities.dart';
import 'package:seagull/utils/datetime_utils.dart';

import '../../../mocks.dart';

void main() {
  DayActivitiesBloc dayActivitiesBloc;
  DayPickerBloc dayPickerBloc;
  ClockBloc clockBloc;
  ActivitiesBloc activitiesBloc;
  ActivitiesOccasionBloc activitiesOccasionBloc;
  DateTime thisMinute = onlyMinutes(DateTime(2006, 06, 06, 06, 06));
  MockActivityRepository mockActivityRepository;
  StreamController<DateTime> mockedTicker;

  group('ActivitiesOccasionBloc', () {
    setUp(() {
      mockedTicker = StreamController<DateTime>();

      clockBloc = ClockBloc(mockedTicker.stream, initialTime: thisMinute);
      dayPickerBloc = DayPickerBloc(clockBloc: clockBloc);
      mockActivityRepository = MockActivityRepository();
      activitiesBloc =
          ActivitiesBloc(activitiesRepository: mockActivityRepository);
      dayActivitiesBloc = DayActivitiesBloc(
          dayPickerBloc: dayPickerBloc, activitiesBloc: activitiesBloc);
      activitiesOccasionBloc = ActivitiesOccasionBloc(
          clockBloc: clockBloc, dayActivitiesBloc: dayActivitiesBloc);
    });

    test('initial state is ActivitiesOccasionLoading', () {
      expect(activitiesOccasionBloc.initialState,
          ActivitiesOccasionLoading(thisMinute));
      expect(
          activitiesOccasionBloc.state, ActivitiesOccasionLoading(thisMinute));
      expectLater(
        activitiesOccasionBloc,
        emitsInOrder([ActivitiesOccasionLoading(thisMinute)]),
      );
    });
    test(
        'state is ActivitiesOccasionLoaded when ActivitiesBloc loadeds activities',
        () {
      final activities = <ActivityOccasion>[];
      final expectedResponse = [
        ActivitiesOccasionLoading(thisMinute),
        ActivitiesOccasionLoaded(
            activities: activities,
            fullDayActivities: activities,
            now: thisMinute),
      ];
      when(mockActivityRepository.loadActivities())
          .thenAnswer((_) => Future.value(Iterable.empty()));

      activitiesBloc.add(LoadActivities());
      expectLater(
        activitiesOccasionBloc,
        emitsInOrder(expectedResponse),
      );
    });

    test(
        'ActivitiesOccasionLoaded only loads todays activities with correct occasion in correct order',
        () {
      final nowActivity = FakeActivity.onTime(thisMinute);
      final pastActivity = FakeActivity.past(thisMinute);
      final laterActivity = FakeActivity.later(thisMinute);
      final activitiesToday = <ActivityOccasion>[
        ActivityOccasion.forTest(pastActivity, Occasion.past),
        ActivityOccasion.forTest(nowActivity, Occasion.current),
        ActivityOccasion.forTest(laterActivity, Occasion.future),
      ];

      final expectedResponse = [
        ActivitiesOccasionLoading(thisMinute),
        ActivitiesOccasionLoaded(
            activities: activitiesToday,
            fullDayActivities: <ActivityOccasion>[],
            now: thisMinute),
      ];

      when(mockActivityRepository.loadActivities()).thenAnswer(
          (_) => Future.value([nowActivity, pastActivity, laterActivity]));
      expectLater(
        activitiesOccasionBloc,
        emitsInOrder(expectedResponse),
      );

      activitiesBloc.add(LoadActivities());
      activitiesBloc.add(LoadActivities());
    });

    test('ActivitiesOccasionLoaded fullday activities', () {
      final fullDayActivity = FakeActivity.fullday(thisMinute);
      final tomorrowFullday = FakeActivity.tomorrowFullday(thisMinute);
      final yesterdayFullday = FakeActivity.yesterdayFullday(thisMinute);

      final expectedResponse = [
        ActivitiesOccasionLoading(thisMinute),
        ActivitiesOccasionLoaded(
            activities: <ActivityOccasion>[],
            fullDayActivities: [
              ActivityOccasion.forTest(fullDayActivity, Occasion.future)
            ],
            now: thisMinute),
      ];

      when(mockActivityRepository.loadActivities())
          .thenAnswer((_) => Future.value([
                yesterdayFullday,
                tomorrowFullday,
                fullDayActivity,
              ]));

      expectLater(
        activitiesOccasionBloc,
        emitsInOrder(expectedResponse),
      );

      activitiesBloc.add(LoadActivities());
    });

    test(
        'ActivitiesOccasionLoaded only loads todays activities with correct occasion in correct order and fullday activities',
        () {
      final nowActivity = FakeActivity.onTime(thisMinute);
      final pastActivity = FakeActivity.past(thisMinute);
      final laterActivity = FakeActivity.later(thisMinute);
      final fullDayActivity = FakeActivity.fullday(thisMinute);
      final tomorrowActivity = FakeActivity.dayAfter(thisMinute);
      final activitiesToday = <ActivityOccasion>[
        ActivityOccasion.forTest(pastActivity, Occasion.past),
        ActivityOccasion.forTest(nowActivity, Occasion.current),
        ActivityOccasion.forTest(laterActivity, Occasion.future),
      ];

      final expectedResponse = [
        ActivitiesOccasionLoading(thisMinute),
        ActivitiesOccasionLoaded(
            activities: activitiesToday,
            fullDayActivities: [
              ActivityOccasion.forTest(fullDayActivity, Occasion.future)
            ],
            now: thisMinute),
      ];

      when(mockActivityRepository.loadActivities()).thenAnswer((_) =>
          Future.value([
            nowActivity,
            pastActivity,
            laterActivity,
            fullDayActivity,
            tomorrowActivity
          ]));
      expectLater(
        activitiesOccasionBloc,
        emitsInOrder(expectedResponse),
      );

      activitiesBloc.add(LoadActivities());
    });

    test(
        'ActivitiesOccasionLoaded fullday activities, today, tomorrow, yesterday',
        () async {
      final fullDayActivity = FakeActivity.fullday(thisMinute);
      final tomorrowFullday = FakeActivity.tomorrowFullday(thisMinute);
      final yesterdayFullday = FakeActivity.yesterdayFullday(thisMinute);

      final expectedResponse = [
        ActivitiesOccasionLoading(thisMinute),
        ActivitiesOccasionLoaded(
            activities: <ActivityOccasion>[],
            fullDayActivities: [
              ActivityOccasion.forTest(fullDayActivity, Occasion.future)
            ],
            now: thisMinute),
        ActivitiesOccasionLoaded(
            activities: <ActivityOccasion>[],
            fullDayActivities: [
              ActivityOccasion.forTest(tomorrowFullday, Occasion.future)
            ],
            now: thisMinute),
        ActivitiesOccasionLoaded(
            activities: <ActivityOccasion>[],
            fullDayActivities: [
              ActivityOccasion.forTest(fullDayActivity, Occasion.future)
            ],
            now: thisMinute),
        ActivitiesOccasionLoaded(
            activities: <ActivityOccasion>[],
            fullDayActivities: [
              ActivityOccasion.forTest(yesterdayFullday, Occasion.past)
            ],
            now: thisMinute),
      ];

      when(mockActivityRepository.loadActivities())
          .thenAnswer((_) => Future.value([
                yesterdayFullday,
                tomorrowFullday,
                fullDayActivity,
              ]));

      expectLater(
        activitiesOccasionBloc,
        emitsInOrder(expectedResponse),
      );

      activitiesBloc.add(LoadActivities());
      await activitiesOccasionBloc.any((s) => s is ActivitiesOccasionLoaded);
      dayPickerBloc.add(NextDay());
      dayPickerBloc.add(PreviousDay());
      dayPickerBloc.add(PreviousDay());
    });

    test(
        'ActivitiesOccasionLoaded only loads tomorrows activities with correct occasion in correct order and tomorrows full day',
        () {
      final tomorrow = thisMinute.add(Duration(days: 1));
      final nowActivity = FakeActivity.startsAt(tomorrow);
      final pastActivity = FakeActivity.past(tomorrow);
      final laterActivity = FakeActivity.later(tomorrow);
      final fulldayActivity = FakeActivity.fulldayWhen(tomorrow);
      final activitiesToday = <ActivityOccasion>[
        ActivityOccasion.forTest(pastActivity, Occasion.future),
        ActivityOccasion.forTest(nowActivity, Occasion.future),
        ActivityOccasion.forTest(laterActivity, Occasion.future),
      ];

      final expectedResponse = [
        ActivitiesOccasionLoading(thisMinute),
        ActivitiesOccasionLoaded(
            activities: activitiesToday,
            fullDayActivities: [
              ActivityOccasion.forTest(fulldayActivity, Occasion.future)
            ],
            now: thisMinute),
      ];

      when(mockActivityRepository.loadActivities()).thenAnswer((_) =>
          Future.value(
              [nowActivity, pastActivity, laterActivity, fulldayActivity]));
      expectLater(
        activitiesOccasionBloc,
        emitsInOrder(expectedResponse),
      );

      activitiesBloc.add(LoadActivities());

      dayPickerBloc.add(NextDay());
    });

    test(
        'ActivitiesOccasionLoaded only loads yesterday activities with correct occasion in correct order and yesterday full day',
        () {
      final yesterday = thisMinute.subtract(Duration(days: 1));
      final nowActivity = FakeActivity.startsAt(yesterday);
      final pastActivity = FakeActivity.past(yesterday);
      final laterActivity = FakeActivity.later(yesterday);
      final fulldayActivity = FakeActivity.fulldayWhen(yesterday);
      final activitiesToday = <ActivityOccasion>[
        ActivityOccasion.forTest(pastActivity, Occasion.past),
        ActivityOccasion.forTest(nowActivity, Occasion.past),
        ActivityOccasion.forTest(laterActivity, Occasion.past),
      ];

      final expectedResponse = [
        ActivitiesOccasionLoading(thisMinute),
        ActivitiesOccasionLoaded(
            activities: activitiesToday,
            fullDayActivities: [
              ActivityOccasion.forTest(fulldayActivity, Occasion.past)
            ],
            now: thisMinute),
      ];

      when(mockActivityRepository.loadActivities()).thenAnswer((_) =>
          Future.value(
              [nowActivity, pastActivity, laterActivity, fulldayActivity]));
      expectLater(
        activitiesOccasionBloc,
        emitsInOrder(expectedResponse),
      );

      activitiesBloc.add(LoadActivities());

      dayPickerBloc.add(PreviousDay());
    });

    test('Activity ends this minute is current', () {
      final endsSoon = FakeActivity.endsAt(thisMinute);
      final activitiesToday = <ActivityOccasion>[
        ActivityOccasion.forTest(endsSoon, Occasion.current),
      ];

      final expectedResponse = [
        ActivitiesOccasionLoading(thisMinute),
        ActivitiesOccasionLoaded(
            activities: activitiesToday,
            fullDayActivities: [],
            now: thisMinute),
      ];

      when(mockActivityRepository.loadActivities())
          .thenAnswer((_) => Future.value([endsSoon]));
      expectLater(
        activitiesOccasionBloc,
        emitsInOrder(expectedResponse),
      );
      activitiesBloc.add(LoadActivities());
    });

    test('Activity start this minute is current', () {
      final startsNow = FakeActivity.startsAt(thisMinute);
      final activitiesToday = <ActivityOccasion>[
        ActivityOccasion.forTest(startsNow, Occasion.current),
      ];

      final expectedResponse = [
        ActivitiesOccasionLoading(thisMinute),
        ActivitiesOccasionLoaded(
            activities: activitiesToday,
            fullDayActivities: [],
            now: thisMinute),
      ];

      when(mockActivityRepository.loadActivities())
          .thenAnswer((_) => Future.value([startsNow]));
      expectLater(
        activitiesOccasionBloc,
        emitsInOrder(expectedResponse),
      );
      activitiesBloc.add(LoadActivities());
    });

    test('Changing now changing order', () async {
      final nextMinute = thisMinute.add(Duration(minutes: 1));
      final nowActivity = FakeActivity.longSpanning(thisMinute);
      final endsSoonActivity = FakeActivity.endsAt(thisMinute);
      final startSoonActivity = FakeActivity.startsOneMinuteAfter(thisMinute);
      final activitiesOrder1 = <ActivityOccasion>[
        ActivityOccasion.forTest(nowActivity, Occasion.current),
        ActivityOccasion.forTest(endsSoonActivity, Occasion.current),
        ActivityOccasion.forTest(startSoonActivity, Occasion.future),
      ];

      final activitiesOrder2 = <ActivityOccasion>[
        ActivityOccasion.forTest(endsSoonActivity, Occasion.past),
        ActivityOccasion.forTest(nowActivity, Occasion.current),
        ActivityOccasion.forTest(startSoonActivity, Occasion.current),
      ];

      final expectedResponse = [
        ActivitiesOccasionLoaded(
            activities: activitiesOrder1,
            fullDayActivities: <ActivityOccasion>[],
            now: thisMinute),
        ActivitiesOccasionLoaded(
            activities: activitiesOrder2,
            fullDayActivities: <ActivityOccasion>[],
            now: nextMinute),
      ];
      when(mockActivityRepository.loadActivities()).thenAnswer((_) =>
          Future.value([nowActivity, startSoonActivity, endsSoonActivity]));

      activitiesBloc.add(LoadActivities());

      await activitiesOccasionBloc.any((s) => s is ActivitiesOccasionLoaded);

      mockedTicker.add(nextMinute);

      expectLater(
        activitiesOccasionBloc,
        emitsInOrder(expectedResponse),
      );
    });

    tearDown(() {
      dayPickerBloc.close();
      activitiesBloc.close();
      activitiesOccasionBloc.close();
      dayActivitiesBloc.close();
      clockBloc.close();
      mockedTicker.close();
    });
  });
}
