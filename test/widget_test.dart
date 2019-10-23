import 'package:flutter_test/flutter_test.dart';
import 'package:seagull/main.dart';
import 'package:seagull/ui/pages/login_page.dart';

void main() {
  testWidgets('Application starts', (WidgetTester tester) async {
    await tester.pumpWidget(App());
    await tester.pumpAndSettle();
    expect(find.text('Password'), findsOneWidget);
    expect(find.byWidgetPredicate((w) => w is LoginPage), findsOneWidget);
  });
}
