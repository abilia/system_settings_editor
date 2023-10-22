import 'package:carymessenger/main.dart';
import 'package:carymessenger/ui/pages/main/main_page.dart';
import 'package:carymessenger/ui/widgets/clock/analog_clock.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:lokalise_flutter_sdk/lokalise_flutter_sdk.dart';
import 'package:seagull_fakes/permissions.dart';

import '../../../fakes/fake_getit.dart';

void main() {
  setUpAll(() async {
    await Lokalise.initMock();
  });

  setUp(() async {
    setupPermissions();
    initGetItFakes(loggedIn: true);
  });

  tearDown(() => GetIt.I.reset());

  testWidgets('shows when logged in', (tester) async {
    await tester.pumpWidget(const CaryMobileApp());
    await tester.pumpAndSettle();
    expect(find.byType(MainPage), findsOneWidget);
    expect(find.byType(ClockAndDate), findsOneWidget);
    expect(find.byType(AnalogClock), findsOneWidget);
    expect(find.byType(TimeDateText), findsOneWidget);
    expect(find.byType(Agenda), findsOneWidget);
    expect(find.byType(AgendaHeader), findsOneWidget);
    expect(find.byType(AgendaList), findsOneWidget);
  });
}
