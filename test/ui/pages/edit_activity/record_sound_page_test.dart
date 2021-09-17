import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mime/mime.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/models/all.dart';

import 'package:seagull/ui/all.dart';
import 'package:seagull/ui/components/buttons/green_play_button.dart';
import 'package:seagull/ui/pages/edit_activity/record_sound_page.dart';

import '../../../fakes/fake_authenticated_blocs_provider.dart';
import '../../../fakes/fake_db_and_repository.dart';
import '../../../fakes/fakes_blocs.dart';
import '../../../fakes/permission.dart';
import '../../../mocks/shared.mocks.dart';

final _dummyFile = UnstoredAbiliaFile.forTest('testfile', 'jksd', File('nbnb'));

const recorded_bytes =
    'AAAAGGZ0eXBtcDQyAAAAAGlzb21tcDQyAAADFW1vb3YAAABsbXZoZAAAAADdaLlC3Wi5QgAAA+gAAAAAAAEAAAEAAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAIAAADqbWV0YQAAACFoZGxyAAAAAAAAAABtZHRhAAAAAAAAAAAAAAAAAAAAAGRrZXlzAAAAAAAAAAMAAAAbbWR0YWNvbS5hbmRyb2lkLnZlcnNpb24AAAAgbWR0YWNvbS5hbmRyb2lkLm1hbnVmYWN0dXJlcgAAABltZHRhY29tLmFuZHJvaWQubW9kZWwAAABdaWxzdAAAABoAAAABAAAAEmRhdGEAAAABAAAAADEwAAAAHgAAAAIAAAAWZGF0YQAAAAEAAAAAR29vZ2xlAAAAHQAAAAMAAAAVZGF0YQAAAAEAAAAAUGl4ZWwAAAG3dHJhawAAAFx0a2hkAAAAB91ouULdaLlCAAAAAQAAAAAAAAAAAAAAAAAAAAAAAAAAAQAAAAABAAAAAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAABU21kaWEAAAAgbWRoZAAAAADdaLlC3Wi5QgAArEQAAAAAAAAAAAAAACxoZGxyAAAAAAAAAABzb3VuAAAAAAAAAAAAAAAAU291bmRIYW5kbGUAAAAA/21pbmYAAAAQc21oZAAAAAAAAAAAAAAAJGRpbmYAAAAcZHJlZgAAAAAAAAABAAAADHVybCAAAAABAAAAw3N0YmwAAABbc3RzZAAAAAAAAAABAAAAS21wNGEAAAAAAAAAAQAAAAAAAAAAAAEAEAAAAACsRAAAAAAAJ2VzZHMAAAAAAxkAAAAEEUAVAAMAAAH0AAAB9AAFAhIIBgECAAAAGHN0dHMAAAAAAAAAAQAAAAEAAAAAAAAAGHN0c3oAAAAAAAAAAAAAAAEAAAFzAAAA';

void main() {
  setUp(() async {
    setupPermissions();
  });

  group('RecordSoundPage test', () {
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
                  fileStorage: MockFileStorage(),
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
            ], child: child!),
          ),
          home: widget,
        );

    testWidgets('record page smoke test no previous file',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        wrapWithMaterialApp(
          BlocProvider(
            create: (context) => RecordSoundCubit(
              originalSoundFile: AbiliaFile.empty,
            ),
            child: RecordSoundPage(
              originalSoundFile: AbiliaFile.empty,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(RecordSoundPage), findsOneWidget);
      expect(find.byType(StoppedEmptyStateWidget), findsOneWidget);
      expect(find.byType(RecordAudioButton), findsOneWidget);
    });

    testWidgets('record page smoke test existing previous file',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        wrapWithMaterialApp(
          BlocProvider(
            create: (context) => RecordSoundCubit(
              originalSoundFile: _dummyFile,
            ),
            child: RecordSoundPage(
              originalSoundFile: _dummyFile,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(RecordSoundPage), findsOneWidget);
      expect(find.byType(StoppedNotEmptyStateWidget), findsOneWidget);
      expect(find.byType(GreenPlaySoundButton), findsOneWidget);
      expect(find.byIcon(AbiliaIcons.delete_all_clear), findsOneWidget);
    });

    testWidgets('delete file. check that correct state is shown afterwards.',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        wrapWithMaterialApp(
          BlocProvider(
            create: (context) => RecordSoundCubit(
              originalSoundFile: _dummyFile,
            ),
            child: RecordSoundPage(
              originalSoundFile: _dummyFile,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(StoppedNotEmptyStateWidget), findsOneWidget);
      expect(find.byType(GreenPlaySoundButton), findsOneWidget);
      await tester.tap(find.byIcon(AbiliaIcons.delete_all_clear));
      await tester.pumpAndSettle();
      expect(find.byType(StoppedEmptyStateWidget), findsOneWidget);
      expect(find.byType(RecordAudioButton), findsOneWidget);
    });

    //   testWidgets('test record. stop recording and check state',
    //       (WidgetTester tester) async {
    //     setupPermissions({
    //       Permission.microphone: PermissionStatus.granted,
    //     });
    //     await tester.pumpWidget(
    //       wrapWithMaterialApp(
    //         BlocProvider(
    //           create: (context) => RecordSoundCubit(
    //             originalSoundFile: AbiliaFile.empty,
    //           ),
    //           child: RecordSoundPage(
    //             originalSoundFile: AbiliaFile.empty,
    //           ),
    //         ),
    //       ),
    //     );
    //     await tester.pumpAndSettle();
    //
    //     final permissionBloc = PermissionBloc();
    //     expect(permissionBloc.state.microphoneDenied, false);
    //
    //     await tester.tap(find.byType(RecordAudioButton));
    //     await tester.pumpAndSettle();
    //     expect(find.byType(RecordingStateWidget), findsOneWidget);
    //     await tester.tap(find.byType(StopButton));
    //     await tester.pumpAndSettle();
    //     expect(find.byType(StoppedNotEmptyStateWidget), findsOneWidget);
    //   });
  });

  group('sound file tests', () {
    test(
        'test sound file generation. Check that content type is correct (based on extensions)',
        () async {
      final fileContent = base64.decode(recorded_bytes);

      var mpegTest = await File('test.mp3').writeAsBytes(fileContent);

      var bytes = await mpegTest.readAsBytes();
      final file = UserFile(
        id: 'f7bd7434-fae3-4d8e-ae30-b6b606b59f08',
        sha1: 'sha1',
        md5: 'md5',
        path: 'path',
        contentType: lookupMimeType(mpegTest.path, headerBytes: bytes),
        fileSize: bytes.length,
        deleted: false,
        fileLoaded: true,
      );
      expect(file.contentType, 'audio/mpeg');
      await mpegTest.delete();
    });
  });
}
