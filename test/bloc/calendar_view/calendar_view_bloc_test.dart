import 'package:flutter_test/flutter_test.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/models/all.dart';

import '../../mocks.dart';

void main() {
  CalendarViewBloc calendarViewBloc;
  MockSettingsDb settingsDb;
  setUp(() {
    settingsDb = MockSettingsDb();
    calendarViewBloc = CalendarViewBloc(settingsDb);
  });
  test('initial state', () {
    expect(calendarViewBloc.state, CalendarViewState(DayCalendarType.LIST));
  });

  test('Change calendar view', () async {
    calendarViewBloc.add(CalendarTypeChanged(DayCalendarType.TIMEPILLAR));
    await expectLater(
      calendarViewBloc.stream,
      emits(CalendarViewState(DayCalendarType.TIMEPILLAR)),
    );
  });

  test('Toggle left category', () async {
    calendarViewBloc.add(ToggleLeft());
    await expectLater(
      calendarViewBloc.stream,
      emits(
        CalendarViewState(
          DayCalendarType.LIST,
          expandLeftCategory: false,
        ),
      ),
    );
  });
  test('Toggle right category', () async {
    calendarViewBloc.add(ToggleRight());
    await expectLater(
      calendarViewBloc.stream,
      emits(
        CalendarViewState(
          DayCalendarType.LIST,
          expandRightCategory: false,
        ),
      ),
    );
  });
}
