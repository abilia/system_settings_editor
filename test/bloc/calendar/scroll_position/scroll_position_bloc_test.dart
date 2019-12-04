import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:seagull/bloc.dart';
import 'package:seagull/fakes/fake_activities.dart';
import 'package:seagull/utils.dart';

import '../../../mocks.dart';

class MockScrollController extends Mock implements ScrollController {}

class MockScrollPosition extends Mock implements ScrollPosition {}

void main() {
  ScrollPositionBloc scrollPositionBloc;
  DayActivitiesBloc dayActivitiesBloc;
  DayPickerBloc dayPickerBloc;
  ClockBloc clockBloc;
  ActivitiesBloc activitiesBloc;
  ActivitiesOccasionBloc activitiesOccasionBloc;
  DateTime initialTime = onlyMinutes(DateTime(2006, 06, 06, 06, 06, 06, 06));
  DateTime initialMinutes = onlyMinutes(initialTime);

  MockActivityRepository mockActivityRepository;
  MockScrollController mockScrollController;
  MockScrollPosition mockScrollPosition;
  StreamController<DateTime> mockedTicker;
  final cardHeigt = 80.0;
  final widgetKey = GlobalKey<State<StatefulWidget>>();

  group('ScrollPositionBloc', () {
    setUp(
      () {
        mockedTicker = StreamController<DateTime>();
        clockBloc = ClockBloc(mockedTicker.stream, initialTime: initialMinutes);
        dayPickerBloc = DayPickerBloc(clockBloc: clockBloc);
        mockActivityRepository = MockActivityRepository();
        activitiesBloc = ActivitiesBloc(
            activitiesRepository: mockActivityRepository,
            pushBloc: MockPushBloc());
        dayActivitiesBloc = DayActivitiesBloc(
            dayPickerBloc: dayPickerBloc, activitiesBloc: activitiesBloc);
        activitiesOccasionBloc = ActivitiesOccasionBloc(
            clockBloc: clockBloc,
            dayActivitiesBloc: dayActivitiesBloc,
            dayPickerBloc: dayPickerBloc);
        mockScrollController = MockScrollController();
        mockScrollPosition = MockScrollPosition();

        scrollPositionBloc = ScrollPositionBloc(
            activitiesOccasionBloc,
            clockBloc,
            dayPickerBloc,
            mockScrollController,
            cardHeigt,
            widgetKey);
        when(mockScrollController.position).thenReturn(mockScrollPosition);
        when(mockScrollPosition.maxScrollExtent).thenReturn(0.0);
      },
    );

    test(
      'initial state is Unready',
      () {
        // Assert
        expect(scrollPositionBloc.initialState, Unready());
        expectLater(
          scrollPositionBloc,
          emitsInOrder([
            Unready(),
          ]),
        );
      },
    );

    test(
      'after event ListViewRenderComplete still Unready if ScrollController has no Clients',
      () async {
        // Arrange
        when(mockActivityRepository.loadActivities())
            .thenAnswer((_) => Future.value(Iterable.empty()));
        when(mockScrollController.hasClients).thenReturn(false);

        // Act
        activitiesBloc.add(LoadActivities());
        scrollPositionBloc.add(ListViewRenderComplete());

        // Assert
        await expectLater(
          scrollPositionBloc,
          emitsInOrder([
            Unready(),
          ]),
        );
      },
    );

    test(
      'after event ListViewRenderComplete still Unready if ActivitiesOccasionState is ActivitiesOccasionLoading',
      () async {
        //Arrange
        when(mockScrollController.hasClients).thenReturn(true);
        // Act
        scrollPositionBloc.add(ListViewRenderComplete());
        // Assert
        await expectLater(
          scrollPositionBloc,
          emitsInOrder([
            Unready(),
          ]),
        );
      },
    );

    test(
      'Empty list emits InView',
      () async {
        // Arrange
        when(mockActivityRepository.loadActivities())
            .thenAnswer((_) => Future.value(Iterable.empty()));
        when(mockScrollController.hasClients).thenReturn(true);

        // Act
        activitiesBloc.add(LoadActivities());
        await activitiesOccasionBloc
            .firstWhere((s) => s is ActivitiesOccasionLoaded);

        scrollPositionBloc.add(ListViewRenderComplete());

        // Assert
        await expectLater(
          scrollPositionBloc,
          emitsInOrder([
            Unready(),
            InView(),
          ]),
        );
      },
    );

    test(
      'Empty list emits InView',
      () async {
        // Arrange
        when(mockActivityRepository.loadActivities())
            .thenAnswer((_) => Future.value(Iterable.empty()));
        when(mockScrollController.hasClients).thenReturn(true);

        // Act
        activitiesBloc.add(LoadActivities());
        await activitiesOccasionBloc
            .firstWhere((s) => s is ActivitiesOccasionLoaded);

        scrollPositionBloc.add(ListViewRenderComplete());

        // Assert
        await expectLater(
          scrollPositionBloc,
          emitsInOrder([
            Unready(),
            InView(),
          ]),
        );
      },
    );

    test(
      'Unrenderd emits OutOfView',
      () async {
        // Arrange
        when(mockActivityRepository.loadActivities())
            .thenAnswer((_) => Future.value([FakeActivity.startsAt(initialTime)]));
        when(mockScrollController.hasClients).thenReturn(true);
        when(mockScrollController.offset).thenReturn(0.0);

        // Act
        activitiesBloc.add(LoadActivities());
        await activitiesOccasionBloc
            .firstWhere((s) => s is ActivitiesOccasionLoaded);

        scrollPositionBloc.add(ListViewRenderComplete());

        // Assert
        await expectLater(
          scrollPositionBloc,
          emitsInOrder([
            Unready(),
            OutOfView(),
          ]),
        );
      },
    );

    //scrollPosition >= maxScrollExtent && offsetToActivity > maxScrollExtent;
    test(
      'IfAtBottomOfList emits OutOfView',
      () async {
        // Arrange
        when(mockActivityRepository.loadActivities())
            .thenAnswer((_) => Future.value([FakeActivity.startsAt(initialTime.subtract(Duration(hours: 3))), FakeActivity.startsAt(initialTime)]));
        when(mockScrollController.hasClients).thenReturn(true);
        when(mockScrollController.offset).thenReturn(cardHeigt * 10);

        // Act
        activitiesBloc.add(LoadActivities());
        await activitiesOccasionBloc
            .firstWhere((s) => s is ActivitiesOccasionLoaded);

        scrollPositionBloc.add(ListViewRenderComplete());

        // Assert
        await expectLater(
          scrollPositionBloc,
          emitsInOrder([
            Unready(),
            InView(),
          ]),
        );
      },
    );

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
