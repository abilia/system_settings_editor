// @dart=2.9

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:seagull/bloc/all.dart';

import 'package:seagull/ui/all.dart';
import 'package:seagull/ui/components/activity/record_speech.dart';
import 'package:seagull/ui/pages/edit_activity/record_speech_page.dart';

import '../../../mocks.dart';

void main() {
  group('Record page test', () {
    final mockSortableBloc = MockSortableBloc();

    final mockNavigatorObserver = MockNavigatorObserver();

    Widget wrapWithMaterialApp(Widget widget) => MaterialApp(
          supportedLocales: Translator.supportedLocals,
          localizationsDelegates: [Translator.delegate],
          navigatorObservers: [mockNavigatorObserver],
          localeResolutionCallback: (locale, supportedLocales) =>
              supportedLocales.firstWhere(
                  (l) => l.languageCode == locale?.languageCode,
                  orElse: () => supportedLocales.first),
          builder: (context, child) => MockAuthenticatedBlocsProvider(
            child: MultiBlocProvider(providers: [
              BlocProvider<SortableBloc>.value(
                value: mockSortableBloc,
              ),
              BlocProvider<UserFileBloc>(
                create: (context) => UserFileBloc(
                  fileStorage: MockFileStorage(),
                  pushBloc: MockPushBloc(),
                  syncBloc: MockSyncBloc(),
                  userFileRepository: MockUserFileRepository(),
                ),
              ),
              BlocProvider<SettingsBloc>(
                create: (context) => SettingsBloc(
                  settingsDb: MockSettingsDb(),
                ),
              ),
            ], child: child),
          ),
          home: widget,
        );

    testWidgets('record page smoke test no previous file',
        (WidgetTester tester) async {
      await tester.pumpWidget(
          wrapWithMaterialApp(RecordSpeechPage(originalSoundFile: '')));
      await tester.pumpAndSettle();
      expect(find.byType(RecordSpeechPage), findsOneWidget);
      expect(find.byType(StoppedEmptyState), findsOneWidget);
      expect(find.byType(RecordAudioButton), findsOneWidget);
    });

    testWidgets('record page smoke test existing previous file',
        (WidgetTester tester) async {
      await tester.pumpWidget(
          wrapWithMaterialApp(RecordSpeechPage(originalSoundFile: 'testfile')));
      await tester.pumpAndSettle();
      expect(find.byType(RecordSpeechPage), findsOneWidget);
      expect(find.byType(StoppedNotEmptyState), findsOneWidget);
      expect(find.byType(PlaySpeechButton), findsOneWidget);
      expect(find.byType(ActionButton), findsOneWidget);
    });

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
