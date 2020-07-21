import 'package:flutter_test/flutter_test.dart';
import 'package:seagull/bloc/all.dart';

void main() {
  CalendarViewBloc calendarViewBloc;
  group('CalendarViewBloc', () {
    setUp(() {
      calendarViewBloc = CalendarViewBloc();
    });
    test('initial state', () {
      expect(calendarViewBloc.state, CalendarViewState(CalendarViewType.LIST));
    });

    test('Change calendar view', () async {
      calendarViewBloc.add(CalendarViewChanged(CalendarViewType.TIMEPILLAR));
      await expectLater(
        calendarViewBloc,
        emitsInOrder([
          CalendarViewState(CalendarViewType.LIST),
          CalendarViewState(CalendarViewType.TIMEPILLAR)
        ]),
      );
    });
    test('Toggle left category', () async {
      calendarViewBloc.add(ToggleLeft());
      await expectLater(
        calendarViewBloc,
        emitsInOrder([
          CalendarViewState(CalendarViewType.LIST),
          CalendarViewState(
            CalendarViewType.LIST,
            expandLeftCategory: false,
          )
        ]),
      );
    });
    test('Toggle right category', () async {
      calendarViewBloc.add(ToggleRight());
      await expectLater(
        calendarViewBloc,
        emitsInOrder([
          CalendarViewState(CalendarViewType.LIST),
          CalendarViewState(
            CalendarViewType.LIST,
            expandRightCategory: false,
          )
        ]),
      );
    });
  });
}
