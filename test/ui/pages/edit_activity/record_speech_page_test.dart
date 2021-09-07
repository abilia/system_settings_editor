import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/models/all.dart';

import 'package:seagull/ui/all.dart';
import 'package:seagull/ui/pages/edit_activity/record_sound_page.dart';

import '../../../mocks_and_fakes/fake_authenticated_blocs_provider.dart';
import '../../../mocks_and_fakes/fake_db_and_repository.dart';
import '../../../mocks_and_fakes/fakes_blocs.dart';

void main() {
  group('Record page test', () {
    Widget wrapWithMaterialApp(Widget widget) => MaterialApp(
          supportedLocales: Translator.supportedLocals,
          localizationsDelegates: [Translator.delegate],
          localeResolutionCallback: (locale, supportedLocales) =>
              supportedLocales.firstWhere(
                  (l) => l.languageCode == locale?.languageCode,
                  orElse: () => supportedLocales.first),
          builder: (context, child) => FakeAuthenticatedBlocsProvider(
            child: MultiBlocProvider(providers: [
              BlocProvider<SortableBloc>.value(
                value: FakeSortableBloc(),
              ),
              BlocProvider<UserFileBloc>(
                create: (context) => UserFileBloc(
                  fileStorage: FakeFileStorage(),
                  pushBloc: FakePushBloc(),
                  syncBloc: FakeSyncBloc(),
                  userFileRepository: FakeUserFileRepository(),
                ),
              ),
              BlocProvider<SettingsBloc>(
                create: (context) => SettingsBloc(
                  settingsDb: FakeSettingsDb(),
                ),
              ),
            ], child: child!),
          ),
          home: widget,
        );

    testWidgets('record page smoke test no previous file',
        (WidgetTester tester) async {
      await tester.pumpWidget(wrapWithMaterialApp(
          RecordSoundPage(originalSoundFile: AbiliaFile.empty)));
      await tester.pumpAndSettle();
      expect(find.byType(RecordSoundPage), findsOneWidget);
      expect(find.byType(StoppedEmptyState), findsOneWidget);
      expect(find.byType(RecordAudioButton), findsOneWidget);
    });

    // testWidgets('record page smoke test existing previous file',
    //     (WidgetTester tester) async {
    //   await tester.pumpWidget(wrapWithMaterialApp(RecordSoundPage(
    //       originalSoundFile: AbiliaFile.from(path: 'testfile', id: 'jksd'))));
    //   await tester.pumpAndSettle();
    //   expect(find.byType(RecordSoundPage), findsOneWidget);
    //   expect(find.byType(StoppedNotEmptyState), findsOneWidget);
    //   // expect(find.byType(ActionButton), findsOneWidget);
    // });

    // These won't work for some reason. The cubit isn't emitting?
    //   testWidgets('record delete file', (WidgetTester tester) async {
    //     await tester.pumpWidget(
    //         wrapWithMaterialApp(RecordSpeechPage(originalSoundFile: 'testfile')));
    //     await tester.pumpAndSettle();
    //     expect(find.byType(StoppedNotEmptyState), findsOneWidget);
    //     await tester.tap(find.byType(ActionButton));
    //     await tester.pumpAndSettle();
    //     expect(find.byType(StoppedEmptyState), findsOneWidget);
    //     expect(find.byType(RecordAudioButton), findsOneWidget);
    //   });
    //
    //   testWidgets('test record', (WidgetTester tester) async {
    //     await tester.pumpWidget(
    //         wrapWithMaterialApp(RecordSpeechPage(originalSoundFile: '')));
    //     await tester.pumpAndSettle();
    //     await tester.tap(find.byType(RecordAudioButton));
    //     await tester.pumpAndSettle();
    //     expect(find.byType(RecordingState), findsOneWidget);
    //     await tester.tap(find.byType(StopButton));
    //     await tester.pumpAndSettle();
    //     expect(find.byType(StoppedNotEmptyState), findsOneWidget);
    //   });
  });
}
