import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:seagull/bloc/all.dart';
import 'package:seagull/ui/all.dart';

import '../../fakes/fake_db_and_repository.dart';

void main() {
  testWidgets('Bug SGC-516 No style in error message', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider<SettingsBloc>(
          create: (context) => SettingsBloc(settingsDb: FakeSettingsDb()),
          child: const ErrorMessage(text: Text('')),
        ),
      ),
    );
    await tester.pump();
    final richtext = tester.widget<RichText>(find.byType(RichText));
    expect(richtext.text.style?.fontFamily, 'Roboto');
  });
}
