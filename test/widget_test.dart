import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:seagull/main.dart';
import 'package:seagull/ui/pages/login_page.dart';

import 'bloc/mocks.dart';

void main() {
  testWidgets('Application starts', (WidgetTester tester) async {
    final mockSecureStorage = MockSecureStorage();
    when(mockSecureStorage.read(key: anyNamed('key')))
        .thenAnswer((_) => Future.value(null));
    await tester.pumpWidget(App(
      secureStorage: mockSecureStorage,
    ));
    await tester.pumpAndSettle();
    expect(find.text('Password'), findsOneWidget);
    expect(find.byWidgetPredicate((w) => w is LoginPage), findsOneWidget);
  });
}
