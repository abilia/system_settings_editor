import 'package:bloc_test/bloc_test.dart';
import 'package:memoplanner/bloc/all.dart';
import 'package:memoplanner/models/all.dart';
import 'package:memoplanner/utils/all.dart';
import 'package:sortables/bloc/sortable/sortable_bloc.dart';
import 'package:test/expect.dart';
import 'package:test/scaffolding.dart';
import 'package:timezone/data/latest.dart' as tz;

import '../../../mocks/mock_bloc.dart';
import '../../../test_helpers/register_fallback_values.dart';

void main() {
  final aDay = DateTime(2022, 04, 15);
  late MockSortableBloc mockSortableBloc;

  setUpAll(() {
    registerFallbackValues();
    tz.initializeTimeZones();
  });

  setUp(() => mockSortableBloc = MockSortableBloc());

  blocTest<TemplateActivityWizardCubit, WizardState>(
    'initial state',
    build: () => TemplateActivityWizardCubit(
      editActivityCubit: EditActivityCubit.newActivity(
        day: aDay,
        defaultsSettings:
            DefaultsAddActivitySettings(alarm: Alarm.fromInt(noAlarm)),
        calendarId: 'calendarId',
      ),
      sortableBloc: mockSortableBloc,
      original: Sortable.createNew(
        groupId: 'a folder',
        sortOrder: startSortOrder,
        data: BasicActivityDataItem.createNew(),
      ),
    ),
    verify: (c) => expect(
      c.state,
      WizardState(0, const [WizardStep.advance]),
    ),
  );

  blocTest<TemplateActivityWizardCubit, WizardState>(
    'previous not possible',
    build: () => TemplateActivityWizardCubit(
      editActivityCubit: EditActivityCubit.newActivity(
        day: aDay,
        defaultsSettings:
            DefaultsAddActivitySettings(alarm: Alarm.fromInt(noAlarm)),
        calendarId: 'calendarId',
      ),
      sortableBloc: mockSortableBloc,
      original: Sortable.createNew(
        groupId: 'a folder',
        sortOrder: startSortOrder,
        data: BasicActivityDataItem.createNew(),
      ),
    ),
    act: (c) => c.previous(),
    expect: () => [
      WizardState(0, const [WizardStep.advance]),
    ],
  );

  blocTest<TemplateActivityWizardCubit, WizardState>(
    'next emit fail save if no title or image',
    build: () => TemplateActivityWizardCubit(
      editActivityCubit: EditActivityCubit.newActivity(
        day: aDay,
        defaultsSettings:
            DefaultsAddActivitySettings(alarm: Alarm.fromInt(noAlarm)),
        calendarId: 'calendarId',
      ),
      sortableBloc: mockSortableBloc,
      original: Sortable.createNew(
        groupId: 'a folder',
        sortOrder: startSortOrder,
        data: BasicActivityDataItem.createNew(),
      ),
    ),
    act: (c) => c.next(),
    expect: () => [
      WizardState(
        0,
        const [WizardStep.advance],
        saveErrors: const {SaveError.noTitleOrImage},
        successfulSave: false,
      ),
    ],
    verify: (c) {
      verifyNever(() => mockSortableBloc.add(any()));
    },
  );

  blocTest<TemplateActivityWizardCubit, WizardState>(
    'next emit successful save and adds to sortable bloc',
    build: () => TemplateActivityWizardCubit(
      editActivityCubit: EditActivityCubit.newActivity(
        day: aDay,
        defaultsSettings:
            DefaultsAddActivitySettings(alarm: Alarm.fromInt(noAlarm)),
        calendarId: 'calendarId',
      ),
      sortableBloc: mockSortableBloc,
      original: Sortable.createNew(
        groupId: 'some group',
        sortOrder: 'sort-order',
        data: BasicActivityDataItem.createNew(),
      ),
    ),
    act: (c) {
      final a = c.editActivityCubit.state.activity;
      c.editActivityCubit.replaceActivity(a.copyWith(title: 'some title'));
      c.next();
    },
    expect: () => [
      WizardState(
        0,
        const [WizardStep.advance],
        successfulSave: true,
      ),
    ],
    verify: (c) {
      final captured =
          verify(() => mockSortableBloc.add(captureAny())).captured;
      expect(captured, hasLength(1));
      final saved = (captured[0] as SortableUpdated).sortables.first;
      expect(saved.groupId, 'some group');
      expect(saved.sortOrder, 'sort-order');
      final data = saved.data as BasicActivityDataItem;
      expect(data.name, 'some title');
      expect(data.activityTitle, 'some title');
      expect(data.alarmType, noAlarm);
      expect(data.category, Category.right);
      expect(data.checkable, false);
      expect(data.duration, 0);
      expect(data.fullDay, false);
      expect(data.fileId, '');
      expect(data.icon, '');
      expect(data.info, '');
      expect(data.reminders, '');
      expect(data.removeAfter, false);
      expect(data.secret, false);
      expect(data.startTime, 0);
    },
  );
}
