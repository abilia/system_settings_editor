import 'package:memoplanner/bloc/all.dart';
import 'package:memoplanner/i18n/all.dart';
import 'package:memoplanner/models/abilia_timer.dart';
import 'package:memoplanner/models/sortable/data/basic_timer_data.dart';
import 'package:memoplanner/utils/all.dart';
import 'package:test/test.dart';

import '../../../fakes/all.dart';
import '../../../mocks/mocks.dart';

void main() {
  final now = DateTime(2033, 01, 27, 11, 55);
  final ticker = Ticker.fake(initialTime: now);
  final translate = Locales.language.values.first;

  test('Initial state without basicTimer', () async {
    final editTimerCubit = EditTimerCubit(
      ticker: ticker,
      translate: translate,
      timerCubit: TimerCubit(
        timerDb: MockTimerDb(),
        ticker: ticker,
        analytics: FakeSeagullAnalytics(),
      ),
    );

    expect(editTimerCubit.state, EditTimerState.initial());
  });

  test('Initial state with basicTimer', () async {
    final basicTimer = BasicTimerDataItem.fromTimer(
      AbiliaTimer.createNew(
        startTime: now.subtract(5.minutes()),
        duration: 10.minutes(),
      ),
    );
    final editTimerCubit = EditTimerCubit(
      ticker: ticker,
      translate: translate,
      basicTimer: BasicTimerDataItem.fromTimer(
        AbiliaTimer.createNew(
          startTime: now.subtract(5.minutes()),
          duration: 10.minutes(),
        ),
      ),
      timerCubit: TimerCubit(
        timerDb: MockTimerDb(),
        ticker: ticker,
        analytics: FakeSeagullAnalytics(),
      ),
    );

    expect(editTimerCubit.state, EditTimerState.fromTemplate(basicTimer));
  });

  test('durationText shows correct text', () async {
    final editTimerCubit = EditTimerCubit(
      ticker: ticker,
      translate: translate,
      timerCubit: TimerCubit(
        timerDb: MockTimerDb(),
        ticker: ticker,
        analytics: FakeSeagullAnalytics(),
      ),
    );

    editTimerCubit.updateDuration(5.minutes(), TimerSetType.inputField);
    expect(editTimerCubit.state.durationText, '00:05');

    editTimerCubit.updateDuration(10.minutes(), TimerSetType.inputField);
    expect(editTimerCubit.state.durationText, '00:10');

    editTimerCubit.updateDuration(10.hours(), TimerSetType.inputField);
    expect(editTimerCubit.state.durationText, '10:00');

    editTimerCubit.updateDuration(1.seconds(), TimerSetType.inputField);
    expect(editTimerCubit.state.durationText, '00:00');

    editTimerCubit.updateDuration(
        2.hours() + 1.minutes(), TimerSetType.inputField);
    expect(editTimerCubit.state.durationText, '02:01');

    editTimerCubit.updateDuration(
        45.hours() + 45.minutes(), TimerSetType.inputField);
    expect(editTimerCubit.state.durationText, '45:45');

    editTimerCubit.updateDuration(
        99.hours() + 5.minutes(), TimerSetType.inputField);
    expect(editTimerCubit.state.durationText, '99:05');

    editTimerCubit.updateDuration(
        1000.hours() + 26.minutes() + 27.seconds() + 556.milliseconds(),
        TimerSetType.inputField);
    expect(editTimerCubit.state.durationText, '1000:26');

    const days = 564345;
    const hours = 4536545;
    const minutes = 435656;
    const seconds = 24545657;
    const milliseconds = 45654363;
    final totalDuration = days.days() +
        hours.hours() +
        minutes.minutes() +
        seconds.seconds() +
        milliseconds.milliseconds();
    final totalMinutes =
        (minutes + seconds / 60 + milliseconds / 60000).toInt();
    final remainingMinutes = totalMinutes % 60;
    final totalHours =
        (days * 24 + hours + (totalMinutes - remainingMinutes) / 60).toInt();
    final remainingMinutesString = remainingMinutes.toString().padLeft(2, '0');

    editTimerCubit.updateDuration(totalDuration, TimerSetType.inputField);
    expect(editTimerCubit.state.durationText,
        '$totalHours:$remainingMinutesString');
  });

  test('name shows correct text', () async {
    final editTimerCubit = EditTimerCubit(
      ticker: ticker,
      translate: translate,
      timerCubit: TimerCubit(
        timerDb: MockTimerDb(),
        ticker: ticker,
        analytics: FakeSeagullAnalytics(),
      ),
    );

    editTimerCubit.updateDuration(10.minutes(), TimerSetType.inputField);
    expect(editTimerCubit.state.name, '10 minutes');

    editTimerCubit.updateDuration(10.hours(), TimerSetType.inputField);
    expect(editTimerCubit.state.name, '10 hours');

    editTimerCubit.updateDuration(
        11.hours() + 11.minutes(), TimerSetType.inputField);
    expect(editTimerCubit.state.name, '11 hours');

    editTimerCubit.updateName('title');
    expect(editTimerCubit.state.name, 'title');

    editTimerCubit.updateDuration(5.minutes(), TimerSetType.inputField);
    expect(editTimerCubit.state.name, 'title');
  });
}
