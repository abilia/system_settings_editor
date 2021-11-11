import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/ui/all.dart';

import '../../../fakes/all.dart';
import '../../../mocks/mocks.dart';

void main() {
  final mockNetworkInfo = MockNetworkInfo();

  Widget wrapWithMaterialApp(Widget widget) => MaterialApp(
        supportedLocales: Translator.supportedLocals,
        localizationsDelegates: const [Translator.delegate],
        localeResolutionCallback: (locale, supportedLocales) => supportedLocales
            .firstWhere((l) => l.languageCode == locale?.languageCode,
                orElse: () => supportedLocales.first),
        home: MultiBlocProvider(providers: [
          BlocProvider<ClockBloc>(
            create: (context) => ClockBloc(StreamController<DateTime>().stream,
                initialTime: DateTime(1919)),
          ),
          BlocProvider<MemoplannerSettingBloc>(
            create: (context) => FakeMemoplannerSettingsBloc(),
          ),
          BlocProvider<SettingsBloc>(
            create: (context) => SettingsBloc(
              settingsDb: FakeSettingsDb(),
            ),
          ),
        ], child: widget),
      );

  testWidgets('Not connected', (WidgetTester tester) async {
    when(() => mockNetworkInfo.getWifiName())
        .thenAnswer((_) => Future.value(null));
    await tester.pumpWidget(wrapWithMaterialApp(WiFiPickField(
      networkInfo: mockNetworkInfo,
      locationPermission: PermissionStatus.granted,
    )));
    await tester.pumpAndSettle();
    expect(find.byIcon(AbiliaIcons.noWifi), findsOneWidget);
  });

  testWidgets('Connected', (WidgetTester tester) async {
    const networkName = 'my network';
    when(() => mockNetworkInfo.getWifiName())
        .thenAnswer((_) => Future.value(networkName));
    await tester.pumpWidget(wrapWithMaterialApp(WiFiPickField(
      networkInfo: mockNetworkInfo,
      locationPermission: PermissionStatus.granted,
    )));
    await tester.pumpAndSettle();
    expect(find.byIcon(AbiliaIcons.wifi), findsOneWidget);
    expect(find.text(networkName), findsOneWidget);
  });
}
