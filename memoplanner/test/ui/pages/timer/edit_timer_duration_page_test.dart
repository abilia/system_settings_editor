import 'package:flutter_test/flutter_test.dart';
import 'package:lokalise_flutter_sdk/lokalise_flutter_sdk.dart';
import 'package:memoplanner/bloc/all.dart';
import 'package:memoplanner/ui/all.dart';

import '../../../fakes/all.dart';
import '../../../test_helpers/enter_text.dart';
import '../../../test_helpers/navigation_observer.dart';

final navObserver = NavObserver();

void main() {
  setUpAll(() async {
    await Lokalise.initMock();
  });
  Widget wrapWithMaterialApp({Duration initialDuration = Duration.zero}) =>
      MaterialApp(
        navigatorObservers: [navObserver],
        localizationsDelegates: const [Lt.delegate],
        localeResolutionCallback: (locale, supportedLocales) => supportedLocales
            .firstWhere((l) => l.languageCode == locale?.languageCode,
                orElse: () => supportedLocales.first),
        home: BlocProvider<SpeechSettingsCubit>(
          create: (context) => FakeSpeechSettingsCubit(),
          child: EditTimerDurationPage(
            initialDuration: initialDuration,
          ),
        ),
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
    await tester.enterTime(find.byKey(TestKey.minutes), '45');
    expect(find.text('45'), findsOneWidget);
  });

  testWidgets('Save 45 minutes', (WidgetTester tester) async {
    await tester.pumpWidget(wrapWithMaterialApp());
    await tester.pumpAndSettle();
    await tester.enterTime(find.byKey(TestKey.minutes), '45');
    expect(find.text('45'), findsOneWidget);
    await tester.tap(find.byType(OkButton));
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
    await tester.enterTime(find.byKey(TestKey.minutes), '15');
    await tester.enterTime(find.byKey(TestKey.hours), '2');
    await tester.tap(find.byType(OkButton));
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
    await tester.enterTime(find.byKey(TestKey.minutes), '97');
    expect(find.text('97'), findsNothing);
    expect(find.text('07'), findsOneWidget);
  });

  testWidgets('Try enter 32 hours', (WidgetTester tester) async {
    await tester.pumpWidget(wrapWithMaterialApp());
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(TestKey.hours));
    await tester.enterTime(find.byKey(TestKey.hours), '32');
    expect(find.text('32'), findsNothing);
    expect(find.text('03'), findsOneWidget);
  });
}
