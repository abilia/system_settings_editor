import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/i18n/app_localizations.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/utils/all.dart';
import 'package:seagull/ui/components/all.dart';
import 'package:seagull/ui/pages/all.dart';
import 'package:intl/date_symbol_data_local.dart';

import '../../mocks.dart';

void main() {
  group('new activity test', () {
    DateTime startTime = DateTime(2020, 02, 25, 15, 30);
    DateTime today = startTime.onlyDays();
    Activity startActivity = Activity.createNew(
      title: '',
      startTime: startTime.millisecondsSinceEpoch,
    );
    final locale = Locale('en');
    final translate = Translator(locale).translate;

    Widget wrapWithMaterialApp(Widget widget) => MaterialApp(
          supportedLocales: Translator.supportedLocals,
          localizationsDelegates: [Translator.delegate],
          localeResolutionCallback: (locale, supportedLocales) =>
              supportedLocales.firstWhere(
                  (l) => l.languageCode == locale?.languageCode,
                  orElse: () => supportedLocales.first),
          home: MultiBlocProvider(providers: [
            BlocProvider<AuthenticationBloc>(
                create: (context) => MockAuthenticationBloc()),
            BlocProvider<ActivitiesBloc>(
                create: (context) => MockActivitiesBloc()),
            BlocProvider<AddActivityBloc>(
              create: (context) => AddActivityBloc(
                activitiesBloc: BlocProvider.of<ActivitiesBloc>(context),
                activity: startActivity,
              ),
            ),
          ], child: widget),
        );

    setUp(() {
      Locale.cachedLocale = locale;
      initializeDateFormatting();
    });

    Future scrollDown(WidgetTester tester) async {
      final Offset center =
          tester.getCenter(find.byKey(TestKey.leftCategoryRadio));
      await tester.dragFrom(center, Offset(0.0, -800.0));
      await tester.pump();
    }

    testWidgets('New activity shows', (WidgetTester tester) async {
      await tester
          .pumpWidget(wrapWithMaterialApp(NewActivityPage(today: today)));
      await tester.pumpAndSettle();
      expect(find.byType(NewActivityPage), findsOneWidget);
    });

    testWidgets('Scroll to end of page', (WidgetTester tester) async {
      await tester
          .pumpWidget(wrapWithMaterialApp(NewActivityPage(today: today)));
      await tester.pumpAndSettle();
      expect(find.byType(AvailibleForWidget), findsNothing);
      await scrollDown(tester);
      expect(find.byType(AvailibleForWidget), findsOneWidget);
    });

    testWidgets('Can enter text', (WidgetTester tester) async {
      final newActivtyTitle = 'activity title';
      await tester
          .pumpWidget(wrapWithMaterialApp(NewActivityPage(today: today)));
      await tester.pumpAndSettle();
      expect(find.text(newActivtyTitle), findsNothing);
      await tester.enterText(
          find.byKey(TestKey.newActivityNameInput), newActivtyTitle);
      expect(find.text(newActivtyTitle), findsOneWidget);
    });

    testWidgets('Select picture dialog shows', (WidgetTester tester) async {
      await tester
          .pumpWidget(wrapWithMaterialApp(NewActivityPage(today: today)));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(TestKey.addPicture));
      await tester.pumpAndSettle();
      expect(find.byType(SelectPictureDialog), findsOneWidget);
      await tester.tap(find.byKey(TestKey.closeDialog));
      await tester.pumpAndSettle();
      expect(find.byType(SelectPictureDialog), findsNothing);
    });

    testWidgets(
        'Add activity button is disabled when no title and enabled when titled entered',
        (WidgetTester tester) async {
      final newActivtyName = 'new activity name';
      await tester
          .pumpWidget(wrapWithMaterialApp(NewActivityPage(today: today)));
      await tester.pumpAndSettle();
      expect(
          tester
              .widget<ActionButton>(find.byKey(TestKey.finishNewActivityButton))
              .onPressed,
          isNull);
      await tester.enterText(
          find.byKey(TestKey.newActivityNameInput), newActivtyName);
      await tester.pumpAndSettle();

      expect(
        tester
            .widget<ActionButton>(find.byKey(TestKey.finishNewActivityButton))
            .onPressed,
        isNotNull,
      );
      await tester.tap(find.byKey(TestKey.finishNewActivityButton));
      await tester.pumpAndSettle();
    });

    testWidgets('full day switch', (WidgetTester tester) async {
      await tester
          .pumpWidget(wrapWithMaterialApp(NewActivityPage(today: today)));
      await tester.pumpAndSettle();
      expect(
          tester
              .widget<Switch>(find.byKey(ObjectKey(TestKey.fullDaySwitch)))
              .value,
          isFalse);
      await tester.tap(find.byKey(TestKey.fullDaySwitch));
      await tester.pumpAndSettle();
      expect(
          tester
              .widget<Switch>(find.byKey(ObjectKey(TestKey.fullDaySwitch)))
              .value,
          isTrue);
    });

    testWidgets('alarm at start switch', (WidgetTester tester) async {
      await tester
          .pumpWidget(wrapWithMaterialApp(NewActivityPage(today: today)));
      await tester.pumpAndSettle();
      await scrollDown(tester);
      expect(
          tester
              .widget<Switch>(find.byKey(ObjectKey(TestKey.alarmAtStartSwitch)))
              .value,
          isFalse);
      expect(find.byKey(TestKey.alarmAtStartSwitch), findsOneWidget);
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(TestKey.alarmAtStartSwitch));
      await tester.pumpAndSettle();
      expect(
          tester
              .widget<Switch>(find.byKey(ObjectKey(TestKey.alarmAtStartSwitch)))
              .value,
          isTrue);
    });

    testWidgets('Select alarm dialog', (WidgetTester tester) async {
      await tester
          .pumpWidget(wrapWithMaterialApp(NewActivityPage(today: today)));
      await tester.pumpAndSettle();
      await scrollDown(tester);
      await tester.pumpAndSettle();
      expect(find.byKey(TestKey.selectAlarm), findsOneWidget);
      expect(find.text(translate.vibration), findsNothing);
      expect(find.byIcon(AbiliaIcons.handi_vibration), findsNothing);
      await tester.tap(find.byKey(TestKey.selectAlarm));
      await tester.pumpAndSettle();
      expect(find.byType(SelectAlarmTypeDialog), findsOneWidget);
      await tester.tap(find.byKey(TestKey.vibrationAlarm));
      await tester.pumpAndSettle();
      expect(find.text(translate.vibration), findsOneWidget);
      expect(find.byIcon(AbiliaIcons.handi_vibration), findsOneWidget);
    });

    testWidgets('checkable switch', (WidgetTester tester) async {
      await tester
          .pumpWidget(wrapWithMaterialApp(NewActivityPage(today: today)));
      await tester.pumpAndSettle();
      await scrollDown(tester);
      expect(
          tester
              .widget<Switch>(find.byKey(ObjectKey(TestKey.checkableSwitch)))
              .value,
          isFalse);
      expect(find.byKey(TestKey.checkableSwitch), findsOneWidget);
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(TestKey.checkableSwitch));
      await tester.pumpAndSettle();
      expect(
          tester
              .widget<Switch>(find.byKey(ObjectKey(TestKey.checkableSwitch)))
              .value,
          isTrue);
    });

    testWidgets('delete after switch', (WidgetTester tester) async {
      await tester
          .pumpWidget(wrapWithMaterialApp(NewActivityPage(today: today)));
      await tester.pumpAndSettle();
      await scrollDown(tester);
      expect(
          tester
              .widget<Switch>(find.byKey(ObjectKey(TestKey.deleteAfterSwitch)))
              .value,
          isFalse);
      expect(find.byKey(TestKey.deleteAfterSwitch), findsOneWidget);
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(TestKey.deleteAfterSwitch));
      await tester.pumpAndSettle();
      expect(
          tester
              .widget<Switch>(find.byKey(ObjectKey(TestKey.deleteAfterSwitch)))
              .value,
          isTrue);
    });

    testWidgets('Datetime picker', (WidgetTester tester) async {
      await tester
          .pumpWidget(wrapWithMaterialApp(NewActivityPage(today: today)));
      await tester.pumpAndSettle();
      expect(find.text('(Today) February 25, 2020'), findsOneWidget);

      await tester.tap(find.byKey(TestKey.datePicker));
      await tester.pumpAndSettle();
      await tester.tap(find.text('14'));
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      expect(find.text('(Today) February 25, 2020'), findsNothing);
      expect(find.text('February 14, 2020'), findsOneWidget);
    });

    testWidgets('Time picker', (WidgetTester tester) async {
      await tester
          .pumpWidget(wrapWithMaterialApp(NewActivityPage(today: today)));
      await tester.pumpAndSettle();
      expect(find.text('3:30 PM'), findsOneWidget);
      expect(find.byIcon(AbiliaIcons.plus), findsOneWidget);

      await tester.tap(find.byKey(TestKey.startTimePicker));

      await tester.pumpAndSettle();
      final Offset center = tester
          .getCenter(find.byKey(const ValueKey<String>('time-picker-dial')));
      final Offset hour3 = Offset(center.dx + 50.0, center.dy);
      final Offset hour9 = Offset(center.dx - 50.0, center.dy);
      await tester.tapAt(hour3);
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();
      expect(find.text('12:30 PM'), findsNothing);
      expect(find.text('3:30 PM'), findsOneWidget);

      await tester.tap(find.byKey(TestKey.endTimePicker));
      await tester.pumpAndSettle();
      await tester.tapAt(hour9);
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();
      expect(find.text('3:30 PM'), findsOneWidget);
      expect(find.text('9:30 PM'), findsOneWidget);
    });

    testWidgets('Category picker', (WidgetTester tester) async {
      final rightRadioKey = ObjectKey(TestKey.rightCategoryRadio);
      final leftRadioKey = ObjectKey(TestKey.leftCategoryRadio);
      await tester
          .pumpWidget(wrapWithMaterialApp(NewActivityPage(today: today)));
      await tester.pumpAndSettle();
      final leftCategoryRadio1 = tester.widget<Radio>(find.byKey(leftRadioKey));
      final rightCategoryRadio1 =
          tester.widget<Radio>(find.byKey(rightRadioKey));

      expect(leftCategoryRadio1.groupValue, leftCategoryRadio1.value);
      expect(rightCategoryRadio1.groupValue, isNot(rightCategoryRadio1.value));

      await tester.tap(find.byKey(TestKey.rightCategoryRadio));
      await tester.pumpAndSettle();
      final leftCategoryRadio2 = tester.widget<Radio>(find.byKey(leftRadioKey));
      final rightCategoryRadio2 =
          tester.widget<Radio>(find.byKey(rightRadioKey));

      expect(leftCategoryRadio2.groupValue, isNot(leftCategoryRadio2.value));
      expect(rightCategoryRadio2.groupValue, rightCategoryRadio2.value);

      await tester.tap(find.byKey(TestKey.leftCategoryRadio));
      await tester.pumpAndSettle();
      final leftCategoryRadio3 = tester.widget<Radio>(find.byKey(leftRadioKey));
      final rightCategoryRadio3 =
          tester.widget<Radio>(find.byKey(rightRadioKey));

      expect(leftCategoryRadio3.groupValue, leftCategoryRadio3.value);
      expect(rightCategoryRadio3.groupValue, isNot(rightCategoryRadio3.value));
    });

    testWidgets('Availible for dialog', (WidgetTester tester) async {
      await tester
          .pumpWidget(wrapWithMaterialApp(NewActivityPage(today: today)));
      await tester.pumpAndSettle();
      await scrollDown(tester);
      await tester.pumpAndSettle();

      expect(find.byKey(TestKey.availibleFor), findsOneWidget);
      expect(find.text(translate.onlyMe), findsNothing);
      expect(find.byIcon(AbiliaIcons.password_protection), findsNothing);
      await tester.tap(find.byKey(TestKey.availibleFor));
      await tester.pumpAndSettle();
      expect(find.byType(SelectAvailableForDialog), findsOneWidget);
      await tester.tap(find.byKey(TestKey.onlyMe));
      await tester.pumpAndSettle();
      expect(find.text(translate.onlyMe), findsOneWidget);
      expect(find.byIcon(AbiliaIcons.password_protection), findsOneWidget);
    });
  });
}
