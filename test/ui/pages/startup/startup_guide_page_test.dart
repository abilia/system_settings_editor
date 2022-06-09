import 'package:flutter_test/flutter_test.dart';
import 'package:seagull/db/all.dart';
import 'package:seagull/getit.dart';
import 'package:seagull/ui/all.dart';

import '../../../fakes/all.dart';
import '../../../mocks/mocks.dart';
import '../../../test_helpers/app_pumper.dart';

void main() {
  const Translator _translator = Translator(Locale('en'));
  group('Startup', () {
    late DeviceDb deviceDb;
    setUp(() async {
      deviceDb = MockDeviceDb();
      GetItInitializer()
        ..sharedPreferences =
            await FakeSharedPreferences.getInstance(loggedIn: false)
        ..battery = FakeBattery()
        ..database = FakeDatabase()
        ..deviceDb = deviceDb
        ..init();
    });

    testWidgets('When empty serial number production guide is shown',
        (WidgetTester tester) async {
      when(() => deviceDb.serialId).thenReturn('');
      await tester.pumpApp();
      await tester.pumpAndSettle();
      expect(find.byType(ProductionGuidePage), findsOneWidget);
    });

    testWidgets('When non empty serial id welcome page is shown',
        (WidgetTester tester) async {
      when(() => deviceDb.serialId).thenReturn('serialId');
      when(() => deviceDb.startGuideCompleted).thenReturn('');
      await tester.pumpApp();
      await tester.pumpAndSettle();
      expect(find.byType(WelcomePage), findsOneWidget);
    });

    testWidgets('Can navigate to page one', (WidgetTester tester) async {
      when(() => deviceDb.serialId).thenReturn('serialId');
      when(() => deviceDb.startGuideCompleted).thenReturn('');
      await tester.pumpApp();
      await tester.pumpAndSettle();
      expect(find.byType(WelcomePage), findsOneWidget);

      await tester.tap(find.text(_translator.translate.start));
      await tester.pumpAndSettle();
      expect(find.byType(PageOne), findsOneWidget);
    });
  }, skip: !Config.isMP);
}
