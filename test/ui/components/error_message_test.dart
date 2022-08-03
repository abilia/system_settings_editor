import 'package:flutter_test/flutter_test.dart';

import 'package:seagull/bloc/all.dart';
import 'package:seagull/ui/all.dart';

import '../../fakes/all.dart';

void main() {
  testWidgets('Bug SGC-516 No style in error message', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider<SpeechSettingsCubit>(
          create: (context) => FakeSpeechSettingsCubit(),
          child: const ErrorMessage(text: Text('')),
        ),
      ),
    );
    await tester.pump();
    final richtext = tester.widget<RichText>(find.byType(RichText));
    expect(richtext.text.style?.fontFamily, 'Roboto');
  });
}
