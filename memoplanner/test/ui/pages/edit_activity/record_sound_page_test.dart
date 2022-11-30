import 'dart:convert';
import 'dart:io';

import 'package:file/memory.dart';

import 'package:flutter_test/flutter_test.dart';

import 'package:memoplanner/bloc/all.dart';
import 'package:memoplanner/models/all.dart';
import 'package:memoplanner/ui/all.dart';

import '../../../fakes/all.dart';
import '../../../mocks/mock_bloc.dart';
import '../../../mocks/mocks.dart';
import '../../../test_helpers/register_fallback_values.dart';

final _dummyFile = UnstoredAbiliaFile.forTest('testfile', 'jksd', File('nbnb'));

void main() {
  late MockRecord mockRecorder;
  const recordedBytes =
      'AAAAGGZ0eXBtcDQyAAAAAGlzb21tcDQyAAADFW1vb3YAAABsbXZoZAAAAADdaLlC3Wi5QgAAA+gAAAAAAAEAAAEAAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAIAAADqbWV0YQAAACFoZGxyAAAAAAAAAABtZHRhAAAAAAAAAAAAAAAAAAAAAGRrZXlzAAAAAAAAAAMAAAAbbWR0YWNvbS5hbmRyb2lkLnZlcnNpb24AAAAgbWR0YWNvbS5hbmRyb2lkLm1hbnVmYWN0dXJlcgAAABltZHRhY29tLmFuZHJvaWQubW9kZWwAAABdaWxzdAAAABoAAAABAAAAEmRhdGEAAAABAAAAADEwAAAAHgAAAAIAAAAWZGF0YQAAAAEAAAAAR29vZ2xlAAAAHQAAAAMAAAAVZGF0YQAAAAEAAAAAUGl4ZWwAAAG3dHJhawAAAFx0a2hkAAAAB91ouULdaLlCAAAAAQAAAAAAAAAAAAAAAAAAAAAAAAAAAQAAAAABAAAAAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAABU21kaWEAAAAgbWRoZAAAAADdaLlC3Wi5QgAArEQAAAAAAAAAAAAAACxoZGxyAAAAAAAAAABzb3VuAAAAAAAAAAAAAAAAU291bmRIYW5kbGUAAAAA/21pbmYAAAAQc21oZAAAAAAAAAAAAAAAJGRpbmYAAAAcZHJlZgAAAAAAAAABAAAADHVybCAAAAABAAAAw3N0YmwAAABbc3RzZAAAAAAAAAABAAAAS21wNGEAAAAAAAAAAQAAAAAAAAAAAAEAEAAAAACsRAAAAAAAJ2VzZHMAAAAAAxkAAAAEEUAVAAMAAAH0AAAB9AAFAhIIBgECAAAAGHN0dHMAAAAAAAAAAQAAAAEAAAAAAAAAGHN0c3oAAAAAAAAAAAAAAAEAAAFzAAAA';
  const filePath = 'hmm.m4a';
  setUp(() async {
    final fileContent = base64.decode(recordedBytes);
    final file = MemoryFileSystem().file(filePath);
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
              BlocProvider<UserFileCubit>(
                create: (context) => UserFileCubit(
                  fileStorage: FakeFileStorage(),
                  syncBloc: FakeSyncBloc(),
                  userFileRepository: FakeUserFileRepository(),
                ),
              ),
              BlocProvider<SpeechSettingsCubit>(
                create: (context) => FakeSpeechSettingsCubit(),
              ),
              BlocProvider<PermissionCubit>(
                create: (context) => PermissionCubit(),
              ),
              BlocProvider(
                create: (context) => RecordSoundCubit(
                  record: mockRecorder,
                  originalSoundFile: originalSoundFile,
                ),
              ),
              BlocProvider<SoundBloc>(
                create: (context) => SoundBloc(
                  storage: FakeFileStorage(),
                  userFileCubit: context.read<UserFileCubit>(),
                ),
              ),
            ], child: child!),
          ),
          home: widget,
        );

    testWidgets('record page smoke test no previous file',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        wrapWithMaterialApp(const RecordSoundPage(title: '')),
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
          const RecordSoundPage(title: ''),
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
          const RecordSoundPage(title: ''),
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
        wrapWithMaterialApp(const RecordSoundPage(title: '')),
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

    testWidgets(
        'Recording a sound and clicking cancel triggers discard warning dialog',
        (WidgetTester tester) async {
      setupPermissions({
        Permission.microphone: PermissionStatus.granted,
      });
      await tester.pumpWidget(
        wrapWithMaterialApp(const RecordSoundPage(title: '')),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byType(RecordAudioButton));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(StopButton));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(CancelButton));
      await tester.pumpAndSettle();

      expect(find.byType(DiscardWarningDialog), findsOneWidget);
    });
  });

  group('display duration tests', () {
    late MockRecordSoundCubit mockRecordSoundCubit;
    late MockSoundBloc mockSoundBloc;
    setUp(() {
      mockRecordSoundCubit = MockRecordSoundCubit();
      mockSoundBloc = MockSoundBloc();
    });

    setUpAll(() {
      registerFallbackValues();
    });

    Widget wrapWithMaterialApp(Widget widget) => MaterialApp(
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
              BlocProvider<UserFileCubit>(
                create: (context) => UserFileCubit(
                  fileStorage: FakeFileStorage(),
                  syncBloc: FakeSyncBloc(),
                  userFileRepository: FakeUserFileRepository(),
                ),
              ),
              BlocProvider<SpeechSettingsCubit>(
                create: (context) => FakeSpeechSettingsCubit(),
              ),
              BlocProvider<PermissionCubit>(
                create: (context) => PermissionCubit(),
              ),
              BlocProvider<RecordSoundCubit>(
                create: (context) => mockRecordSoundCubit,
              ),
              BlocProvider<SoundBloc>(
                create: (context) => mockSoundBloc,
              ),
            ], child: child!),
          ),
          home: widget,
        );

    testWidgets(
        'RecordSoundState emits EmptyRecordSoundState. SoundState emits NoSoundPlaying. EmptyRecordSoundState takes precedence',
        (WidgetTester tester) async {
      when(() => mockRecordSoundCubit.state).thenReturn(
        const EmptyRecordSoundState(),
      );
      when(() => mockSoundBloc.state).thenReturn(
        const NoSoundPlaying(),
      );
      await tester.pumpWidget(
        wrapWithMaterialApp(
          const RecordSoundPage(title: ''),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('00:00'), findsOneWidget);
    });

    testWidgets(
        'RecordSoundState emits NewRecordSoundState. SoundState emits NoSoundPlaying. NewRecordSoundState takes precedence',
        (WidgetTester tester) async {
      when(() => mockRecordSoundCubit.state).thenReturn(
        NewRecordedSoundState(_dummyFile, const Duration(seconds: 5)),
      );
      when(() => mockSoundBloc.state).thenReturn(
        const NoSoundPlaying(),
      );
      await tester.pumpWidget(
        wrapWithMaterialApp(
          const RecordSoundPage(title: ''),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('00:05'), findsOneWidget);
    });

    testWidgets(
        'RecordSoundState emits EmptyRecordSoundState. SoundState emits SoundPlaying. SoundPlaying takes precedence',
        (WidgetTester tester) async {
      when(() => mockRecordSoundCubit.state).thenReturn(
        const EmptyRecordSoundState(),
      );
      when(() => mockSoundBloc.state).thenReturn(
        SoundPlaying(_dummyFile, position: const Duration(seconds: 1)),
      );
      await tester.pumpWidget(
        wrapWithMaterialApp(
          const RecordSoundPage(title: ''),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('00:01'), findsOneWidget);
    });

    testWidgets(
        'RecordSoundState emits RecordingSoundState. SoundState emits NoSoundPlaying. RecordingSoundState takes precedence',
        (WidgetTester tester) async {
      when(() => mockRecordSoundCubit.state).thenReturn(
        const RecordingSoundState(Duration(seconds: 3)),
      );
      when(() => mockSoundBloc.state).thenReturn(
        const NoSoundPlaying(),
      );
      await tester.pumpWidget(
        wrapWithMaterialApp(
          const RecordSoundPage(title: ''),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('00:03'), findsOneWidget);
    });

    testWidgets(
        'RecordSoundState emits RecordingSoundState. SoundState emits SoundPlaying. Should never happen? RecordingSoundState takes precedence.',
        (WidgetTester tester) async {
      when(() => mockRecordSoundCubit.state).thenReturn(
        const RecordingSoundState(Duration(seconds: 3)),
      );
      when(() => mockSoundBloc.state).thenReturn(
        SoundPlaying(
          _dummyFile,
          position: const Duration(seconds: 1),
        ),
      );
      await tester.pumpWidget(
        wrapWithMaterialApp(
          const RecordSoundPage(title: ''),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('00:03'), findsOneWidget);
    });
  });
}
