import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/ui/all.dart';

import '../../../fakes/all.dart';
import '../../../mocks/mocks.dart';

void main() {
  final mockConnectivity = MockConnectivity();
  final translate = Locales.language.values.first;

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
          BlocProvider<MemoplannerSettingsBloc>(
            create: (context) => FakeMemoplannerSettingsBloc(),
          ),
          BlocProvider<SpeechSettingsCubit>(
            create: (context) => FakeSpeechSettingsCubit(),
          ),
        ], child: widget),
      );

  testWidgets('Not connected shows no wifi icon', (WidgetTester tester) async {
    when(() => mockConnectivity.onConnectivityChanged)
        .thenAnswer((_) => Stream.value(ConnectivityResult.none));
    when(() => mockConnectivity.checkConnectivity())
        .thenAnswer((_) => Future.value(ConnectivityResult.none));
    await tester.pumpWidget(wrapWithMaterialApp(WiFiPickField(
      connectivity: mockConnectivity,
    )));
    await tester.pumpAndSettle();
    expect(find.byIcon(AbiliaIcons.noWifi), findsOneWidget);
    expect(find.text(translate.notConnected), findsOneWidget);
  });

  testWidgets('Connected shows wifi icon', (WidgetTester tester) async {
    when(() => mockConnectivity.onConnectivityChanged)
        .thenAnswer((_) => Stream.value(ConnectivityResult.wifi));
    when(() => mockConnectivity.checkConnectivity())
        .thenAnswer((_) => Future.value(ConnectivityResult.wifi));
    await tester.pumpWidget(wrapWithMaterialApp(WiFiPickField(
      connectivity: mockConnectivity,
    )));
    await tester.pumpAndSettle();
    expect(find.byIcon(AbiliaIcons.wifi), findsOneWidget);
    expect(find.text(translate.connected), findsOneWidget);
  });
}
