import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:collection/collection.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memoplanner/bloc/all.dart';
import 'package:memoplanner/models/all.dart';
import 'package:memoplanner/repository/all.dart';
import 'package:memoplanner/utils/all.dart';
import 'package:seagull_fakes/all.dart';

import '../../../fakes/all.dart';
import '../../../mocks/mocks.dart';

void main() {
  late MonthCalendarCubit monthCalendarCubit;
  late ActivitiesBloc activitiesBloc;
  late ActivityRepository mockActivityRepository;

  late ClockBloc clockBloc;
  late StreamController<DateTime> clock;
  final initial = DateTime(2021, 03, 19, 09, 45);
  late DayPickerBloc dayPickerBloc;

  setUp(() {
    clock = StreamController<DateTime>();
    clockBloc = ClockBloc(clock.stream, initialTime: initial);
    dayPickerBloc = DayPickerBloc(clockBloc: clockBloc);
    mockActivityRepository = MockActivityRepository();

    activitiesBloc = ActivitiesBloc(
      activityRepository: mockActivityRepository,
      syncBloc: FakeSyncBloc(),
    );
  });

  tearDown(() {
    clock.close();
  });

  group('Calendar days are correct', () {
    setUp(() {
      when(() => mockActivityRepository.allBetween(any(), any()))
          .thenAnswer((_) => Future.value(const Iterable.empty()));
    });
    test('initial state basics', () {
      // Arrange
      monthCalendarCubit = MonthCalendarCubit(
        activityRepository: mockActivityRepository,
        activitiesBloc: activitiesBloc,
        clockBloc: clockBloc,
        dayPickerBloc: dayPickerBloc,
      );
      // Assert
      expect(
        monthCalendarCubit.state.firstDay,
        DateTime(2021, 03, 01),
      );
      expect(monthCalendarCubit.state.occasion, Occasion.current);
      expect(monthCalendarCubit.state.weeks.length, 6);
    });

    test('initial state', () {
      // Arrange
      monthCalendarCubit = MonthCalendarCubit(
        activityRepository: mockActivityRepository,
        activitiesBloc: activitiesBloc,
        clockBloc: clockBloc,
        dayPickerBloc: dayPickerBloc,
      );

      // Asserts
      expect(
        monthCalendarCubit.state,
        _MonthCalendarStateMatcher(MonthCalendarState(
          firstDay: DateTime(2021, 03, 01),
          occasion: Occasion.current,
          weeks: [
            MonthWeek(
              9,
              [
                MonthDay(DateTime(2021, 03, 01), null, false, 0, Occasion.past),
                MonthDay(DateTime(2021, 03, 02), null, false, 0, Occasion.past),
                MonthDay(DateTime(2021, 03, 03), null, false, 0, Occasion.past),
                MonthDay(DateTime(2021, 03, 04), null, false, 0, Occasion.past),
                MonthDay(DateTime(2021, 03, 05), null, false, 0, Occasion.past),
                MonthDay(DateTime(2021, 03, 06), null, false, 0, Occasion.past),
                MonthDay(DateTime(2021, 03, 07), null, false, 0, Occasion.past),
              ],
            ),
            MonthWeek(
              10,
              [
                MonthDay(DateTime(2021, 03, 08), null, false, 0, Occasion.past),
                MonthDay(DateTime(2021, 03, 09), null, false, 0, Occasion.past),
                MonthDay(DateTime(2021, 03, 10), null, false, 0, Occasion.past),
                MonthDay(DateTime(2021, 03, 11), null, false, 0, Occasion.past),
                MonthDay(DateTime(2021, 03, 12), null, false, 0, Occasion.past),
                MonthDay(DateTime(2021, 03, 13), null, false, 0, Occasion.past),
                MonthDay(DateTime(2021, 03, 14), null, false, 0, Occasion.past),
              ],
            ),
            MonthWeek(
              11,
              [
                MonthDay(DateTime(2021, 03, 15), null, false, 0, Occasion.past),
                MonthDay(DateTime(2021, 03, 16), null, false, 0, Occasion.past),
                MonthDay(DateTime(2021, 03, 17), null, false, 0, Occasion.past),
                MonthDay(DateTime(2021, 03, 18), null, false, 0, Occasion.past),
                MonthDay(
                    DateTime(2021, 03, 19), null, false, 0, Occasion.current),
                MonthDay(
                    DateTime(2021, 03, 20), null, false, 0, Occasion.future),
                MonthDay(
                    DateTime(2021, 03, 21), null, false, 0, Occasion.future),
              ],
            ),
            MonthWeek(
              12,
              [
                MonthDay(
                    DateTime(2021, 03, 22), null, false, 0, Occasion.future),
                MonthDay(
                    DateTime(2021, 03, 23), null, false, 0, Occasion.future),
                MonthDay(
                    DateTime(2021, 03, 24), null, false, 0, Occasion.future),
                MonthDay(
                    DateTime(2021, 03, 25), null, false, 0, Occasion.future),
                MonthDay(
                    DateTime(2021, 03, 26), null, false, 0, Occasion.future),
                MonthDay(
                    DateTime(2021, 03, 27), null, false, 0, Occasion.future),
                MonthDay(
                    DateTime(2021, 03, 28), null, false, 0, Occasion.future),
              ],
            ),
            MonthWeek(
              13,
              [
                MonthDay(
                    DateTime(2021, 03, 29), null, false, 0, Occasion.future),
                MonthDay(
                    DateTime(2021, 03, 30), null, false, 0, Occasion.future),
                MonthDay(
                    DateTime(2021, 03, 31), null, false, 0, Occasion.future),
                NotInMonthDay(),
                NotInMonthDay(),
                NotInMonthDay(),
                NotInMonthDay(),
              ],
            ),
            MonthWeek(
              14,
              [
                NotInMonthDay(),
                NotInMonthDay(),
                NotInMonthDay(),
                NotInMonthDay(),
                NotInMonthDay(),
                NotInMonthDay(),
                NotInMonthDay(),
              ],
            ),
          ],
        )),
      );
    });

    test('next month, basic', () async {
      // Arrange
      monthCalendarCubit = MonthCalendarCubit(
        activityRepository: mockActivityRepository,
        activitiesBloc: activitiesBloc,
        clockBloc: clockBloc,
        dayPickerBloc: dayPickerBloc,
      );

      // Act
      await monthCalendarCubit.goToNextMonth();
      final state = monthCalendarCubit.state;

      // Assert
      expect(
        state.firstDay,
        DateTime(2021, 04, 01),
      );
      expect(state.weeks.length, 6);
      expect(state.occasion, Occasion.future);
    });

    blocTest<MonthCalendarCubit, MonthCalendarState>(
      'next month',
      build: () => MonthCalendarCubit(
        activityRepository: mockActivityRepository,
        activitiesBloc: activitiesBloc,
        clockBloc: clockBloc,
        dayPickerBloc: dayPickerBloc,
      ),
      act: (bloc) => bloc.goToNextMonth(),
      expect: () => [
        _MonthCalendarStateMatcher(
          MonthCalendarState(
            firstDay: DateTime(2021, 04, 01),
            occasion: Occasion.future,
            weeks: [
              MonthWeek(
                13,
                [
                  NotInMonthDay(),
                  NotInMonthDay(),
                  NotInMonthDay(),
                  MonthDay(
                      DateTime(2021, 04, 1), null, false, 0, Occasion.future),
                  MonthDay(
                      DateTime(2021, 04, 2), null, false, 0, Occasion.future),
                  MonthDay(
                      DateTime(2021, 04, 3), null, false, 0, Occasion.future),
                  MonthDay(
                      DateTime(2021, 04, 4), null, false, 0, Occasion.future),
                ],
              ),
              MonthWeek(
                14,
                [
                  MonthDay(
                      DateTime(2021, 04, 5), null, false, 0, Occasion.future),
                  MonthDay(
                      DateTime(2021, 04, 6), null, false, 0, Occasion.future),
                  MonthDay(
                      DateTime(2021, 04, 7), null, false, 0, Occasion.future),
                  MonthDay(
                      DateTime(2021, 04, 8), null, false, 0, Occasion.future),
                  MonthDay(
                      DateTime(2021, 04, 9), null, false, 0, Occasion.future),
                  MonthDay(
                      DateTime(2021, 04, 10), null, false, 0, Occasion.future),
                  MonthDay(
                      DateTime(2021, 04, 11), null, false, 0, Occasion.future),
                ],
              ),
              MonthWeek(
                15,
                [
                  MonthDay(
                      DateTime(2021, 04, 12), null, false, 0, Occasion.future),
                  MonthDay(
                      DateTime(2021, 04, 13), null, false, 0, Occasion.future),
                  MonthDay(
                      DateTime(2021, 04, 14), null, false, 0, Occasion.future),
                  MonthDay(
                      DateTime(2021, 04, 15), null, false, 0, Occasion.future),
                  MonthDay(
                      DateTime(2021, 04, 16), null, false, 0, Occasion.future),
                  MonthDay(
                      DateTime(2021, 04, 17), null, false, 0, Occasion.future),
                  MonthDay(
                      DateTime(2021, 04, 18), null, false, 0, Occasion.future),
                ],
              ),
              MonthWeek(
                16,
                [
                  MonthDay(
                      DateTime(2021, 04, 19), null, false, 0, Occasion.future),
                  MonthDay(
                      DateTime(2021, 04, 20), null, false, 0, Occasion.future),
                  MonthDay(
                      DateTime(2021, 04, 21), null, false, 0, Occasion.future),
                  MonthDay(
                      DateTime(2021, 04, 22), null, false, 0, Occasion.future),
                  MonthDay(
                      DateTime(2021, 04, 23), null, false, 0, Occasion.future),
                  MonthDay(
                      DateTime(2021, 04, 24), null, false, 0, Occasion.future),
                  MonthDay(
                      DateTime(2021, 04, 25), null, false, 0, Occasion.future),
                ],
              ),
              MonthWeek(
                17,
                [
                  MonthDay(
                      DateTime(2021, 04, 26), null, false, 0, Occasion.future),
                  MonthDay(
                      DateTime(2021, 04, 27), null, false, 0, Occasion.future),
                  MonthDay(
                      DateTime(2021, 04, 28), null, false, 0, Occasion.future),
                  MonthDay(
                      DateTime(2021, 04, 29), null, false, 0, Occasion.future),
                  MonthDay(
                      DateTime(2021, 04, 30), null, false, 0, Occasion.future),
                  NotInMonthDay(),
                  NotInMonthDay(),
                ],
              ),
              MonthWeek(
                18,
                [
                  NotInMonthDay(),
                  NotInMonthDay(),
                  NotInMonthDay(),
                  NotInMonthDay(),
                  NotInMonthDay(),
                  NotInMonthDay(),
                  NotInMonthDay(),
                ],
              ),
            ],
          ),
        ),
      ],
    );

    test('previous month, basic', () async {
      // Arrange
      monthCalendarCubit = MonthCalendarCubit(
        activityRepository: mockActivityRepository,
        activitiesBloc: activitiesBloc,
        clockBloc: clockBloc,
        dayPickerBloc: dayPickerBloc,
      );

      // Act
      await monthCalendarCubit.goToPreviousMonth();
      final state = monthCalendarCubit.state;

      // Assert
      expect(
        state.firstDay,
        DateTime(2021, 02, 01),
      );
      expect(state.weeks.length, 6);
      expect(state.occasion, Occasion.past);
    });

    blocTest<MonthCalendarCubit, MonthCalendarState>(
      'previous month',
      build: () => MonthCalendarCubit(
        activityRepository: mockActivityRepository,
        activitiesBloc: activitiesBloc,
        clockBloc: clockBloc,
        dayPickerBloc: dayPickerBloc,
      ),
      act: (cubit) => cubit.goToPreviousMonth(),
      expect: () => [
        _MonthCalendarStateMatcher(
          MonthCalendarState(
            firstDay: DateTime(2021, 02, 01),
            occasion: Occasion.past,
            weeks: [
              MonthWeek(
                5,
                [
                  MonthDay(
                      DateTime(2021, 02, 1), null, false, 0, Occasion.past),
                  MonthDay(
                      DateTime(2021, 02, 2), null, false, 0, Occasion.past),
                  MonthDay(
                      DateTime(2021, 02, 3), null, false, 0, Occasion.past),
                  MonthDay(
                      DateTime(2021, 02, 4), null, false, 0, Occasion.past),
                  MonthDay(
                      DateTime(2021, 02, 5), null, false, 0, Occasion.past),
                  MonthDay(
                      DateTime(2021, 02, 6), null, false, 0, Occasion.past),
                  MonthDay(
                      DateTime(2021, 02, 7), null, false, 0, Occasion.past),
                ],
              ),
              MonthWeek(
                6,
                [
                  MonthDay(
                      DateTime(2021, 02, 8), null, false, 0, Occasion.past),
                  MonthDay(
                      DateTime(2021, 02, 9), null, false, 0, Occasion.past),
                  MonthDay(
                      DateTime(2021, 02, 10), null, false, 0, Occasion.past),
                  MonthDay(
                      DateTime(2021, 02, 11), null, false, 0, Occasion.past),
                  MonthDay(
                      DateTime(2021, 02, 12), null, false, 0, Occasion.past),
                  MonthDay(
                      DateTime(2021, 02, 13), null, false, 0, Occasion.past),
                  MonthDay(
                      DateTime(2021, 02, 14), null, false, 0, Occasion.past),
                ],
              ),
              MonthWeek(
                7,
                [
                  MonthDay(
                      DateTime(2021, 02, 15), null, false, 0, Occasion.past),
                  MonthDay(
                      DateTime(2021, 02, 16), null, false, 0, Occasion.past),
                  MonthDay(
                      DateTime(2021, 02, 17), null, false, 0, Occasion.past),
                  MonthDay(
                      DateTime(2021, 02, 18), null, false, 0, Occasion.past),
                  MonthDay(
                      DateTime(2021, 02, 19), null, false, 0, Occasion.past),
                  MonthDay(
                      DateTime(2021, 02, 20), null, false, 0, Occasion.past),
                  MonthDay(
                      DateTime(2021, 02, 21), null, false, 0, Occasion.past),
                ],
              ),
              MonthWeek(
                8,
                [
                  MonthDay(
                      DateTime(2021, 02, 22), null, false, 0, Occasion.past),
                  MonthDay(
                      DateTime(2021, 02, 23), null, false, 0, Occasion.past),
                  MonthDay(
                      DateTime(2021, 02, 24), null, false, 0, Occasion.past),
                  MonthDay(
                      DateTime(2021, 02, 25), null, false, 0, Occasion.past),
                  MonthDay(
                      DateTime(2021, 02, 26), null, false, 0, Occasion.past),
                  MonthDay(
                      DateTime(2021, 02, 27), null, false, 0, Occasion.past),
                  MonthDay(
                      DateTime(2021, 02, 28), null, false, 0, Occasion.past),
                ],
              ),
              MonthWeek(
                9,
                [
                  NotInMonthDay(),
                  NotInMonthDay(),
                  NotInMonthDay(),
                  NotInMonthDay(),
                  NotInMonthDay(),
                  NotInMonthDay(),
                  NotInMonthDay(),
                ],
              ),
              MonthWeek(
                10,
                [
                  NotInMonthDay(),
                  NotInMonthDay(),
                  NotInMonthDay(),
                  NotInMonthDay(),
                  NotInMonthDay(),
                  NotInMonthDay(),
                  NotInMonthDay(),
                ],
              ),
            ],
          ),
        ),
      ],
    );

    test('when new day day is updated', () async {
      // Arrange
      monthCalendarCubit = MonthCalendarCubit(
        activityRepository: mockActivityRepository,
        activitiesBloc: activitiesBloc,
        clockBloc: clockBloc,
        dayPickerBloc: dayPickerBloc,
      );

      var week11 = monthCalendarCubit.state.weeks[2];
      final day18 = week11.days[3] as MonthDay;
      var day19 = week11.days[4] as MonthDay,
          day20 = week11.days[5] as MonthDay;

      // Assert
      expect(week11.number, 11);
      expect(day18.occasion, Occasion.past);
      expect(day19.occasion, Occasion.current);
      expect(day20.occasion, Occasion.future);

      // Act
      clock.add(initial.nextDay().add(1.minutes()));
      final nextState = await monthCalendarCubit.stream.first;

      week11 = nextState.weeks[2];
      day19 = week11.days[4] as MonthDay;
      day20 = week11.days[5] as MonthDay;
      final day21 = week11.days[6] as MonthDay;

      // Assert
      expect(day19.occasion, Occasion.past);
      expect(day20.occasion, Occasion.current);
      expect(day21.occasion, Occasion.future);
    });

    test('January 2021', () {
      // Arrange
      final january15 = DateTime(2021, 01, 15, 15, 15);

      clockBloc = ClockBloc.fixed(january15);
      monthCalendarCubit = MonthCalendarCubit(
        activityRepository: mockActivityRepository,
        activitiesBloc: activitiesBloc,
        clockBloc: clockBloc,
        dayPickerBloc: dayPickerBloc,
      );

      // Asserts
      expect(
        monthCalendarCubit.state,
        _MonthCalendarStateMatcher(MonthCalendarState(
          firstDay: DateTime(2021, 01, 01),
          occasion: Occasion.current,
          weeks: [
            MonthWeek(
              53,
              [
                NotInMonthDay(),
                NotInMonthDay(),
                NotInMonthDay(),
                NotInMonthDay(),
                MonthDay(DateTime(2021, 01, 1), null, false, 0, Occasion.past),
                MonthDay(DateTime(2021, 01, 2), null, false, 0, Occasion.past),
                MonthDay(DateTime(2021, 01, 3), null, false, 0, Occasion.past),
              ],
            ),
            MonthWeek(
              1,
              [
                MonthDay(DateTime(2021, 01, 4), null, false, 0, Occasion.past),
                MonthDay(DateTime(2021, 01, 5), null, false, 0, Occasion.past),
                MonthDay(DateTime(2021, 01, 6), null, false, 0, Occasion.past),
                MonthDay(DateTime(2021, 01, 7), null, false, 0, Occasion.past),
                MonthDay(DateTime(2021, 01, 8), null, false, 0, Occasion.past),
                MonthDay(DateTime(2021, 01, 9), null, false, 0, Occasion.past),
                MonthDay(DateTime(2021, 01, 10), null, false, 0, Occasion.past),
              ],
            ),
            MonthWeek(
              2,
              [
                MonthDay(DateTime(2021, 01, 11), null, false, 0, Occasion.past),
                MonthDay(DateTime(2021, 01, 12), null, false, 0, Occasion.past),
                MonthDay(DateTime(2021, 01, 13), null, false, 0, Occasion.past),
                MonthDay(DateTime(2021, 01, 14), null, false, 0, Occasion.past),
                MonthDay(
                    DateTime(2021, 01, 15), null, false, 0, Occasion.current),
                MonthDay(
                    DateTime(2021, 01, 16), null, false, 0, Occasion.future),
                MonthDay(
                    DateTime(2021, 01, 17), null, false, 0, Occasion.future),
              ],
            ),
            MonthWeek(
              3,
              [
                MonthDay(
                    DateTime(2021, 01, 18), null, false, 0, Occasion.future),
                MonthDay(
                    DateTime(2021, 01, 19), null, false, 0, Occasion.future),
                MonthDay(
                    DateTime(2021, 01, 20), null, false, 0, Occasion.future),
                MonthDay(
                    DateTime(2021, 01, 21), null, false, 0, Occasion.future),
                MonthDay(
                    DateTime(2021, 01, 22), null, false, 0, Occasion.future),
                MonthDay(
                    DateTime(2021, 01, 23), null, false, 0, Occasion.future),
                MonthDay(
                    DateTime(2021, 01, 24), null, false, 0, Occasion.future),
              ],
            ),
            MonthWeek(
              4,
              [
                MonthDay(
                    DateTime(2021, 01, 25), null, false, 0, Occasion.future),
                MonthDay(
                    DateTime(2021, 01, 26), null, false, 0, Occasion.future),
                MonthDay(
                    DateTime(2021, 01, 27), null, false, 0, Occasion.future),
                MonthDay(
                    DateTime(2021, 01, 28), null, false, 0, Occasion.future),
                MonthDay(
                    DateTime(2021, 01, 29), null, false, 0, Occasion.future),
                MonthDay(
                    DateTime(2021, 01, 30), null, false, 0, Occasion.future),
                MonthDay(
                    DateTime(2021, 01, 31), null, false, 0, Occasion.future),
              ],
            ),
            MonthWeek(
              5,
              [
                NotInMonthDay(),
                NotInMonthDay(),
                NotInMonthDay(),
                NotInMonthDay(),
                NotInMonthDay(),
                NotInMonthDay(),
                NotInMonthDay(),
              ],
            ),
          ],
        )),
      );
    });

    test('may 2021', () {
      // Arrange
      final mayThe4 = DateTime(2021, 05, 04, 13, 37);

      clockBloc = ClockBloc.fixed(mayThe4);
      monthCalendarCubit = MonthCalendarCubit(
        activityRepository: mockActivityRepository,
        activitiesBloc: activitiesBloc,
        clockBloc: clockBloc,
        dayPickerBloc: dayPickerBloc,
      );

      final weeks = [
        MonthWeek(
          17,
          [
            NotInMonthDay(),
            NotInMonthDay(),
            NotInMonthDay(),
            NotInMonthDay(),
            NotInMonthDay(),
            MonthDay(DateTime(2021, 05, 01), null, false, 0, Occasion.past),
            MonthDay(DateTime(2021, 05, 02), null, false, 0, Occasion.past),
          ],
        ),
        MonthWeek(
          18,
          [
            MonthDay(DateTime(2021, 05, 03), null, false, 0, Occasion.past),
            MonthDay(DateTime(2021, 05, 04), null, false, 0, Occasion.current),
            MonthDay(DateTime(2021, 05, 05), null, false, 0, Occasion.future),
            MonthDay(DateTime(2021, 05, 06), null, false, 0, Occasion.future),
            MonthDay(DateTime(2021, 05, 07), null, false, 0, Occasion.future),
            MonthDay(DateTime(2021, 05, 08), null, false, 0, Occasion.future),
            MonthDay(DateTime(2021, 05, 09), null, false, 0, Occasion.future),
          ],
        ),
        MonthWeek(
          19,
          [
            MonthDay(DateTime(2021, 05, 10), null, false, 0, Occasion.future),
            MonthDay(DateTime(2021, 05, 11), null, false, 0, Occasion.future),
            MonthDay(DateTime(2021, 05, 12), null, false, 0, Occasion.future),
            MonthDay(DateTime(2021, 05, 13), null, false, 0, Occasion.future),
            MonthDay(DateTime(2021, 05, 14), null, false, 0, Occasion.future),
            MonthDay(DateTime(2021, 05, 15), null, false, 0, Occasion.future),
            MonthDay(DateTime(2021, 05, 16), null, false, 0, Occasion.future),
          ],
        ),
        MonthWeek(
          20,
          [
            MonthDay(DateTime(2021, 05, 17), null, false, 0, Occasion.future),
            MonthDay(DateTime(2021, 05, 18), null, false, 0, Occasion.future),
            MonthDay(DateTime(2021, 05, 19), null, false, 0, Occasion.future),
            MonthDay(DateTime(2021, 05, 20), null, false, 0, Occasion.future),
            MonthDay(DateTime(2021, 05, 21), null, false, 0, Occasion.future),
            MonthDay(DateTime(2021, 05, 22), null, false, 0, Occasion.future),
            MonthDay(DateTime(2021, 05, 23), null, false, 0, Occasion.future),
          ],
        ),
        MonthWeek(
          21,
          [
            MonthDay(DateTime(2021, 05, 24), null, false, 0, Occasion.future),
            MonthDay(DateTime(2021, 05, 25), null, false, 0, Occasion.future),
            MonthDay(DateTime(2021, 05, 26), null, false, 0, Occasion.future),
            MonthDay(DateTime(2021, 05, 27), null, false, 0, Occasion.future),
            MonthDay(DateTime(2021, 05, 28), null, false, 0, Occasion.future),
            MonthDay(DateTime(2021, 05, 29), null, false, 0, Occasion.future),
            MonthDay(DateTime(2021, 05, 30), null, false, 0, Occasion.future),
          ],
        ),
        MonthWeek(
          22,
          [
            MonthDay(DateTime(2021, 05, 31), null, false, 0, Occasion.future),
            NotInMonthDay(),
            NotInMonthDay(),
            NotInMonthDay(),
            NotInMonthDay(),
            NotInMonthDay(),
            NotInMonthDay(),
          ],
        ),
      ];

      // Asserts
      expect(
        monthCalendarCubit.state,
        _MonthCalendarStateMatcher(MonthCalendarState(
          firstDay: DateTime(2021, 05, 01),
          occasion: Occasion.current,
          weeks: weeks,
        )),
      );
    });
  });

  group('month activities', () {
    test('monthly recurrent activity', () async {
      // Arrange
      when(() => mockActivityRepository.allBetween(any(), any())).thenAnswer(
        (_) => Future.value(
          [
            Activity.createNew(
              title: 'end and start of month',
              startTime: DateTime(2020, 01, 01, 22, 30),
              recurs: Recurs.monthlyOnDays(const [1, 2, 3, 30, 31]),
            ),
          ],
        ),
      );

      monthCalendarCubit = MonthCalendarCubit(
        activityRepository: mockActivityRepository,
        activitiesBloc: activitiesBloc,
        clockBloc: clockBloc,
        dayPickerBloc: dayPickerBloc,
      );

      // Act
      activitiesBloc.add(LoadActivities());

      // Asserts
      await expectLater(
        monthCalendarCubit.stream,
        emits(
          _MonthCalendarStateMatcher(MonthCalendarState(
            firstDay: DateTime(2021, 03, 01),
            occasion: Occasion.current,
            weeks: [
              MonthWeek(
                9,
                [
                  MonthDay(DateTime(2021, 03, 1), null, true, 0, Occasion.past),
                  MonthDay(DateTime(2021, 03, 2), null, true, 0, Occasion.past),
                  MonthDay(DateTime(2021, 03, 3), null, true, 0, Occasion.past),
                  MonthDay(
                      DateTime(2021, 03, 4), null, false, 0, Occasion.past),
                  MonthDay(
                      DateTime(2021, 03, 5), null, false, 0, Occasion.past),
                  MonthDay(
                      DateTime(2021, 03, 6), null, false, 0, Occasion.past),
                  MonthDay(
                      DateTime(2021, 03, 7), null, false, 0, Occasion.past),
                ],
              ),
              MonthWeek(
                10,
                [
                  MonthDay(
                      DateTime(2021, 03, 8), null, false, 0, Occasion.past),
                  MonthDay(
                      DateTime(2021, 03, 9), null, false, 0, Occasion.past),
                  MonthDay(
                      DateTime(2021, 03, 10), null, false, 0, Occasion.past),
                  MonthDay(
                      DateTime(2021, 03, 11), null, false, 0, Occasion.past),
                  MonthDay(
                      DateTime(2021, 03, 12), null, false, 0, Occasion.past),
                  MonthDay(
                      DateTime(2021, 03, 13), null, false, 0, Occasion.past),
                  MonthDay(
                      DateTime(2021, 03, 14), null, false, 0, Occasion.past),
                ],
              ),
              MonthWeek(
                11,
                [
                  MonthDay(
                      DateTime(2021, 03, 15), null, false, 0, Occasion.past),
                  MonthDay(
                      DateTime(2021, 03, 16), null, false, 0, Occasion.past),
                  MonthDay(
                      DateTime(2021, 03, 17), null, false, 0, Occasion.past),
                  MonthDay(
                      DateTime(2021, 03, 18), null, false, 0, Occasion.past),
                  MonthDay(
                      DateTime(2021, 03, 19), null, false, 0, Occasion.current),
                  MonthDay(
                      DateTime(2021, 03, 20), null, false, 0, Occasion.future),
                  MonthDay(
                      DateTime(2021, 03, 21), null, false, 0, Occasion.future),
                ],
              ),
              MonthWeek(
                12,
                [
                  MonthDay(
                      DateTime(2021, 03, 22), null, false, 0, Occasion.future),
                  MonthDay(
                      DateTime(2021, 03, 23), null, false, 0, Occasion.future),
                  MonthDay(
                      DateTime(2021, 03, 24), null, false, 0, Occasion.future),
                  MonthDay(
                      DateTime(2021, 03, 25), null, false, 0, Occasion.future),
                  MonthDay(
                      DateTime(2021, 03, 26), null, false, 0, Occasion.future),
                  MonthDay(
                      DateTime(2021, 03, 27), null, false, 0, Occasion.future),
                  MonthDay(
                      DateTime(2021, 03, 28), null, false, 0, Occasion.future),
                ],
              ),
              MonthWeek(
                13,
                [
                  MonthDay(
                      DateTime(2021, 03, 29), null, false, 0, Occasion.future),
                  MonthDay(
                      DateTime(2021, 03, 30), null, true, 0, Occasion.future),
                  MonthDay(
                      DateTime(2021, 03, 31), null, true, 0, Occasion.future),
                  NotInMonthDay(),
                  NotInMonthDay(),
                  NotInMonthDay(),
                  NotInMonthDay(),
                ],
              ),
              MonthWeek(
                14,
                [
                  NotInMonthDay(),
                  NotInMonthDay(),
                  NotInMonthDay(),
                  NotInMonthDay(),
                  NotInMonthDay(),
                  NotInMonthDay(),
                  NotInMonthDay(),
                ],
              ),
            ],
          )),
        ),
      );
    });

    test('weekend activity', () async {
      // Arrange
      final firstDay = DateTime(2021, 03, 01);
      final weekendFullDay = Activity.createNew(
        title: 'full day on weekends',
        startTime: DateTime(2010, 01, 01),
        recurs: Recurs.weeklyOnDays(const [6, 7]),
        fullDay: true,
      );
      when(() => mockActivityRepository.allBetween(any(), any())).thenAnswer(
        (_) => Future.value(
          [
            weekendFullDay,
          ],
        ),
      );

      monthCalendarCubit = MonthCalendarCubit(
        activityRepository: mockActivityRepository,
        activitiesBloc: activitiesBloc,
        clockBloc: clockBloc,
        dayPickerBloc: dayPickerBloc,
      );

      // Act
      activitiesBloc.add(LoadActivities());

      // Asserts
      await expectLater(
        monthCalendarCubit.stream,
        emits(
          _MonthCalendarStateMatcher(MonthCalendarState(
            firstDay: firstDay,
            occasion: Occasion.current,
            weeks: [
              MonthWeek(
                9,
                [
                  MonthDay(firstDay, null, false, 0, Occasion.past),
                  MonthDay(
                      DateTime(2021, 03, 2), null, false, 0, Occasion.past),
                  MonthDay(
                      DateTime(2021, 03, 3), null, false, 0, Occasion.past),
                  MonthDay(
                      DateTime(2021, 03, 4), null, false, 0, Occasion.past),
                  MonthDay(
                      DateTime(2021, 03, 5), null, false, 0, Occasion.past),
                  ...[6, 7].map<MonthDay>(
                    (d) => MonthDay(
                      DateTime(2021, 03, d),
                      ActivityDay(weekendFullDay, firstDay.addDays(d - 1)),
                      false,
                      1,
                      Occasion.past,
                    ),
                  ),
                ],
              ),
              MonthWeek(
                10,
                [
                  MonthDay(
                      DateTime(2021, 03, 8), null, false, 0, Occasion.past),
                  MonthDay(
                      DateTime(2021, 03, 9), null, false, 0, Occasion.past),
                  MonthDay(
                      DateTime(2021, 03, 10), null, false, 0, Occasion.past),
                  MonthDay(
                      DateTime(2021, 03, 11), null, false, 0, Occasion.past),
                  MonthDay(
                      DateTime(2021, 03, 12), null, false, 0, Occasion.past),
                  ...[13, 14].map<MonthDay>(
                    (d) => MonthDay(
                      DateTime(2021, 03, d),
                      ActivityDay(weekendFullDay, firstDay.addDays(d - 1)),
                      false,
                      1,
                      Occasion.past,
                    ),
                  ),
                ],
              ),
              MonthWeek(
                11,
                [
                  MonthDay(
                      DateTime(2021, 03, 15), null, false, 0, Occasion.past),
                  MonthDay(
                      DateTime(2021, 03, 16), null, false, 0, Occasion.past),
                  MonthDay(
                      DateTime(2021, 03, 17), null, false, 0, Occasion.past),
                  MonthDay(
                      DateTime(2021, 03, 18), null, false, 0, Occasion.past),
                  MonthDay(
                      DateTime(2021, 03, 19), null, false, 0, Occasion.current),
                  ...[20, 21].map<MonthDay>(
                    (d) => MonthDay(
                      DateTime(2021, 03, d),
                      ActivityDay(weekendFullDay, firstDay.addDays(d - 1)),
                      false,
                      1,
                      Occasion.future,
                    ),
                  ),
                ],
              ),
              MonthWeek(
                12,
                [
                  MonthDay(
                      DateTime(2021, 03, 22), null, false, 0, Occasion.future),
                  MonthDay(
                      DateTime(2021, 03, 23), null, false, 0, Occasion.future),
                  MonthDay(
                      DateTime(2021, 03, 24), null, false, 0, Occasion.future),
                  MonthDay(
                      DateTime(2021, 03, 25), null, false, 0, Occasion.future),
                  MonthDay(
                      DateTime(2021, 03, 26), null, false, 0, Occasion.future),
                  ...[27, 28].map<MonthDay>(
                    (d) => MonthDay(
                      DateTime(2021, 03, d),
                      ActivityDay(weekendFullDay, firstDay.addDays(d - 1)),
                      false,
                      1,
                      Occasion.future,
                    ),
                  ),
                ],
              ),
              MonthWeek(
                13,
                [
                  MonthDay(
                      DateTime(2021, 03, 29), null, false, 0, Occasion.future),
                  MonthDay(
                      DateTime(2021, 03, 30), null, false, 0, Occasion.future),
                  MonthDay(
                      DateTime(2021, 03, 31), null, false, 0, Occasion.future),
                  NotInMonthDay(),
                  NotInMonthDay(),
                  NotInMonthDay(),
                  NotInMonthDay(),
                ],
              ),
              MonthWeek(
                14,
                [
                  NotInMonthDay(),
                  NotInMonthDay(),
                  NotInMonthDay(),
                  NotInMonthDay(),
                  NotInMonthDay(),
                  NotInMonthDay(),
                  NotInMonthDay(),
                ],
              ),
            ],
          )),
        ),
      );
    });

    test('SGC-845: Remove after should be respected', () async {
      // Arrange
      final firstDay = DateTime(2021, 03, 01);
      final removeAfter = Activity.createNew(
        title: 'Remove after',
        startTime: DateTime(2010, 01, 01, 15, 00),
        recurs: Recurs.weeklyOnDays(const [4, 5, 6]),
        removeAfter: true,
      );
      when(() => mockActivityRepository.allBetween(any(), any())).thenAnswer(
        (_) => Future.value(
          [
            removeAfter,
          ],
        ),
      );

      monthCalendarCubit = MonthCalendarCubit(
        activityRepository: mockActivityRepository,
        activitiesBloc: activitiesBloc,
        clockBloc: clockBloc,
        dayPickerBloc: dayPickerBloc,
      );

      // Act
      activitiesBloc.add(LoadActivities());

      // Asserts
      await expectLater(
        monthCalendarCubit.stream,
        emits(
          _MonthCalendarStateMatcher(MonthCalendarState(
            firstDay: firstDay,
            occasion: Occasion.current,
            weeks: [
              MonthWeek(
                9,
                [
                  MonthDay(
                      DateTime(2021, 03, 01), null, false, 0, Occasion.past),
                  MonthDay(
                      DateTime(2021, 03, 02), null, false, 0, Occasion.past),
                  MonthDay(
                      DateTime(2021, 03, 03), null, false, 0, Occasion.past),
                  MonthDay(
                      DateTime(2021, 03, 04), null, false, 0, Occasion.past),
                  MonthDay(
                      DateTime(2021, 03, 05), null, false, 0, Occasion.past),
                  MonthDay(
                      DateTime(2021, 03, 06), null, false, 0, Occasion.past),
                  MonthDay(
                      DateTime(2021, 03, 07), null, false, 0, Occasion.past),
                ],
              ),
              MonthWeek(
                10,
                [
                  MonthDay(
                      DateTime(2021, 03, 08), null, false, 0, Occasion.past),
                  MonthDay(
                      DateTime(2021, 03, 09), null, false, 0, Occasion.past),
                  MonthDay(
                      DateTime(2021, 03, 10), null, false, 0, Occasion.past),
                  MonthDay(
                      DateTime(2021, 03, 11), null, false, 0, Occasion.past),
                  MonthDay(
                      DateTime(2021, 03, 12), null, false, 0, Occasion.past),
                  MonthDay(
                      DateTime(2021, 03, 13), null, false, 0, Occasion.past),
                  MonthDay(
                      DateTime(2021, 03, 14), null, false, 0, Occasion.past),
                ],
              ),
              MonthWeek(
                11,
                [
                  MonthDay(
                      DateTime(2021, 03, 15), null, false, 0, Occasion.past),
                  MonthDay(
                      DateTime(2021, 03, 16), null, false, 0, Occasion.past),
                  MonthDay(
                      DateTime(2021, 03, 17), null, false, 0, Occasion.past),
                  MonthDay(
                      DateTime(2021, 03, 18), null, false, 0, Occasion.past),
                  MonthDay(
                      DateTime(2021, 03, 19), null, true, 0, Occasion.current),
                  MonthDay(
                      DateTime(2021, 03, 20), null, true, 0, Occasion.future),
                  MonthDay(
                      DateTime(2021, 03, 21), null, false, 0, Occasion.future),
                ],
              ),
              MonthWeek(
                12,
                [
                  MonthDay(
                      DateTime(2021, 03, 22), null, false, 0, Occasion.future),
                  MonthDay(
                      DateTime(2021, 03, 23), null, false, 0, Occasion.future),
                  MonthDay(
                      DateTime(2021, 03, 24), null, false, 0, Occasion.future),
                  MonthDay(
                      DateTime(2021, 03, 25), null, true, 0, Occasion.future),
                  MonthDay(
                      DateTime(2021, 03, 26), null, true, 0, Occasion.future),
                  MonthDay(
                      DateTime(2021, 03, 27), null, true, 0, Occasion.future),
                  MonthDay(
                      DateTime(2021, 03, 28), null, false, 0, Occasion.future),
                ],
              ),
              MonthWeek(
                13,
                [
                  MonthDay(
                      DateTime(2021, 03, 29), null, false, 0, Occasion.future),
                  MonthDay(
                      DateTime(2021, 03, 30), null, false, 0, Occasion.future),
                  MonthDay(
                      DateTime(2021, 03, 31), null, false, 0, Occasion.future),
                  NotInMonthDay(),
                  NotInMonthDay(),
                  NotInMonthDay(),
                  NotInMonthDay(),
                ],
              ),
              MonthWeek(
                14,
                [
                  NotInMonthDay(),
                  NotInMonthDay(),
                  NotInMonthDay(),
                  NotInMonthDay(),
                  NotInMonthDay(),
                  NotInMonthDay(),
                  NotInMonthDay(),
                ],
              ),
            ],
          )),
        ),
      );
    });
  });

  test(
    'Adding new timer updates MonthCalendarState',
    () async {
      // Arrange
      final firstDay = DateTime(2021, 03, 01);
      when(() => mockActivityRepository.allBetween(any(), any()))
          .thenAnswer((_) => Future.value(const Iterable.empty()));
      final ticker = Ticker.fake(initialTime: initial);
      final timerCubit = TimerCubit(
        timerDb: MockTimerDb(),
        ticker: ticker,
        analytics: FakeSeagullAnalytics(),
      );
      final timerAlarmBloc = TimerAlarmBloc(
        timerCubit: timerCubit,
        ticker: ticker,
      );
      monthCalendarCubit = MonthCalendarCubit(
        activityRepository: mockActivityRepository,
        activitiesBloc: activitiesBloc,
        timerAlarmBloc: timerAlarmBloc,
        clockBloc: clockBloc,
        dayPickerBloc: dayPickerBloc,
      );

      // Act
      timerAlarmBloc.emit(TimerAlarmState.sort([
        AbiliaTimer(id: 'id', startTime: firstDay, duration: 20.minutes())
            .toOccasion(initial)
      ]));
      await monthCalendarCubit.stream.first;

      // Assert
      expect(
        monthCalendarCubit.state,
        _MonthCalendarStateMatcher(
          MonthCalendarState(
            firstDay: firstDay,
            occasion: Occasion.current,
            weeks: [
              MonthWeek(
                9,
                [
                  MonthDay(
                      DateTime(2021, 03, 01),
                      null,
                      true, // hasTimer is true
                      0,
                      Occasion.past),
                  MonthDay(
                      DateTime(2021, 03, 02), null, false, 0, Occasion.past),
                  MonthDay(
                      DateTime(2021, 03, 03), null, false, 0, Occasion.past),
                  MonthDay(
                      DateTime(2021, 03, 04), null, false, 0, Occasion.past),
                  MonthDay(
                      DateTime(2021, 03, 05), null, false, 0, Occasion.past),
                  MonthDay(
                      DateTime(2021, 03, 06), null, false, 0, Occasion.past),
                  MonthDay(
                      DateTime(2021, 03, 07), null, false, 0, Occasion.past),
                ],
              ),
              MonthWeek(
                10,
                [
                  MonthDay(
                      DateTime(2021, 03, 08), null, false, 0, Occasion.past),
                  MonthDay(
                      DateTime(2021, 03, 09), null, false, 0, Occasion.past),
                  MonthDay(
                      DateTime(2021, 03, 10), null, false, 0, Occasion.past),
                  MonthDay(
                      DateTime(2021, 03, 11), null, false, 0, Occasion.past),
                  MonthDay(
                      DateTime(2021, 03, 12), null, false, 0, Occasion.past),
                  MonthDay(
                      DateTime(2021, 03, 13), null, false, 0, Occasion.past),
                  MonthDay(
                      DateTime(2021, 03, 14), null, false, 0, Occasion.past),
                ],
              ),
              MonthWeek(
                11,
                [
                  MonthDay(
                      DateTime(2021, 03, 15), null, false, 0, Occasion.past),
                  MonthDay(
                      DateTime(2021, 03, 16), null, false, 0, Occasion.past),
                  MonthDay(
                      DateTime(2021, 03, 17), null, false, 0, Occasion.past),
                  MonthDay(
                      DateTime(2021, 03, 18), null, false, 0, Occasion.past),
                  MonthDay(
                      DateTime(2021, 03, 19), null, false, 0, Occasion.current),
                  MonthDay(
                      DateTime(2021, 03, 20), null, false, 0, Occasion.future),
                  MonthDay(
                      DateTime(2021, 03, 21), null, false, 0, Occasion.future),
                ],
              ),
              MonthWeek(
                12,
                [
                  MonthDay(
                      DateTime(2021, 03, 22), null, false, 0, Occasion.future),
                  MonthDay(
                      DateTime(2021, 03, 23), null, false, 0, Occasion.future),
                  MonthDay(
                      DateTime(2021, 03, 24), null, false, 0, Occasion.future),
                  MonthDay(
                      DateTime(2021, 03, 25), null, false, 0, Occasion.future),
                  MonthDay(
                      DateTime(2021, 03, 26), null, false, 0, Occasion.future),
                  MonthDay(
                      DateTime(2021, 03, 27), null, false, 0, Occasion.future),
                  MonthDay(
                      DateTime(2021, 03, 28), null, false, 0, Occasion.future),
                ],
              ),
              MonthWeek(
                13,
                [
                  MonthDay(
                      DateTime(2021, 03, 29), null, false, 0, Occasion.future),
                  MonthDay(
                      DateTime(2021, 03, 30), null, false, 0, Occasion.future),
                  MonthDay(
                      DateTime(2021, 03, 31), null, false, 0, Occasion.future),
                  NotInMonthDay(),
                  NotInMonthDay(),
                  NotInMonthDay(),
                  NotInMonthDay(),
                ],
              ),
              MonthWeek(
                14,
                [
                  NotInMonthDay(),
                  NotInMonthDay(),
                  NotInMonthDay(),
                  NotInMonthDay(),
                  NotInMonthDay(),
                  NotInMonthDay(),
                  NotInMonthDay(),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );
}

class _MonthCalendarStateMatcher extends Matcher {
  const _MonthCalendarStateMatcher(this.value);

  final MonthCalendarState value;

  @override
  Description describe(Description description) => description.add('');

  @override
  bool matches(object, Map matchState) {
    return object is MonthCalendarState &&
        value.firstDay == object.firstDay &&
        value.occasion == object.occasion &&
        const ListEquality().equals(value.weeks, object.weeks);
  }
}
