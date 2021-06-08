// @dart=2.9

import 'package:flutter_test/flutter_test.dart';
import 'package:seagull/bloc/all.dart';

import '../../mocks.dart';

void main() {
  CalendarViewBloc calendarViewBloc;
  MockSettingsDb settingsDb;
  setUp(() {
    settingsDb = MockSettingsDb();
    calendarViewBloc = CalendarViewBloc(settingsDb);
  });
  test('initial state', () {
    expect(calendarViewBloc.state, CalendarViewState());
  });

  test('Toggle left category', () async {
    calendarViewBloc.add(ToggleLeft());
    await expectLater(
      calendarViewBloc.stream,
      emits(
        CalendarViewState(
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
          expandRightCategory: false,
        ),
      ),
    );
  });
}
