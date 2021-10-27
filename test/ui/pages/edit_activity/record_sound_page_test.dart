import 'dart:convert';
import 'dart:io';

import 'package:file/memory.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:seagull/bloc/all.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/ui/all.dart';

import '../../../fakes/all.dart';
import '../../../mocks/mocks.dart';

final _dummyFile = UnstoredAbiliaFile.forTest('testfile', 'jksd', File('nbnb'));

void main() {
  late MockRecord mockRecorder;
  const recordedBytes =
      'AAAAGGZ0eXBtcDQyAAAAAGlzb21tcDQyAAADFW1vb3YAAABsbXZoZAAAAADdaLlC3Wi5QgAAA+gAAAAAAAEAAAEAAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAIAAADqbWV0YQAAACFoZGxyAAAAAAAAAABtZHRhAAAAAAAAAAAAAAAAAAAAAGRrZXlzAAAAAAAAAAMAAAAbbWR0YWNvbS5hbmRyb2lkLnZlcnNpb24AAAAgbWR0YWNvbS5hbmRyb2lkLm1hbnVmYWN0dXJlcgAAABltZHRhY29tLmFuZHJvaWQubW9kZWwAAABdaWxzdAAAABoAAAABAAAAEmRhdGEAAAABAAAAADEwAAAAHgAAAAIAAAAWZGF0YQAAAAEAAAAAR29vZ2xlAAAAHQAAAAMAAAAVZGF0YQAAAAEAAAAAUGl4ZWwAAAG3dHJhawAAAFx0a2hkAAAAB91ouULdaLlCAAAAAQAAAAAAAAAAAAAAAAAAAAAAAAAAAQAAAAABAAAAAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAABU21kaWEAAAAgbWRoZAAAAADdaLlC3Wi5QgAArEQAAAAAAAAAAAAAACxoZGxyAAAAAAAAAABzb3VuAAAAAAAAAAAAAAAAU291bmRIYW5kbGUAAAAA/21pbmYAAAAQc21oZAAAAAAAAAAAAAAAJGRpbmYAAAAcZHJlZgAAAAAAAAABAAAADHVybCAAAAABAAAAw3N0YmwAAABbc3RzZAAAAAAAAAABAAAAS21wNGEAAAAAAAAAAQAAAAAAAAAAAAEAEAAAAACsRAAAAAAAJ2VzZHMAAAAAAxkAAAAEEUAVAAMAAAH0AAAB9AAFAhIIBgECAAAAGHN0dHMAAAAAAAAAAQAAAAEAAAAAAAAAGHN0c3oAAAAAAAAAAAAAAAEAAAFzAAAA';
  const filePath = 'hmm.m4a';
  setUp(() async {
    final fileContent = base64.decode(recordedBytes);
    File file = MemoryFileSystem().file(filePath);
    await file.writeAsBytes(fileContent);
    mockRecorder = MockRecord();
    when(() => mockRecorder.start()).thenAnswer((_) => Future.value());
    when(() => mockRecorder.stop()).thenAnswer((_) => Future.value(filePath));
    setupPermissions();
  });

  group('RecordSoundPage test', () {
    Widget wrapWithMaterialApp(
      Widget widget, {
      AbiliaFile originalSoundFile = AbiliaFile.empty,
    }) =>
        MaterialApp(
          supportedLocales: Translator.supportedLocals,
          localizationsDelegates: const [Translator.delegate],
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
              BlocProvider<PermissionBloc>(
                create: (context) => PermissionBloc(),
              ),
              BlocProvider(
                create: (context) => RecordSoundCubit(
                  record: mockRecorder,
                  originalSoundFile: originalSoundFile,
                ),
              ),
              BlocProvider<SoundCubit>(
                create: (context) => SoundCubit(
                  storage: FakeFileStorage(),
                  userFileBloc: context.read<UserFileBloc>(),
                ),
              ),
            ], child: child!),
          ),
          home: widget,
        );

    testWidgets('record page smoke test no previous file',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        wrapWithMaterialApp(RecordSoundPage()),
      );
      await tester.pumpAndSettle();
      expect(find.byType(RecordSoundPage), findsOneWidget);
      expect(find.byType(RecordAudioButton), findsOneWidget);

      expect(find.byType(PlayRecordingButton), findsNothing);
      expect(find.byType(DeleteButton), findsNothing);
      expect(find.byType(StopButton), findsNothing);
    });

    testWidgets('record page smoke test existing previous file',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        wrapWithMaterialApp(
          RecordSoundPage(),
          originalSoundFile: _dummyFile,
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(RecordSoundPage), findsOneWidget);
      expect(find.byType(PlayRecordingButton), findsOneWidget);
      expect(find.byType(DeleteButton), findsOneWidget);

      expect(find.byType(RecordAudioButton), findsNothing);
      expect(find.byType(StopButton), findsNothing);
    });

    testWidgets('delete file. check that correct state is shown afterwards.',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        wrapWithMaterialApp(
          RecordSoundPage(),
          originalSoundFile: _dummyFile,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(PlayRecordingButton), findsOneWidget);
      expect(find.byType(DeleteButton), findsOneWidget);

      expect(find.byType(RecordAudioButton), findsNothing);
      expect(find.byType(StopButton), findsNothing);

      await tester.tap(find.byIcon(AbiliaIcons.deleteAllClear));
      await tester.pumpAndSettle();

      expect(find.byType(RecordAudioButton), findsOneWidget);

      expect(find.byType(DeleteButton), findsNothing);
      expect(find.byType(StopButton), findsNothing);
      expect(find.byType(PlayRecordingButton), findsNothing);
    });

    testWidgets('test record. stop recording and check state',
        (WidgetTester tester) async {
      setupPermissions({
        Permission.microphone: PermissionStatus.granted,
      });
      await tester.pumpWidget(
        wrapWithMaterialApp(RecordSoundPage()),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byType(RecordAudioButton));
      await tester.pumpAndSettle();
      verify(() => mockRecorder.start());

      expect(find.byType(StopButton), findsOneWidget);
      await tester.tap(find.byType(StopButton));
      await tester.pumpAndSettle();

      verify(() => mockRecorder.stop());
      expect(find.byType(PlayRecordingButton), findsOneWidget);
    });
  });
}
