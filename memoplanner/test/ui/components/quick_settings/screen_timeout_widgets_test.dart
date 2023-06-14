import 'package:flutter_test/flutter_test.dart';
import 'package:memoplanner/bloc/all.dart';
import 'package:memoplanner/ui/all.dart';
import 'package:memoplanner/utils/all.dart';

import '../../../fakes/all.dart';
import '../../../mocks/mock_bloc.dart';

void main() {
  late MockWakeLockCubit mockWakeLockCubit;
  late final Lt translate;
  const baseState = WakeLockState(hasBattery: true);

  setUp(() async {
    translate = await Lt.load(Lt.supportedLocales.first);
    mockWakeLockCubit = MockWakeLockCubit();
  });

  Widget wrapWithMaterialApp(Widget widget) => MaterialApp(
        supportedLocales: Lt.supportedLocales,
        localizationsDelegates: const [Lt.delegate],
        localeResolutionCallback: (locale, supportedLocales) => supportedLocales
            .firstWhere((l) => l.languageCode == locale?.languageCode,
                orElse: () => supportedLocales.first),
        home: MultiBlocProvider(providers: [
          BlocProvider<ClockBloc>(
            create: (context) => ClockBloc.fixed(DateTime(1919)),
          ),
          BlocProvider<MemoplannerSettingsBloc>(
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
        screenTimeout: maxScreenTimeoutDuration,
      ),
    );
    await tester
        .pumpWidget(wrapWithMaterialApp(const ScreenTimeoutPickField()));
    await tester.pumpAndSettle();

    expect(find.text(translate.alwaysOn), findsOneWidget);
  }, skip: !Config.isMP);
}
