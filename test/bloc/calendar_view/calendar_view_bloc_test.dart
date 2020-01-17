import 'package:flutter_test/flutter_test.dart';
import 'package:seagull/bloc/all.dart';

void main() {
  CalendarViewBloc calendarViewBloc;
  group('CalendarViewBloc', () {
    setUp(() {
      calendarViewBloc = CalendarViewBloc();
    });
    test('initial state', () {
      expect(calendarViewBloc.initialState,
          CalendarViewState(CalendarViewType.LIST));
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
  });
}
