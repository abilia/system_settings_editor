import 'package:flutter_test/flutter_test.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/ui/all.dart';
import 'package:seagull/utils/all.dart';

import '../../../fakes/all.dart';
import '../../../mocks/mock_bloc.dart';

void main() {
  late MockWakeLockCubit mockWakeLockCubit;
  const translate = EN();
  const baseState = WakeLockState(
    keepScreenAwakeSettings: KeepScreenAwakeSettings(),
  );

  setUp(() {
    mockWakeLockCubit = MockWakeLockCubit();
  });

  Widget wrapWithMaterialApp(Widget widget) => MaterialApp(
        supportedLocales: Translator.supportedLocals,
        localizationsDelegates: const [Translator.delegate],
        localeResolutionCallback: (locale, supportedLocales) => supportedLocales
            .firstWhere((l) => l.languageCode == locale?.languageCode,
                orElse: () => supportedLocales.first),
        home: MultiBlocProvider(providers: [
          BlocProvider<ClockBloc>(
            create: (context) => ClockBloc.fixed(DateTime(1919)),
          ),
          BlocProvider<MemoplannerSettingBloc>(
            create: (context) => FakeMemoplannerSettingsBloc(),
          ),
          BlocProvider<SpeechSettingsCubit>(
            create: (context) => FakeSpeechSettingsCubit(),
          ),
          BlocProvider<WakeLockCubit>.value(value: mockWakeLockCubit),
        ], child: widget),
      );

  testWidgets('Timeout set to one minute', (WidgetTester tester) async {
    const time = Duration(minutes: 1);

    when(() => mockWakeLockCubit.state).thenReturn(
      baseState.copyWith(screenTimeout: time),
    );
    await tester
        .pumpWidget(wrapWithMaterialApp(const ScreenTimeoutPickField()));
    await tester.pumpAndSettle();

    expect(find.text(time.toDurationString(translate)), findsOneWidget);
  }, skip: !Config.isMP);

  testWidgets('Timeout set to 30 minutes', (WidgetTester tester) async {
    const time = Duration(minutes: 30);
    when(() => mockWakeLockCubit.state).thenReturn(
      baseState.copyWith(screenTimeout: time),
    );
    await tester
        .pumpWidget(wrapWithMaterialApp(const ScreenTimeoutPickField()));
    await tester.pumpAndSettle();

    expect(find.text(time.toDurationString(translate)), findsOneWidget);
  }, skip: !Config.isMP);

  testWidgets('Timeout disabled', (WidgetTester tester) async {
    when(() => mockWakeLockCubit.state).thenReturn(
      baseState.copyWith(
        keepScreenAwakeSettings: const KeepScreenAwakeSettings(
          keepScreenOnAlways: true,
        ),
      ),
    );
    await tester
        .pumpWidget(wrapWithMaterialApp(const ScreenTimeoutPickField()));
    await tester.pumpAndSettle();

    expect(find.text(translate.alwaysOn), findsOneWidget);
  }, skip: !Config.isMP);
}
