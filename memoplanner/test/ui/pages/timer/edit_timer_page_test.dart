import 'package:flutter_test/flutter_test.dart';
import 'package:memoplanner/bloc/all.dart';
import 'package:memoplanner/getit.dart';
import 'package:memoplanner/models/all.dart';
import 'package:memoplanner/ui/all.dart';
import 'package:memoplanner/utils/all.dart';
import 'package:seagull_fakes/all.dart';

import '../../../fakes/all.dart';
import '../../../mocks/mocks.dart';
import '../../../test_helpers/enter_text.dart';
import '../../../test_helpers/register_fallback_values.dart';

void main() {
  late EditTimerCubit editTimerCubit;
  late TimerCubit timerCubit;
  late Ticker fakeTicker;

  Widget wrapWithMaterialApp({
    bool editTemplateTimer = false,
  }) {
    return MaterialApp(
      supportedLocales: Translator.supportedLocals,
      localizationsDelegates: const [Translator.delegate],
      localeResolutionCallback: (locale, supportedLocales) => supportedLocales
          .firstWhere((l) => l.languageCode == locale?.languageCode,
              orElse: () => supportedLocales.first),
      home: MultiBlocProvider(
        providers: [
          BlocProvider<SpeechSettingsCubit>(
            create: (context) => FakeSpeechSettingsCubit(),
          ),
          BlocProvider<EditTimerCubit>(
            create: (context) => editTimerCubit,
          ),
        ],
        child: editTemplateTimer
            ? const EditBasicTimerPage(
                title: 'template',
              )
            : const EditTimerPage(),
      ),
    );
  }

  setUp(() async {
    registerFallbackValues();
    fakeTicker = Ticker.fake(initialTime: DateTime(2022));
    final timerDb = MockTimerDb();
    when(() => timerDb.insert(any())).thenAnswer((_) => Future.value(0));
    final analytics = MockSeagullAnalytics();
    timerCubit = TimerCubit(
      timerDb: timerDb,
      ticker: fakeTicker,
      analytics: analytics,
    );
    editTimerCubit = EditTimerCubit(
      timerCubit: timerCubit,
      translate: Locales.language.values.first,
      ticker: fakeTicker,
      basicTimer: BasicTimerDataItem.fromTimer(
        AbiliaTimer(
          id: 'id',
          startTime: DateTime(2022),
          duration: Duration.zero,
        ),
      ),
    );
    GetItInitializer()
      ..database = FakeDatabase()
      ..sharedPreferences = await FakeSharedPreferences.getInstance()
      ..client = Fakes.client()
      ..analytics = analytics
      ..init();
  });

  tearDown(() => GetIt.instance.reset());

  group('Timer wheel animation', () {
    void expectAnimation(WidgetTester tester, {required bool animating}) {
      final editTimerWheelState =
          tester.state(find.byType(EditTimerWheel)) as EditTimerWheelState;
      expect(editTimerWheelState.animate, animating);
    }

    testWidgets('Timer wheel animates when creating new timer',
        (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(wrapWithMaterialApp());
      await tester.pumpAndSettle();

      // Assert
      expectAnimation(tester, animating: true);
    });

    testWidgets('Timer wheel stops animating when entering time',
        (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(wrapWithMaterialApp());
      await tester.pumpAndSettle();

      // Assert
      expectAnimation(tester, animating: true);

      // Act
      await tester.tap(find.byType(PickField));
      await tester.pumpAndSettle();
      await tester.enterTime(find.byKey(TestKey.minutes), '45');
      await tester.tap(find.byType(OkButton));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('45 minutes'), findsOneWidget);
      expectAnimation(tester, animating: false);
    });

    testWidgets('Timer wheel stops animating when tapping it',
        (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(wrapWithMaterialApp());
      await tester.pumpAndSettle();

      // Assert
      expectAnimation(tester, animating: true);

      // Act
      final wheelFinder = find.byType(TimerWheel);
      final wheelSize = tester.getSize(wheelFinder);
      final wheelCenter = tester.getCenter(wheelFinder);
      await tester.tapAt(
        wheelCenter.translate(0, wheelSize.height * 0.3),
      );
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('30 minutes'), findsOneWidget);
      expectAnimation(tester, animating: false);
    });

    testWidgets('Timer wheel does not animates when editing timer',
        (WidgetTester tester) async {
      // Act
      editTimerCubit = EditTimerCubit(
        timerCubit: timerCubit,
        translate: Locales.language.values.first,
        ticker: fakeTicker,
        basicTimer: BasicTimerDataItem.fromTimer(
          AbiliaTimer(
            id: 'id',
            startTime: DateTime(2022),
            duration: 1.seconds(),
          ),
        ),
      );
      await tester.pumpWidget(
        wrapWithMaterialApp(
          editTemplateTimer: true,
        ),
      );
      await tester.pumpAndSettle();

      // Assert
      expectAnimation(tester, animating: false);
    });

    testWidgets(
        'SGC-2284 - Clicking on the slider thumb does not move the timer',
        (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(wrapWithMaterialApp());
      await tester.pumpAndSettle();

      final wheelFinder = find.byType(TimerWheel);
      final wheelSize = tester.getSize(wheelFinder);
      final wheelCenter = tester.getCenter(wheelFinder);

      // Assert - Timer start at 00:00
      expect(find.text('00:00'), findsOneWidget);

      // Act - Tap on 59 minutes
      await tester.tapAt(
        wheelCenter.translate(10, -(wheelSize.height * 0.3)),
      );
      await tester.pumpAndSettle();

      // Assert - Timer is still at 00:00
      expect(find.text('00:00'), findsOneWidget);

      // Act - Tap on 30 minutes
      await tester.tapAt(
        wheelCenter.translate(0, wheelSize.height * 0.3),
      );
      await tester.pumpAndSettle();

      // Assert - Timer is now at 00:30
      expect(find.text('00:30'), findsOneWidget);

      // Act - Tap on 59 minutes again
      await tester.tapAt(
        wheelCenter.translate(10, -(wheelSize.height * 0.3)),
      );
      await tester.pumpAndSettle();

      // Assert - Timer is now at 01:00
      expect(find.text('01:00'), findsOneWidget);
    });
  });

  testWidgets('Analytics are correct when creating a new timer',
      (WidgetTester tester) async {
    await tester.pumpWidget(wrapWithMaterialApp());
    await tester.pumpAndSettle();

    // Act
    await tester.tap(find.byType(PickField));
    await tester.pumpAndSettle();
    await tester.enterTime(find.byKey(TestKey.minutes), '45');
    await tester.tap(find.byType(OkButton));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(StartButton));
    await tester.pumpAndSettle();

    final analytics = GetIt.I<SeagullAnalytics>() as MockSeagullAnalytics;
    verify(
      () => analytics.trackEvent(
        AnalyticsEvents.timerStarted,
        properties: {
          'From Template': true,
          'Duration': 45,
          'Image': false,
          'Title Changed': false,
          'Set Type': TimerSetType.inputField.name,
        },
      ),
    );
  });
}
