import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:memoplanner/bloc/all.dart';

import 'package:memoplanner/ui/all.dart';

import '../../../fakes/all.dart';
import '../../../mocks/mocks.dart';

void main() {
  final mockConnectivity = MockConnectivity();
  late MockMyAbiliaConnection mockMyAbiliaConnection;
  late final Lt translate;

  setUpAll(() async {
    await Lokalise.initMock();
    translate = await Lt.load(Lt.supportedLocales.first);
  });

  setUp(() {
    mockMyAbiliaConnection = MockMyAbiliaConnection();
    when(() => mockMyAbiliaConnection.hasConnection())
        .thenAnswer((invocation) async => true);
    when(() => mockConnectivity.onConnectivityChanged)
        .thenAnswer((_) => Stream.value(ConnectivityResult.none));
    when(() => mockConnectivity.checkConnectivity())
        .thenAnswer((_) => Future.value(ConnectivityResult.none));
  });

  Widget wrapWithMaterialApp(Widget widget) => MaterialApp(
        localizationsDelegates: const [Lt.delegate],
        localeResolutionCallback: (locale, supportedLocales) => supportedLocales
            .firstWhere((l) => l.languageCode == locale?.languageCode,
                orElse: () => supportedLocales.first),
        home: MultiBlocProvider(providers: [
          BlocProvider<ClockCubit>(
            create: (context) => ClockCubit.fixed(DateTime(1919)),
          ),
          BlocProvider<MemoplannerSettingsBloc>(
            create: (context) => FakeMemoplannerSettingsBloc(),
          ),
          BlocProvider<SpeechSettingsCubit>(
            create: (context) => FakeSpeechSettingsCubit(),
          ),
          BlocProvider<ConnectivityCubit>(
            create: (context) => ConnectivityCubit(
              connectivity: mockConnectivity,
              baseUrlDb: FakeBaseUrlDb(),
              myAbiliaConnection: mockMyAbiliaConnection,
            )..checkConnectivity(),
          ),
        ], child: widget),
      );

  testWidgets('Not connected shows no wifi icon', (WidgetTester tester) async {
    when(() => mockMyAbiliaConnection.hasConnection())
        .thenAnswer((invocation) async => false);
    await tester.pumpWidget(wrapWithMaterialApp(const WiFiPickField()));
    await tester.pumpAndSettle();
    expect(find.byIcon(AbiliaIcons.noWifi), findsOneWidget);
    expect(find.text(translate.notConnected), findsOneWidget);
  });

  group('Connected to wifi', () {
    setUp(() {
      when(() => mockConnectivity.onConnectivityChanged)
          .thenAnswer((_) => Stream.value(ConnectivityResult.wifi));
      when(() => mockConnectivity.checkConnectivity())
          .thenAnswer((_) => Future.value(ConnectivityResult.wifi));
    });

    testWidgets('shows wifi icon and connected internet',
        (WidgetTester tester) async {
      await tester.pumpWidget(wrapWithMaterialApp(const WiFiPickField()));
      await tester.pumpAndSettle();
      expect(find.byIcon(AbiliaIcons.wifi), findsOneWidget);
      expect(find.text(translate.connected), findsOneWidget);
    });

    testWidgets('no internet, shows icon and not connected text',
        (WidgetTester tester) async {
      when(() => mockMyAbiliaConnection.hasConnection())
          .thenAnswer((invocation) async => false);
      await tester.pumpWidget(wrapWithMaterialApp(const WiFiPickField()));
      await tester.pumpAndSettle();
      expect(find.byIcon(AbiliaIcons.wifi), findsOneWidget);
      expect(find.text(translate.connectedNoInternet), findsOneWidget);
    });
  });
}
