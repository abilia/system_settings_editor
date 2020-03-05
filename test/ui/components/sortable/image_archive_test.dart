import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/bloc/sortable/image_archive/image_archive_bloc.dart';
import 'package:seagull/i18n/app_localizations.dart';
import 'package:seagull/ui/components/all.dart';

import '../../../mocks.dart';

void main() {
  group('Image archive test', () {
    Widget wrapWithMaterialApp(Widget widget) => MaterialApp(
          supportedLocales: Translator.supportedLocals,
          localizationsDelegates: [Translator.delegate],
          localeResolutionCallback: (locale, supportedLocales) =>
              supportedLocales.firstWhere(
                  (l) => l.languageCode == locale?.languageCode,
                  orElse: () => supportedLocales.first),
          home: MultiBlocProvider(providers: [
            BlocProvider<ImageArchiveBloc>(
                create: (context) => ImageArchiveBloc(
                      sortableBloc: MockSortableBloc(),
                    )),
          ], child: widget),
        );

    testWidgets('Image archive smoke test', (WidgetTester tester) async {
      await tester.pumpWidget(wrapWithMaterialApp(ImageArchive(
        onChanged: (val) {},
      )));
      await tester.pumpAndSettle();
      expect(find.byType(ImageArchive), findsOneWidget);
    });
  });
}
