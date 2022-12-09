import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart';
import 'package:memoplanner/bloc/all.dart';

import 'package:memoplanner/db/all.dart';
import 'package:memoplanner/getit.dart';
import 'package:memoplanner/ui/all.dart';

import '../../../fakes/all.dart';
import '../../../mocks/mocks.dart';
import '../../../test_helpers/app_pumper.dart';

void main() {
  group('Startup', () {
    late MockConnectivity mockConnectivity;
    late DeviceDb deviceDb;
    Response connectLicenseResponse = Fakes.connectLicenseSuccessResponses;

    setUp(() async {
      deviceDb = MockDeviceDb();
      when(() => deviceDb.startGuideCompleted).thenReturn(false);

      mockConnectivity = MockConnectivity();
      when(() => mockConnectivity.onConnectivityChanged)
          .thenAnswer((invocation) => Stream.value(ConnectivityResult.wifi));
      when(() => mockConnectivity.checkConnectivity())
          .thenAnswer((invocation) => Future.value(ConnectivityResult.wifi));

      GetItInitializer()
        ..sharedPreferences =
            await FakeSharedPreferences.getInstance(loggedIn: false)
        ..database = FakeDatabase()
        ..deviceDb = deviceDb
        ..client = Fakes.client(
          connectLicenseResponse: () => connectLicenseResponse,
        )
        ..connectivity = mockConnectivity
        ..connectivityCheck = ((_) async => true)
        ..init();
    });

    tearDown(() async {
      setupPermissions();
      await GetIt.I.reset();
      connectLicenseResponse = connectLicenseResponse;
    });

    group('production page', () {
      setUp(() {
        when(() => deviceDb.serialId).thenReturn('');
      });
      testWidgets('When empty serial number production guide is shown',
          (WidgetTester tester) async {
        await tester.pumpApp();
        expect(find.byType(ProductionGuidePage), findsOneWidget);
      });
    });

    group('Start up guide', () {
      setUp(() {
        when(() => deviceDb.serialId).thenReturn('serialId');
      });

      testWidgets('Can navigate to page one (Wifi page)',
          (WidgetTester tester) async {
        await tester.pumpApp();
        expect(find.byType(WelcomePage), findsOneWidget);
        await tester.tap(find.byKey(TestKey.startWelcomeGuide));
        await tester.pumpAndSettle();
        expect(find.byType(PageOneWifi), findsOneWidget);
      });

      testWidgets(
          'Can navigate to page two (Speech support), when license connected',
          (WidgetTester tester) async {
        await tester.pumpApp();
        await tester.tap(find.byKey(TestKey.startWelcomeGuide));
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(TestKey.nextWelcomeGuide));
        await tester.pumpAndSettle();
        expect(find.byType(PageTwoVoiceSupport), findsOneWidget);
      });

      group('failed to connect with license', () {
        setUp(() {
          connectLicenseResponse = Response('', 404);
        });

        testWidgets(
            "Can't navigate to page two when no license connected, when license connected",
            (WidgetTester tester) async {
          await tester.pumpApp();
          await tester.tap(find.byKey(TestKey.startWelcomeGuide));
          await tester.pumpAndSettle();
          expect(find.byKey(TestKey.nextWelcomeGuide), findsNothing);
          expect(find.text(const EN().wifiNoInternet), findsOneWidget);
        });
      });

      group('no connected license', () {
        setUp(() {
          connectLicenseResponse =
              Response('{"serialNumber" : "serialNumber"}', 200);
        });

        testWidgets(
            'navigate to page two (Connect license) when no license connected',
            (WidgetTester tester) async {
          await tester.pumpApp();
          await tester.tap(find.byKey(TestKey.startWelcomeGuide));
          await tester.pumpAndSettle();
          await tester.tap(find.byKey(TestKey.nextWelcomeGuide));
          await tester.pumpAndSettle();
          expect(find.byType(PageTwoConnectedLicense), findsOneWidget);
        });

        testWidgets('license not found, then found and success',
            (WidgetTester tester) async {
          await tester.pumpApp();
          await tester.tap(find.byKey(TestKey.startWelcomeGuide));
          await tester.pumpAndSettle();
          await tester.tap(find.byKey(TestKey.nextWelcomeGuide));
          await tester.pumpAndSettle();
          // No able to press button
          expect(
            tester
                .widget<TextButton>(find.byKey(TestKey.nextWelcomeGuide))
                .onPressed,
            isNull,
          );
          // Respond with no license found
          connectLicenseResponse = Response(
            '''{
              "status" : 400,
              "message" : "No license with key 555555555555 found in database.",
              "errorId" : 67,
              "errors" : [
                {
                  "code": "WHALE-0801",
                  "message": "Provided license key does not exist"
                }
              ]
            }''',
            400,
          );

          await tester.enterText(find.byType(TextField), '111122223333');
          await tester.pumpAndSettle();
          // Error message
          expect(find.text(const EN().licenseErrorNotFound), findsOneWidget);
          // Not able to press button
          expect(
            tester
                .widget<TextButton>(find.byKey(TestKey.nextWelcomeGuide))
                .onPressed,
            isNull,
          );
          // Success response
          connectLicenseResponse = Fakes.connectLicenseSuccessResponses;
          // remove field
          await tester.enterText(find.byType(TextField), '');
          await tester.pumpAndSettle();
          expect(
            tester
                .widget<TextButton>(find.byKey(TestKey.nextWelcomeGuide))
                .onPressed,
            isNull,
          );
          expect(find.text(const EN().licenseErrorNotFound), findsNothing);
          await tester.enterText(find.byType(TextField), '444455556666');
          await tester.pumpAndSettle();

          // Now connected with license, can proceed to next page
          await tester.tap(find.byKey(TestKey.nextWelcomeGuide));
          await tester.pumpAndSettle();
          expect(find.byType(PageTwoVoiceSupport), findsOneWidget);
        });
      });
    });
  }, skip: !Config.isMP);
}
