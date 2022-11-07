import 'package:flutter_test/flutter_test.dart';
import 'package:memoplanner/models/all.dart';
import 'package:memoplanner/utils/all.dart';

void main() {
  final atNine = DateTime(2020, 03, 12, 09, 00);
  group('basics', () {
    testWidgets('stored start time same as new start time > conflicts',
// old: |
// new: |
// conflicts
        (tester) async {
      final storedActivity =
          Activity.createNew(title: 'old', startTime: atNine);
      final newActivity = Activity.createNew(title: 'new', startTime: atNine);
      expect(
        [storedActivity].anyConflictWith(newActivity),
        isTrue,
      );
    });

    testWidgets(
        'stored start time different from new start time > no conflicts',
// old:  |
// new: |
// does not conflicts
        (tester) async {
      final storedActivity =
          Activity.createNew(title: 'old', startTime: atNine.add(1.minutes()));
      final newActivity = Activity.createNew(title: 'new', startTime: atNine);
      expect(
        [storedActivity].anyConflictWith(newActivity),
        isFalse,
      );
    });

    testWidgets(
        'stored activity with range and new activity with '
        'start time inside range > conflicts',
// old: |----|
// new:   |
// conflicts
        (tester) async {
      final storedActivity = Activity.createNew(
          title: 'old',
          startTime: atNine.subtract(30.minutes()),
          duration: 30.minutes());
      final newActivity = Activity.createNew(
        title: 'new',
        startTime: atNine,
      );
      expect(
        [storedActivity].anyConflictWith(newActivity),
        isTrue,
      );
    });

    testWidgets(
        'stored activity with range and new activity with '
        'start time outside range > no conflicts',
// old: |----|
// new:        |
// does not conflict
        (tester) async {
      final storedActivity = Activity.createNew(
          title: 'old',
          startTime: atNine.subtract(30.minutes()),
          duration: 30.minutes());
      final newActivity = Activity.createNew(
        title: 'new',
        startTime: atNine.add(2.hours()),
      );
      expect(
        [storedActivity].anyConflictWith(newActivity),
        isFalse,
      );
    });

    testWidgets(
        'stored activity with only start time and new with range > conflicts',
// old:    |
// new: |-----|
// conflicts
        (tester) async {
      final storedActivity =
          Activity.createNew(title: 'old', startTime: atNine.add(1.hours()));
      final newActivity = Activity.createNew(
        title: 'new',
        startTime: atNine,
        duration: 3.hours(),
      );
      expect(
        [storedActivity].anyConflictWith(newActivity),
        isTrue,
      );
    });

    testWidgets('stored overlapping with new > conflicts',
// old:   |---|
// new: |---|
// conflicts
        (tester) async {
      final storedActivity = Activity.createNew(
        title: 'old',
        startTime: atNine.add(10.minutes()),
        duration: 10.minutes(),
      );
      final newActivity = Activity.createNew(
        title: 'new',
        startTime: atNine,
        duration: 15.minutes(),
      );
      expect(
        [storedActivity].anyConflictWith(newActivity),
        isTrue,
      );
    });
    testWidgets('no overlap > no conflicts',
// old:     |--|
// new: |--|
// does not conflict
        (tester) async {
      final storedActivity = Activity.createNew(
        title: 'old',
        startTime: atNine.add(10.minutes()),
        duration: 10.minutes(),
      );
      final newActivity = Activity.createNew(
        title: 'new',
        startTime: atNine,
        duration: 5.minutes(),
      );
      expect(
        [storedActivity].anyConflictWith(newActivity),
        isFalse,
      );
    });

    testWidgets('start just after range > conflicts',
// old:|--|
// new: |
// conflicts
        (tester) async {
      final storedActivity = Activity.createNew(
        title: 'old',
        startTime: atNine,
        duration: 30.minutes(),
      );
      final newActivity = Activity.createNew(
        title: 'new',
        startTime: atNine.add(3.minutes()),
      );
      expect(
        [storedActivity].anyConflictWith(newActivity),
        isTrue,
      );
    });

    testWidgets('Stored Full day never conflicts', (tester) async {
      final storedActivity = Activity.createNew(
        title: 'old fullDay',
        startTime: atNine.onlyDays(),
        duration: 24.hours(),
        fullDay: true,
        recurs: Recurs.raw(
            0, 0, atNine.nextDay().onlyDays().millisecondsSinceEpoch),
      );
      final newActivity = Activity.createNew(title: 'new', startTime: atNine);
      expect(
        [storedActivity].anyConflictWith(newActivity),
        isFalse,
      );
    });

    testWidgets('new Full day never conflicts', (tester) async {
      final storedActivity = Activity.createNew(
        title: 'old ',
        startTime: atNine.onlyDays(),
      );
      final newActivity = Activity.createNew(
        title: 'new fullDay',
        startTime: atNine.onlyDays(),
        fullDay: true,
      );
      expect(
        [storedActivity].anyConflictWith(newActivity),
        isFalse,
      );
    });

    testWidgets('recurring activities never conflicts', (tester) async {
      final storedActivity = Activity.createNew(
        title: 'old ',
        startTime: atNine,
      );
      final newActivity = Activity.createNew(
        title: 'new recurring',
        startTime: atNine,
        recurs: Recurs.everyDay,
      );
      expect(
        [storedActivity].anyConflictWith(newActivity),
        isFalse,
      );
    });
  });

  group('same activity', () {
    testWidgets('Same activity does not collides with self',
// old:   |--|
// edited:  |--|
// does not conflict
        (tester) async {
      final storedActivity = Activity.createNew(
          title: 'old', startTime: atNine, duration: 1.hours());
      final edited = storedActivity.copyWith(
        title: 'new',
        startTime: atNine.add(
          30.minutes(),
        ),
      );
      expect(
        [storedActivity].anyConflictWith(edited),
        isFalse,
      );
    });

    testWidgets('overlapping 24:00 but is same activity > no conflicts',
// clock:     00:00
// old:    |----:----|
// edited:      :   |------|
// does not conflict
        (tester) async {
      final storedActivity = Activity.createNew(
        title: 'old',
        startTime: atNine.subtract(12.hours()),
        duration: 12.hours(),
      );

      final newActivity = storedActivity.copyWith(
        title: 'new',
        startTime: atNine.subtract(1.hours()),
      );
      expect(
        [storedActivity].anyConflictWith(newActivity),
        isFalse,
      );
    });
  });

  group('Activities overlapping 24:00', () {
    final at21 = DateTime(2021, 11, 21, 21, 00);
    testWidgets('starts same time as end on stored > conflicts',
// clock:  00:00
// old: |----:----|
// new:      :    |
// conflicts
        (tester) async {
      final storedActivity = Activity.createNew(
        title: 'old',
        startTime: atNine.subtract(12.hours()),
        duration: 12.hours(),
      );

      final newActivity = Activity.createNew(
        title: 'new',
        startTime: atNine,
      );
      expect(
        [storedActivity].anyConflictWith(newActivity),
        isTrue,
      );
    });

    testWidgets(
        'overlapping with stored activity ranging over 24:00 > conflicts',
// clock:   00:00
// old:       :   |-----|
// new: |-----:-----|
// conflicts
        (tester) async {
      final storedActivity = Activity.createNew(
        title: 'old',
        startTime: at21.add(12.hours()),
        duration: 2.hours(),
      );

      final newActivity = Activity.createNew(
        title: 'new',
        startTime: at21,
        duration: 13.hours(),
      );
      expect(
        [storedActivity].anyConflictWith(newActivity),
        isTrue,
      );
    });
  });
}
