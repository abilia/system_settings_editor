import 'dart:async';

import 'package:carymessenger/l10n/all.dart';
import 'package:carymessenger/main.dart';
import 'package:carymessenger/ui/pages/onboarding/connect_to_wifi/connect_to_wifi_page.dart';
import 'package:carymessenger/ui/pages/onboarding/login/login_page.dart';
import 'package:connectivity/connectivity_cubit.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mocktail/mocktail.dart';
import 'package:seagull_fakes/all.dart';

import '../../../fakes/fake_getit.dart';
import '../../../mocks/mock_connectivity.dart';

void main() {
  late MockConnectivity mockConnectivity;
  late StreamController<ConnectivityResult> connectivityStream;
  setUp(() async {
    mockConnectivity = MockConnectivity();
    connectivityStream = StreamController<ConnectivityResult>();
    when(() => mockConnectivity.checkConnectivity())
        .thenAnswer((invocation) async => ConnectivityResult.none);
    when(() => mockConnectivity.onConnectivityChanged)
        .thenAnswer((_) => connectivityStream.stream);
    setupPermissions();
    initGetItFakes(connectivity: mockConnectivity);
  });

  setUpAll(() async {
    await Lokalise.initMock();
  });

  tearDown(() async {
    GetIt.I.reset();
    await connectivityStream.close();
  });

  testWidgets(
      'no wifi shows connect to wifi page, '
      'when wifi connect, show login page', (tester) async {
    await tester.pumpWidget(const CaryMobileApp());
    await tester.pumpAndSettle();
    expect(find.byType(ConnectToWifiPage), findsOneWidget);
    connectivityStream.add(ConnectivityResult.wifi);
    await tester.pumpAndSettle();
    expect(find.byType(LoginPage), findsOneWidget);
  });

  testWidgets(
      'if wifi shows login page, '
      'when no wifi connect, show connect to wifi page', (tester) async {
    when(() => mockConnectivity.checkConnectivity())
        .thenAnswer((invocation) async => ConnectivityResult.wifi);
    await tester.pumpWidget(const CaryMobileApp());
    await tester.pumpAndSettle();
    expect(find.byType(LoginPage), findsOneWidget);
    connectivityStream.add(ConnectivityResult.none);
    await tester.pumpAndSettle();
    expect(find.byType(ConnectToWifiPage), findsOneWidget);
  });
}
