import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:seagull/fakes/fake_activities.dart';
import 'package:seagull/main.dart';
import 'package:seagull/fakes/fake_client.dart';
import 'package:seagull/ui/components.dart';
import 'package:seagull/ui/pages.dart';

import '../../mocks.dart';

void main() {
  group('calender page widget test', () {
    MockSecureStorage mockSecureStorage;

    setUp(() {
      mockSecureStorage = MockSecureStorage();
      when(mockSecureStorage.read(key: anyNamed('key')))
          .thenAnswer((_) => Future.value(Fakes.token));
    });

    testWidgets('Application starts', (WidgetTester tester) async {
      await tester.pumpWidget(App(
        Fakes.client(),
        secureStorage: mockSecureStorage,
      ));
      await tester.pumpAndSettle();
      expect(find.byType(CalenderPage), findsOneWidget);
    });

    testWidgets('Should show up empty', (WidgetTester tester) async {
      await tester.pumpWidget(App(
        Fakes.client(),
        secureStorage: mockSecureStorage,
      ));
      await tester.pumpAndSettle();
      expect(find.byType(ActivityCard), findsNothing);
    });

    testWidgets('Should show one activity', (WidgetTester tester) async {
      await tester.pumpWidget(App(
        Fakes.client([FakeActivity.onTime()]),
        secureStorage: mockSecureStorage,
      ));
      await tester.pumpAndSettle();
      expect(find.byType(ActivityCard), findsOneWidget);
    });

    testWidgets('Should not show Go to now-button', (WidgetTester tester) async {
      await tester.pumpWidget(App(
        Fakes.client([FakeActivity.onTime()]),
        secureStorage: mockSecureStorage,
      ));
      await tester.pumpAndSettle();
      expect(find.byKey(TestKey.goToNowButton), findsNothing);
    });
  });
}
