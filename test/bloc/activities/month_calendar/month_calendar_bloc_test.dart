import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/repository/all.dart';
import 'package:seagull/utils/all.dart';

import '../../../mocks.dart';

void main() {
  MonthCalendarBloc monthCalendarBloc;
  ActivitiesBloc activitiesBloc;
  ActivityRepository mockActivityRepository;

  ClockBloc clockBloc;
  StreamController<DateTime> clock;
  final initial = DateTime(2021, 03, 19, 09, 45);

  setUp(() {
    clock = StreamController<DateTime>();
    clockBloc = ClockBloc(clock.stream, initialTime: initial);
    mockActivityRepository = MockActivityRepository();

    activitiesBloc = ActivitiesBloc(
      activityRepository: mockActivityRepository,
      syncBloc: MockSyncBloc(),
      pushBloc: MockPushBloc(),
    );
  });

  group('Calendar days are correct', () {
    setUp(() {
      when(mockActivityRepository.load())
          .thenAnswer((_) => Future.value(Iterable.empty()));
    });
    test('initial state basics', () {
      // Arrange
      monthCalendarBloc = MonthCalendarBloc(
          activitiesBloc: activitiesBloc, clockBloc: clockBloc);
      // Assert
      expect(
        monthCalendarBloc.state.firstDay,
        DateTime(2021, 03, 01),
      );
      expect(monthCalendarBloc.state.occasion, Occasion.current);
      expect(monthCalendarBloc.state.weeks.length, 5);
    });

    test('initial state', () {
      // Arrange
      monthCalendarBloc = MonthCalendarBloc(
          activitiesBloc: activitiesBloc, clockBloc: clockBloc);

      // Asserts
      expect(
        monthCalendarBloc.state,
        MonthCalendarState(
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
          ],
        ),
      );
    });

    test('next month, basic', () async {
      // Arrange
      monthCalendarBloc = MonthCalendarBloc(
          activitiesBloc: activitiesBloc, clockBloc: clockBloc);

      // Act
      monthCalendarBloc.add(GoToNextMonth());
      final state = await monthCalendarBloc.stream.first;

      // Assert
      expect(
        state.firstDay,
        DateTime(2021, 04, 01),
      );
      expect(state.weeks.length, 5);
      expect(state.occasion, Occasion.future);
    });

    test('next month', () {
      // Arrange
      monthCalendarBloc = MonthCalendarBloc(
          activitiesBloc: activitiesBloc, clockBloc: clockBloc);

      // Act
      monthCalendarBloc.add(GoToNextMonth());

      // Assert
      expectLater(
        monthCalendarBloc.stream,
        emits(
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
            ],
          ),
        ),
      );
    });

    test('previous month, basic', () async {
      // Arrange
      monthCalendarBloc = MonthCalendarBloc(
          activitiesBloc: activitiesBloc, clockBloc: clockBloc);

      // Act
      monthCalendarBloc.add(GoToPreviousMonth());
      final state = await monthCalendarBloc.stream.first;

      // Assert
      expect(
        state.firstDay,
        DateTime(2021, 02, 01),
      );
      expect(state.weeks.length, 4);
      expect(state.occasion, Occasion.past);
    });

    test('previous month', () {
      // Arrange
      monthCalendarBloc = MonthCalendarBloc(
          activitiesBloc: activitiesBloc, clockBloc: clockBloc);

      // Act
      monthCalendarBloc.add(GoToPreviousMonth());

      // Assert
      expectLater(
        monthCalendarBloc.stream,
        emits(
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
                      DateTime(2021, 02, 8), null, false, 00, Occasion.past),
                  MonthDay(
                      DateTime(2021, 02, 9), null, false, 00, Occasion.past),
                  MonthDay(
                      DateTime(2021, 02, 10), null, false, 00, Occasion.past),
                  MonthDay(
                      DateTime(2021, 02, 11), null, false, 00, Occasion.past),
                  MonthDay(
                      DateTime(2021, 02, 12), null, false, 00, Occasion.past),
                  MonthDay(
                      DateTime(2021, 02, 13), null, false, 00, Occasion.past),
                  MonthDay(
                      DateTime(2021, 02, 14), null, false, 00, Occasion.past),
                ],
              ),
              MonthWeek(
                7,
                [
                  MonthDay(
                      DateTime(2021, 02, 15), null, false, 00, Occasion.past),
                  MonthDay(
                      DateTime(2021, 02, 16), null, false, 00, Occasion.past),
                  MonthDay(
                      DateTime(2021, 02, 17), null, false, 00, Occasion.past),
                  MonthDay(
                      DateTime(2021, 02, 18), null, false, 00, Occasion.past),
                  MonthDay(
                      DateTime(2021, 02, 19), null, false, 00, Occasion.past),
                  MonthDay(
                      DateTime(2021, 02, 20), null, false, 00, Occasion.past),
                  MonthDay(
                      DateTime(2021, 02, 21), null, false, 00, Occasion.past),
                ],
              ),
              MonthWeek(
                8,
                [
                  MonthDay(
                      DateTime(2021, 02, 22), null, false, 00, Occasion.past),
                  MonthDay(
                      DateTime(2021, 02, 23), null, false, 00, Occasion.past),
                  MonthDay(
                      DateTime(2021, 02, 24), null, false, 00, Occasion.past),
                  MonthDay(
                      DateTime(2021, 02, 25), null, false, 00, Occasion.past),
                  MonthDay(
                      DateTime(2021, 02, 26), null, false, 00, Occasion.past),
                  MonthDay(
                      DateTime(2021, 02, 27), null, false, 00, Occasion.past),
                  MonthDay(
                      DateTime(2021, 02, 28), null, false, 00, Occasion.past),
                ],
              ),
            ],
          ),
        ),
      );
    });

    test('when new day day is updated', () async {
      // Arrange
      monthCalendarBloc = MonthCalendarBloc(
          activitiesBloc: activitiesBloc, clockBloc: clockBloc);

      var week11 = monthCalendarBloc.state.weeks[2];
      var day18 = week11.days[3] as MonthDay,
          day19 = week11.days[4] as MonthDay,
          day20 = week11.days[5] as MonthDay;

      // Assert
      expect(week11.number, 11);
      expect(day18.occasion, Occasion.past);
      expect(day19.occasion, Occasion.current);
      expect(day20.occasion, Occasion.future);

      // Act
      clock.add(initial.nextDay());
      final nextState = await monthCalendarBloc.stream.first;

      week11 = nextState.weeks[2];
      day19 = week11.days[4] as MonthDay;
      day20 = week11.days[5] as MonthDay;
      final day21 = week11.days[6] as MonthDay;

      // Assert
      expect(day19.occasion, Occasion.past);
      expect(day20.occasion, Occasion.current);
      expect(day21.occasion, Occasion.future);
    });

    test('january 2021', () {
      // Arrange
      final january15 = DateTime(2021, 01, 15, 15, 15);
      final newClock = StreamController<DateTime>();

      clockBloc = ClockBloc(newClock.stream, initialTime: january15);
      monthCalendarBloc = MonthCalendarBloc(
          activitiesBloc: activitiesBloc, clockBloc: clockBloc);

      // Asserts
      expect(
        monthCalendarBloc.state,
        MonthCalendarState(
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
          ],
        ),
      );
    });

    test('may 2021', () {
      // Arrange
      final mayThe4 = DateTime(2021, 05, 04, 13, 37);
      final newClock = StreamController<DateTime>();

      clockBloc = ClockBloc(newClock.stream, initialTime: mayThe4);
      monthCalendarBloc = MonthCalendarBloc(
          activitiesBloc: activitiesBloc, clockBloc: clockBloc);

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
        monthCalendarBloc.state,
        MonthCalendarState(
          firstDay: DateTime(2021, 05, 01),
          occasion: Occasion.current,
          weeks: weeks,
        ),
      );
    });
  });

  group('month activities', () {
    test('monthly recurrent activity', () async {
      // Arrange
      when(mockActivityRepository.load()).thenAnswer(
        (_) => Future.value(
          [
            Activity.createNew(
              title: 'end and start of month',
              startTime: DateTime(2020, 01, 01, 22, 30),
              recurs: Recurs.monthlyOnDays([1, 2, 3, 30, 31]),
            ),
          ],
        ),
      );

      monthCalendarBloc = MonthCalendarBloc(
          activitiesBloc: activitiesBloc, clockBloc: clockBloc);

      // Act
      activitiesBloc.add(LoadActivities());

      // Asserts
      await expectLater(
        monthCalendarBloc.stream,
        emits(
          MonthCalendarState(
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
                      DateTime(2021, 03, 22), null, false, 00, Occasion.future),
                  MonthDay(
                      DateTime(2021, 03, 23), null, false, 00, Occasion.future),
                  MonthDay(
                      DateTime(2021, 03, 24), null, false, 00, Occasion.future),
                  MonthDay(
                      DateTime(2021, 03, 25), null, false, 00, Occasion.future),
                  MonthDay(
                      DateTime(2021, 03, 26), null, false, 00, Occasion.future),
                  MonthDay(
                      DateTime(2021, 03, 27), null, false, 00, Occasion.future),
                  MonthDay(
                      DateTime(2021, 03, 28), null, false, 00, Occasion.future),
                ],
              ),
              MonthWeek(
                13,
                [
                  MonthDay(
                      DateTime(2021, 03, 29), null, false, 00, Occasion.future),
                  MonthDay(
                      DateTime(2021, 03, 30), null, true, 00, Occasion.future),
                  MonthDay(
                      DateTime(2021, 03, 31), null, true, 00, Occasion.future),
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
    });

    test('weekend activity', () async {
      // Arrange
      final firstDay = DateTime(2021, 03, 01);
      final weekendFullDay = Activity.createNew(
        title: 'full day on weekends',
        startTime: DateTime(2010, 01, 01),
        recurs: Recurs.weeklyOnDays([6, 7]),
        fullDay: true,
      );
      when(mockActivityRepository.load()).thenAnswer(
        (_) => Future.value(
          [
            weekendFullDay,
          ],
        ),
      );

      monthCalendarBloc = MonthCalendarBloc(
          activitiesBloc: activitiesBloc, clockBloc: clockBloc);

      // Act
      activitiesBloc.add(LoadActivities());

      // Asserts
      await expectLater(
        monthCalendarBloc.stream,
        emits(
          MonthCalendarState(
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
            ],
          ),
        ),
      );
    });
  });
}
