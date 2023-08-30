import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:memoplanner/bloc/all.dart';
import 'package:memoplanner/models/all.dart';

void main() {
  late DayPickerBloc dayPickerBloc;
  late ClockCubit clockCubit;
  late StreamController<DateTime> clockStream;
  final theTime = DateTime(1987, 10, 06, 04, 34, 55, 55, 55);
  final theDay = DateTime(1987, 10, 06);
  final thedayBefore = DateTime(1987, 10, 05);
  final theDayAfter = DateTime(1987, 10, 07);
  final theDayAfterTomorrow = DateTime(1987, 10, 08);

  setUp(() {
    clockStream = StreamController();
    clockCubit = ClockCubit(clockStream.stream, initialTime: theTime);
    dayPickerBloc = DayPickerBloc(clockCubit: clockCubit);
  });

  test('initial state', () {
    expect(
      dayPickerBloc.state,
      DayPickerState.forTest(
        theDay,
        Occasion.current,
      ).withMatcher(),
    );
  });

  test('Next day should yeild next day', () async {
    dayPickerBloc.add(NextDay());
    await expectLater(
      dayPickerBloc.stream,
      emits(
        DayPickerState.forTest(
          theDayAfter,
          Occasion.future,
          lastEvent: NextDay(),
        ).withMatcher(),
      ),
    );
  });

  test('Previus day should yeild previus day', () async {
    dayPickerBloc.add(PreviousDay());
    await expectLater(
      dayPickerBloc.stream,
      emits(
        DayPickerState.forTest(
          thedayBefore,
          Occasion.past,
          lastEvent: PreviousDay(),
        ).withMatcher(),
      ),
    );
  });

  test('NextDay then PreviusDay should yeild same day', () async {
    dayPickerBloc
      ..add(NextDay())
      ..add(PreviousDay());
    await expectLater(
      dayPickerBloc.stream,
      emitsInOrder([
        DayPickerState.forTest(
          theDayAfter,
          Occasion.future,
          lastEvent: NextDay(),
        ).withMatcher(),
        DayPickerState.forTest(
          theDay,
          Occasion.current,
          lastEvent: PreviousDay(),
        ).withMatcher(),
      ]),
    );
  });

  test('Current day returns to start day', () async {
    dayPickerBloc
      ..add(NextDay())
      ..add(NextDay())
      ..add(const CurrentDay());
    await expectLater(
      dayPickerBloc.stream,
      emitsInOrder([
        DayPickerState.forTest(
          theDayAfter,
          Occasion.future,
          lastEvent: NextDay(),
        ).withMatcher(),
        DayPickerState.forTest(
          theDayAfterTomorrow,
          Occasion.future,
          lastEvent: NextDay(),
        ).withMatcher(),
        DayPickerState.forTest(
          theDay,
          Occasion.current,
          lastEvent: const CurrentDay(),
        ).withMatcher(),
      ]),
    );
  });

  test('Daylight saving summer time going forward', () async {
    // Arrange
    final daybeforeDST = DateTime(2020, 03, 28);
    final dayLightSavingTime = DateTime(2020, 03, 29);
    final daysAfterDST = DateTime(2020, 03, 30);

    clockCubit = ClockCubit.fixed(daybeforeDST);

    // Act
    dayPickerBloc = DayPickerBloc(clockCubit: clockCubit)
      ..add(NextDay())
      ..add(NextDay());

    // Assert
    await expectLater(
      dayPickerBloc.stream,
      emitsInOrder([
        DayPickerState.forTest(
          dayLightSavingTime,
          Occasion.future,
          lastEvent: NextDay(),
        ).withMatcher(),
        DayPickerState.forTest(
          daysAfterDST,
          Occasion.future,
          lastEvent: NextDay(),
        ).withMatcher()
      ]),
    );
  });

  test('Daylight saving summer time going backwards', () async {
    // Arrange
    final dayLightSavingTime = DateTime(2020, 03, 29);
    final daysAfterDST = DateTime(2020, 03, 30);
    final twoDaysAfterDST = DateTime(2020, 03, 31);
    clockCubit = ClockCubit.fixed(twoDaysAfterDST);

    // Act
    dayPickerBloc = DayPickerBloc(clockCubit: clockCubit)
      ..add(PreviousDay())
      ..add(PreviousDay());

    // Assert
    await expectLater(
      dayPickerBloc.stream,
      emitsInOrder([
        DayPickerState.forTest(
          daysAfterDST,
          Occasion.past,
          lastEvent: PreviousDay(),
        ).withMatcher(),
        DayPickerState.forTest(
          dayLightSavingTime,
          Occasion.past,
          lastEvent: PreviousDay(),
        ).withMatcher(),
      ]),
    );
  });

  test('Daylight saving winter time going forward', () async {
    // Arrange
    final daybeforeDST = DateTime(2020, 10, 24);
    final dayLightSavingTime = DateTime(2020, 10, 25);
    final daysAfterDST = DateTime(2020, 10, 26);

    clockCubit = ClockCubit.fixed(daybeforeDST);

    // Act
    dayPickerBloc = DayPickerBloc(clockCubit: clockCubit)
      ..add(NextDay())
      ..add(NextDay());

    // Assert
    await expectLater(
      dayPickerBloc.stream,
      emitsInOrder([
        DayPickerState.forTest(
          dayLightSavingTime,
          Occasion.future,
          lastEvent: NextDay(),
        ).withMatcher(),
        DayPickerState.forTest(
          daysAfterDST,
          Occasion.future,
          lastEvent: NextDay(),
        ).withMatcher(),
      ]),
    );
  });

  test('Daylight saving winter time going backwards', () async {
    // Arrange
    final dayLightSavingTime = DateTime(2020, 10, 25);
    final daysAfterDST = DateTime(2020, 10, 26);
    final twoDaysAfterDST = DateTime(2020, 10, 27);
    clockCubit = ClockCubit.fixed(twoDaysAfterDST);

    // Act
    dayPickerBloc = DayPickerBloc(clockCubit: clockCubit)
      ..add(PreviousDay())
      ..add(PreviousDay());

    // Assert
    await expectLater(
      dayPickerBloc.stream,
      emitsInOrder([
        DayPickerState.forTest(
          daysAfterDST,
          Occasion.past,
          lastEvent: PreviousDay(),
        ).withMatcher(),
        DayPickerState.forTest(
          dayLightSavingTime,
          Occasion.past,
          lastEvent: PreviousDay(),
        ).withMatcher(),
      ]),
    );
  });

  test('currentDay state should not change until next day', () async {
    for (var i = 0; i < Duration.minutesPerDay; i++) {
      clockStream.add(theDay.add(Duration(minutes: i)));
    }
    await Future.delayed(const Duration(milliseconds: 100));
    dayPickerBloc
      ..add(NextDay())
      ..add(const CurrentDay());
    expect(
      dayPickerBloc.stream,
      emitsInOrder([
        DayPickerState.forTest(
          theDayAfter,
          Occasion.future,
          lastEvent: NextDay(),
        ).withMatcher(),
        DayPickerState.forTest(
          theDay,
          Occasion.current,
          lastEvent: const CurrentDay(),
        ).withMatcher(),
      ]),
    );
  });

  test('currentDay should change with clock passing next day', () async {
    dayPickerBloc.add(PreviousDay());
    clockStream.add(theDayAfter);
    await Future.doWhile(() => Future.delayed(
        const Duration(milliseconds: 10), () => clockCubit.state == theDay));
    dayPickerBloc.add(const CurrentDay());
    await expectLater(
      dayPickerBloc.stream,
      emits(
        DayPickerState.forTest(
          theDayAfter,
          Occasion.current,
        ).withMatcher(),
      ),
    );
    await dayPickerBloc.close();
    await expectLater(dayPickerBloc.stream, emitsDone);
  });

  test('currentDay should change with clocks passing day after next', () async {
    clockStream.add(theDayAfterTomorrow);
    await Future.doWhile(() => Future.delayed(
        const Duration(milliseconds: 10), () => clockCubit.state == theDay));
    dayPickerBloc.add(const CurrentDay());
    await expectLater(
      dayPickerBloc.stream,
      emits(
        DayPickerState.forTest(
          theDayAfterTomorrow,
          Occasion.current,
        ).withMatcher(),
      ),
    );
  });

  test('state should only be day granularity', () async {
    dayPickerBloc.add(PreviousDay());
    for (var i = 0; i < 2 * Duration.secondsPerMinute; i++) {
      clockStream.add(theDay.add(Duration(hours: 23, minutes: 59, seconds: i)));
    }
    await Future.delayed(const Duration(milliseconds: 100));
    dayPickerBloc.add(const CurrentDay());
    await expectLater(
      dayPickerBloc.stream,
      emits(
        DayPickerStateMatcher(
          DayPickerState.forTest(
            theDayAfter,
            Occasion.current,
          ),
        ),
      ),
    );
    await dayPickerBloc.close();
    await expectLater(dayPickerBloc.stream, emitsDone);
  });

  test('Picked day updates when time goes to next day', () async {
    clockStream.add(theDayAfter);
    expect(
      dayPickerBloc.stream,
      emitsInOrder([
        DayPickerState.forTest(
          theDayAfter,
          Occasion.current,
          lastEvent: TimeChanged(theDayAfter),
        ).withMatcher(),
      ]),
    );
  });

  tearDown(() {
    dayPickerBloc.close();
    clockStream.close();
  });
}

extension DayPickerStateMatcherWrapper on DayPickerState {
  DayPickerStateMatcher withMatcher() => DayPickerStateMatcher(this);
}

class DayPickerStateMatcher extends Matcher {
  const DayPickerStateMatcher(this.value);

  final DayPickerState value;

  @override
  Description describe(Description description) => description.add('');

  @override
  bool matches(object, Map matchState) {
    return object is DayPickerState &&
        value.day == object.day &&
        value.occasion == object.occasion &&
        value.lastEvent == object.lastEvent;
  }
}
