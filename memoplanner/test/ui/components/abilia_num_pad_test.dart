import 'package:flutter_test/flutter_test.dart';
import 'package:memoplanner/bloc/all.dart';
import 'package:memoplanner/ui/all.dart';
import '../../fakes/all.dart';

void main() {
  testWidgets('Build AbiliaNumPad', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
        home: Material(
            child: BlocProvider<SpeechSettingsCubit>(
      create: (_) => FakeSpeechSettingsCubit(),
      child: AbiliaNumPad(
          delete: () => {}, onClear: () => {}, onNumPress: (value) => value),
    ))));

    await tester.pump();
    expect(find.byType(KeyboardNumberButton), findsNWidgets(10));
    expect(find.byType(KeyboardActionButton), findsNWidgets(2));
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
