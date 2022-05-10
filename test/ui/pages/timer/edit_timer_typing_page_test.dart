import 'package:flutter_test/flutter_test.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/ui/all.dart';

import '../../../fakes/all.dart';
import '../../../test_helpers/navigation_observer.dart';

final navObserver = NavObserver();

void main() {
  Widget wrapWithMaterialApp({Duration initialDuration = Duration.zero}) =>
      MaterialApp(
        supportedLocales: Translator.supportedLocals,
        navigatorObservers: [navObserver],
        localizationsDelegates: const [Translator.delegate],
        localeResolutionCallback: (locale, supportedLocales) => supportedLocales
            .firstWhere((l) => l.languageCode == locale?.languageCode,
                orElse: () => supportedLocales.first),
        home: BlocProvider<SettingsCubit>(
            create: (context) => SettingsCubit(
                  settingsDb: FakeSettingsDb(),
                ),
            child: EditTimerDurationPage(
              initialDuration: initialDuration,
            )),
      );

  testWidgets('Page visible', (WidgetTester tester) async {
    await tester.pumpWidget(wrapWithMaterialApp());
    await tester.pumpAndSettle();
    expect(find.byType(EditTimerDurationPage), findsOneWidget);
  });

  testWidgets('initialDuration displayed correctly',
      (WidgetTester tester) async {
    await tester.pumpWidget(wrapWithMaterialApp(
        initialDuration: const Duration(hours: 12, minutes: 34)));
    await tester.pumpAndSettle();
    expect(find.text('12'), findsOneWidget);
    expect(find.text('34'), findsOneWidget);
  });

  testWidgets('Page cancelled', (WidgetTester tester) async {
    await tester.pumpWidget(wrapWithMaterialApp());
    await tester.pumpAndSettle();
    await tester.tap(find.byType(CancelButton));
    await tester.pumpAndSettle();
    final popped = navObserver.routesPoped;
    expect(popped, hasLength(0));
  });

  testWidgets('Enter 45 minutes', (WidgetTester tester) async {
    await tester.pumpWidget(wrapWithMaterialApp());
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(TestKey.keyPadNumber(4)));
    await tester.tap(find.byKey(TestKey.keyPadNumber(5)));
    expect(find.text('45'), findsOneWidget);
  });

  testWidgets('Save 45 minutes', (WidgetTester tester) async {
    await tester.pumpWidget(wrapWithMaterialApp());
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(TestKey.keyPadNumber(4)));
    await tester.tap(find.byKey(TestKey.keyPadNumber(5)));
    await tester.pumpAndSettle();
    expect(find.text('45'), findsOneWidget);
    await tester.tap(find.byType(SaveButton));
    await tester.pumpAndSettle();
    final popped = navObserver.routesPoped;
    expect(popped, hasLength(1));
    final res = await popped.first.popped;
    expect(res, const Duration(minutes: 45));
    navObserver.routesPoped.clear();
  });

  testWidgets('Enter and save 2 hours and 15 minutes',
      (WidgetTester tester) async {
    await tester.pumpWidget(wrapWithMaterialApp());
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(TestKey.keyPadNumber(1)));
    await tester.tap(find.byKey(TestKey.keyPadNumber(5)));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(TestKey.hours));
    await tester.tap(find.byKey(TestKey.keyPadNumber(2)));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(SaveButton));
    await tester.pumpAndSettle();
    final popped = navObserver.routesPoped;
    expect(popped, hasLength(1));
    final res = await popped.first.popped;
    expect(res, const Duration(hours: 2, minutes: 15));
    navObserver.routesPoped.clear();
  });

  testWidgets('Try enter 97 minutes', (WidgetTester tester) async {
    await tester.pumpWidget(wrapWithMaterialApp());
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(TestKey.keyPadNumber(9)));
    await tester.tap(find.byKey(TestKey.keyPadNumber(7)));
    await tester.pumpAndSettle();
    expect(find.text('97'), findsNothing);
    expect(find.text('07'), findsOneWidget);
  });

  testWidgets('Try enter 32 hours', (WidgetTester tester) async {
    await tester.pumpWidget(wrapWithMaterialApp());
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(TestKey.hours));
    await tester.tap(find.byKey(TestKey.keyPadNumber(3)));
    await tester.tap(find.byKey(TestKey.keyPadNumber(2)));
    await tester.pumpAndSettle();
    expect(find.text('32'), findsNothing);
    expect(find.text('03'), findsOneWidget);
  });
}
