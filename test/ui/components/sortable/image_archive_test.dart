import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/bloc/sortable/image_archive/image_archive_bloc.dart';
import 'package:seagull/i18n/app_localizations.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/ui/components/all.dart';
import 'package:collection/collection.dart';

import '../../../mocks.dart';

void main() {
  group('Image archive test', () {
    final imageData = '''
          {"name":"bingo","fileId":"351d5e7d-0d87-4037-9829-538a14936128","file":"/images/Basic/Basic/bingo.gif"}
          ''';
    final image =
        Sortable.createNew(type: SortableType.imageArchive, data: imageData);

    final folderData = '''
          {"name":"Basic","fileId":"19da3060-be12-42f9-922e-7e1635293126","icon":"/images/Basic/Basic.png"}
          ''';
    final folder = Sortable.createNew(
        type: SortableType.imageArchive, data: folderData, isGroup: true);

    ImageArchiveBloc imageArchiveBlocMock = MockImageArchiveBloc();

    Widget wrapWithMaterialApp(Widget widget) => MaterialApp(
          supportedLocales: Translator.supportedLocals,
          localizationsDelegates: [Translator.delegate],
          localeResolutionCallback: (locale, supportedLocales) =>
              supportedLocales.firstWhere(
                  (l) => l.languageCode == locale?.languageCode,
                  orElse: () => supportedLocales.first),
          home: MultiBlocProvider(providers: [
            BlocProvider<AuthenticationBloc>(
                create: (context) => MockAuthenticationBloc()),
            BlocProvider<ImageArchiveBloc>(
                create: (context) => imageArchiveBlocMock),
          ], child: widget),
        );

    testWidgets('Image archive smoke test', (WidgetTester tester) async {
      when(imageArchiveBlocMock.state)
          .thenAnswer((_) => stateFromSortables([]));
      await tester.pumpWidget(wrapWithMaterialApp(ImageArchive(
        onChanged: (val) {},
      )));
      await tester.pumpAndSettle();
      expect(find.byType(ImageArchive), findsOneWidget);
      expect(find.byType(ArchiveImage), findsNothing);
    });

    testWidgets('Image archive with one image and no folder',
        (WidgetTester tester) async {
      when(imageArchiveBlocMock.state)
          .thenAnswer((_) => stateFromSortables([image]));
      await tester.pumpWidget(wrapWithMaterialApp(ImageArchive(
        onChanged: (val) {},
      )));
      await tester.pumpAndSettle();
      expect(find.byType(ImageArchive), findsOneWidget);
      expect(find.byType(ArchiveImage), findsOneWidget);
    });

    testWidgets('Image archive with one image and one folder',
        (WidgetTester tester) async {
      when(imageArchiveBlocMock.state)
          .thenAnswer((_) => stateFromSortables([image, folder]));
      await tester.pumpWidget(wrapWithMaterialApp(ImageArchive(
        onChanged: (val) {},
      )));
      await tester.pumpAndSettle();
      expect(find.byType(ImageArchive), findsOneWidget);
      expect(find.byType(ArchiveImage), findsOneWidget);
      expect(find.byType(Folder), findsOneWidget);
    });
  });
}

ImageArchiveState stateFromSortables(List<Sortable> sortables,
    {String folderId, String imageId}) {
  final allByFolder = groupBy<Sortable, String>(sortables, (s) => s.groupId);
  final allById = Map<String, Sortable>.fromIterable(sortables,
      key: (s) => s.id, value: (s) => s);
  return ImageArchiveState(allByFolder, allById, folderId, imageId);
}
