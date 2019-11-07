import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:seagull/main.dart';
import 'package:seagull/fakes/fake_client.dart';
import 'package:seagull/ui/pages.dart';

import '../bloc/mocks.dart';

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
  });
}
