import 'package:flutter_test/flutter_test.dart';
import 'package:seagull/ui/all.dart';
import 'package:seagull/ui/components/custom_num_pad.dart';

void main() {
  testWidgets('Build AbiliaNumPad', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
        home: Material(
      child: AbiliaNumPad(
          delete: () => {}, onClear: () => {}, onNumPress: (value) => value),
    )));

    await tester.pump();
    expect(find.byKey(TestKey.numPadButton), findsNWidgets(10));
    expect(find.byKey(TestKey.numPadActionButton), findsNWidgets(2));
    expect(find.text('0'), findsOneWidget);
    expect(find.text('1'), findsOneWidget);
    expect(find.text('2'), findsOneWidget);
    expect(find.text('3'), findsOneWidget);
    expect(find.text('4'), findsOneWidget);
    expect(find.text('5'), findsOneWidget);
    expect(find.text('6'), findsOneWidget);
    expect(find.text('7'), findsOneWidget);
    expect(find.text('8'), findsOneWidget);
    expect(find.text('9'), findsOneWidget);
  });
}
