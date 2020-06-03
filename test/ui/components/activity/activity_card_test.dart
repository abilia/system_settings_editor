import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/getit.dart';

import 'package:seagull/i18n/app_localizations.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/ui/components/all.dart';

import '../../../mocks.dart';

void main() {
  final startTime = DateTime(2011, 11, 11, 11, 11);

  Future pumpActivityCard(WidgetTester tester, Activity activity) => tester
      .pumpWidget(
        MaterialApp(
          supportedLocales: Translator.supportedLocals,
          localizationsDelegates: [Translator.delegate],
          localeResolutionCallback: (locale, supportedLocales) =>
              supportedLocales.firstWhere(
                  (l) => l.languageCode == locale?.languageCode,
                  orElse: () => supportedLocales.first),
          home: MultiBlocProvider(
            providers: [
              BlocProvider<AuthenticationBloc>(
                  create: (context) => MockAuthenticationBloc()),
              BlocProvider<UserFileBloc>(
                create: (context) => UserFileBloc(
                  fileStorage: MockFileStorage(),
                  pushBloc: MockPushBloc(),
                  syncBloc: MockSyncBloc(),
                  userFileRepository: MockUserFileRepository(),
                ),
              ),
            ],
            child: Material(
              child: ActivityCard(
                activityOccasion: ActivityOccasion.forTest(activity),
              ),
            ),
          ),
        ),
      )
      .then((_) => tester.pumpAndSettle());

  setUp(() {
    initializeDateFormatting();
    GetItInitializer()
      ..fileStorage = MockFileStorage()
      ..init();
  });

  testWidgets('has title ', (WidgetTester tester) async {
    final title = 'title';
    await pumpActivityCard(
      tester,
      Activity.createNew(
        title: title,
        startTime: startTime,
      ),
    );

    // Asert title but no image
    expect(find.byType(ActivityCard), findsOneWidget);
    expect(find.text(title), findsOneWidget);
    expect(find.byType(CheckedImage), findsNothing);
  });

  testWidgets('has image ', (WidgetTester tester) async {
    await pumpActivityCard(
      tester,
      Activity.createNew(
        title: '',
        fileId: 'fileid',
        startTime: startTime,
      ),
    );

    // Assert image
    expect(find.byType(ActivityCard), findsOneWidget);
    expect(find.byType(CheckedImage), findsOneWidget);
  });

  testWidgets('has title and image ', (WidgetTester tester) async {
    final title = 'title';
    await pumpActivityCard(
      tester,
      Activity.createNew(
        title: title,
        fileId: 'fileid',
        startTime: startTime,
      ),
    );

    // Assert title and image
    expect(find.byType(ActivityCard), findsOneWidget);
    expect(find.text(title), findsOneWidget);
    expect(find.byType(CheckedImage), findsOneWidget);
  });

  testWidgets('icon for checkable activity', (WidgetTester tester) async {
    await pumpActivityCard(
        tester,
        Activity.createNew(
            title: 'title', startTime: startTime, checkable: true));

    // Assert title no image
    expect(find.byIcon(AbiliaIcons.handi_check), findsOneWidget);
  });
  testWidgets('icon for alarm and vibration ', (WidgetTester tester) async {
    await pumpActivityCard(
      tester,
      Activity.createNew(
        title: 'title',
        startTime: startTime,
        alarmType: ALARM_SOUND_AND_VIBRATION,
      ),
    );
    expect(find.byIcon(AbiliaIcons.handi_alarm_vibration), findsOneWidget);
  });

  testWidgets('icon for vibration ', (WidgetTester tester) async {
    await pumpActivityCard(
      tester,
      Activity.createNew(
        title: 'title',
        startTime: startTime,
        alarmType: ALARM_VIBRATION,
      ),
    );
    expect(find.byIcon(AbiliaIcons.handi_vibration), findsOneWidget);
  });

  testWidgets('icon for no alarm nor vibration ', (WidgetTester tester) async {
    await pumpActivityCard(
        tester,
        Activity.createNew(
          title: 'title',
          startTime: startTime,
          alarmType: NO_ALARM,
        ));
    expect(find.byIcon(AbiliaIcons.handi_no_alarm_vibration), findsOneWidget);
  });

  testWidgets('icon for reminder ', (WidgetTester tester) async {
    await pumpActivityCard(
      tester,
      Activity.createNew(
        title: 'title',
        startTime: startTime,
        reminderBefore: [124],
      ),
    );
    expect(find.byIcon(AbiliaIcons.handi_reminder), findsOneWidget);
  });

  testWidgets('icon for info item ', (WidgetTester tester) async {
    await pumpActivityCard(
      tester,
      Activity.createNew(
        title: 'title',
        startTime: startTime,
        infoItem: NoteInfoItem('text'),
      ),
    );
    expect(find.byIcon(AbiliaIcons.handi_info), findsOneWidget);
  });

  testWidgets('icon for private activity ', (WidgetTester tester) async {
    await pumpActivityCard(
      tester,
      Activity.createNew(
        title: 'title',
        startTime: startTime,
        secret: true,
      ),
    );
    expect(find.byType(PrivateIcon), findsOneWidget);
    expect(find.byIcon(AbiliaIcons.password_protection), findsOneWidget);
  });
}