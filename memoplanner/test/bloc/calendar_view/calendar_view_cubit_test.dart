import 'package:flutter_test/flutter_test.dart';

import 'package:memoplanner/bloc/all.dart';
import 'package:memoplanner/models/all.dart';

import '../../mocks/mocks.dart';

void main() {
  late CalendarViewCubit calendarViewBloc;
  late MockSettingsDb mockSettingsDb;
  setUp(() {
    mockSettingsDb = MockSettingsDb();
    when(() => mockSettingsDb.leftCategoryExpanded).thenReturn(true);
    when(() => mockSettingsDb.setLeftCategoryExpanded(any()))
        .thenAnswer((_) => Future.value());
    when(() => mockSettingsDb.rightCategoryExpanded).thenReturn(true);
    when(() => mockSettingsDb.setRightCategoryExpanded(any()))
        .thenAnswer((_) => Future.value());
    calendarViewBloc = CalendarViewCubit(mockSettingsDb);
  });

  test('initial state', () {
    expect(
        calendarViewBloc.state,
        const CalendarViewState(
          expandLeftCategory: true,
          expandRightCategory: true,
        ));
  });

  test('initial state other', () {
    when(() => mockSettingsDb.leftCategoryExpanded).thenReturn(false);
    when(() => mockSettingsDb.rightCategoryExpanded).thenReturn(false);
    calendarViewBloc = CalendarViewCubit(mockSettingsDb);
    expect(
      calendarViewBloc.state,
      const CalendarViewState(
        expandLeftCategory: false,
        expandRightCategory: false,
      ),
    );
  });

  test('Toggle left category', () async {
    await calendarViewBloc.toggle(Category.left);
    verify(() => mockSettingsDb.setLeftCategoryExpanded(false));
    expect(
      calendarViewBloc.state,
      const CalendarViewState(
        expandLeftCategory: false,
        expandRightCategory: true,
      ),
    );
  });

  test('Toggle right category', () async {
    await calendarViewBloc.toggle(Category.right);
    verify(() => mockSettingsDb.setRightCategoryExpanded(false));
    expect(
      calendarViewBloc.state,
      const CalendarViewState(
        expandRightCategory: false,
        expandLeftCategory: true,
      ),
    );
  });
}
