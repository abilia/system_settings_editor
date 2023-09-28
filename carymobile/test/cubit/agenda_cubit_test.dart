import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:calendar_events/calendar_events.dart';
import 'package:carymessenger/cubit/agenda_cubit.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:seagull_clock/clock_cubit.dart';
import 'package:seagull_clock/ticker.dart';
import 'package:seagull_fakes/all.dart';
import 'package:utils/utils.dart';

void main() {
  late StreamController onActivityUpdateStreamController;
  late StreamController<DateTime> onClockStream;
  late ClockCubit clockCubit;
  late ActivityRepository activityRepository;
  final initialTime = DateTime(2023, 09, 27, 14, 51);
  final initialDay = initialTime.onlyDays();

  setUp(() {
    onActivityUpdateStreamController = StreamController();
    onClockStream = StreamController<DateTime>();
    clockCubit = ClockCubit.withTicker(
      Ticker.fake(
        initialTime: initialTime,
        stream: onClockStream.stream,
      ),
    );
    activityRepository = MockActivityRepository();
    when(() => activityRepository.allBetween(any(), any())).thenAnswer(
      (invocation) async => [],
    );
  });

  tearDown(() {
    onActivityUpdateStreamController.close();
    onClockStream.close();
  });

  blocTest(
    'agenda cubit initial state and loads',
    build: () => AgendaCubit(
      onActivityUpdate: onActivityUpdateStreamController.stream,
      clock: clockCubit,
      activityRepository: activityRepository,
    ),
    verify: (bloc) {
      verify(
        () => activityRepository.allBetween(
          initialDay.previousDay(),
          initialDay.nextDay(),
        ),
      );
    },
    expect: () => [AgendaLoaded(occasions: const {}, day: initialDay)],
  );

  blocTest(
    'agenda cubit clock emits new day state',
    build: () => AgendaCubit(
      onActivityUpdate: onActivityUpdateStreamController.stream,
      clock: clockCubit,
      activityRepository: activityRepository,
    ),
    act: (bloc) {
      for (var i = 0; i < 24 * 60; i++) {
        onClockStream.add(initialTime.add(Duration(minutes: i)));
      }
    },
    verify: (bloc) {
      verify(
        () => activityRepository.allBetween(
          initialDay.previousDay(),
          initialDay.nextDay(),
        ),
      );
      verify(
        () => activityRepository.allBetween(
          initialDay,
          initialDay.nextDay().nextDay(),
        ),
      );
    },
    expect: () => [
      AgendaLoaded(occasions: const {}, day: initialDay),
      AgendaLoaded(occasions: const {}, day: initialDay.nextDay()),
    ],
  );

  final nowActivity = Activity.createNew(
    startTime: initialTime,
  );
  final nowActivityOccasion = ActivityOccasion(
    nowActivity,
    initialDay,
    Occasion.current,
  );

  final pastActivity = Activity.createNew(
    startTime: initialTime.subtract(const Duration(hours: 1)),
  );
  final pastActivityOccasion = ActivityOccasion(
    pastActivity,
    initialDay,
    Occasion.past,
  );

  final futureActivity = Activity.createNew(
    startTime: initialTime.add(const Duration(hours: 1)),
  );
  final futureActivityOccasion = ActivityOccasion(
    futureActivity,
    initialDay,
    Occasion.future,
  );

  blocTest(
    'agenda cubit emits new state on push',
    build: () => AgendaCubit(
      onActivityUpdate: onActivityUpdateStreamController.stream,
      clock: clockCubit,
      activityRepository: activityRepository,
    ),
    act: (bloc) {
      when(
        () => activityRepository.allBetween(
          initialDay.previousDay(),
          initialDay.nextDay(),
        ),
      ).thenAnswer(
        (invocation) async => [
          pastActivity,
          nowActivity,
          futureActivity,
        ],
      );
      onActivityUpdateStreamController.add(1);
    },
    verify: (bloc) {
      verify(
        () => activityRepository.allBetween(
          initialDay.previousDay(),
          initialDay.nextDay(),
        ),
      );
    },
    expect: () => [
      AgendaLoaded(occasions: const {}, day: initialDay),
      AgendaLoaded(
        occasions: {
          Occasion.past: [pastActivityOccasion],
          Occasion.current: [nowActivityOccasion],
          Occasion.future: [futureActivityOccasion],
        },
        day: initialDay,
      )
    ],
  );
}
