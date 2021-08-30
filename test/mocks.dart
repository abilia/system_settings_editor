// @dart=2.9

import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/gestures.dart';

import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart';
import 'package:mockito/mockito.dart';

import 'package:seagull/analytics/analytics_service.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/db/all.dart';

import 'package:seagull/logging.dart';

import 'package:seagull/models/all.dart';
import 'package:seagull/repository/all.dart';
import 'package:seagull/storage/all.dart';
import 'package:seagull/ui/all.dart';
import 'package:seagull/utils/all.dart';

export 'test_helpers/verify_generic.dart';
export 'test_helpers/fake_shared_preferences.dart';
export 'test_helpers/permission.dart';
export 'test_helpers/alarm_schedualer.dart';
export 'test_helpers/enter_text.dart';
export 'test_helpers/app_pumper.dart';

class MockNavigatorObserver extends Mock implements NavigatorObserver {}

class MockUserRepository extends Mock implements UserRepository {}

class MockActivityRepository extends Mock implements ActivityRepository {}

class MockSortableRepository extends Mock implements SortableRepository {}

class MockUserFileRepository extends Mock implements UserFileRepository {}

class MockGenericRepository extends Mock implements GenericRepository {}

class MockTokenDb extends Mock implements TokenDb {}

class MockLicenseDb extends Mock implements LicenseDb {}

class MockPushBloc extends MockBloc<PushEvent, PushState> implements PushBloc {}

class MockSyncBloc extends MockBloc<SyncEvent, SyncState> implements SyncBloc {}

class MockSortableBloc extends MockBloc<SortableEvent, SortableState>
    implements SortableBloc {}

class MockGenericBloc extends MockBloc<GenericEvent, GenericState>
    implements GenericBloc {}

class MockUserFileBloc extends MockBloc<UserFileEvent, UserFileState>
    implements UserFileBloc {}

class MockTimepillarBloc extends MockBloc<TimepillarEvent, TimepillarState>
    implements TimepillarBloc {}

class MockAlarmBloc extends MockBloc<AlarmEvent, AlarmStateBase>
    implements AlarmBloc {}

class MockNotificationBloc extends MockBloc<NotificationAlarm, AlarmStateBase>
    implements NotificationBloc {}

class MockCalendarViewBloc extends MockBloc<ToggleCategory, CalendarViewState>
    implements CalendarViewBloc {}

class MockLicenseBloc extends MockBloc<LicenseEvent, LicenseState>
    implements LicenseBloc {}

class MockImageArchiveBloc extends MockBloc<SortableArchiveEvent,
        SortableArchiveState<ImageArchiveData>>
    implements SortableArchiveBloc<ImageArchiveData> {}

class MockAuthenticatedBlocsProvider extends StatelessWidget {
  final Widget child;

  const MockAuthenticatedBlocsProvider({Key key, this.child}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(providers: [
      BlocProvider<AuthenticationBloc>(
          create: (context) => MockAuthenticationBloc()),
      BlocProvider<ActivitiesBloc>(create: (context) => MockActivitiesBloc()),
      BlocProvider<SettingsBloc>(create: (context) => MockSettingsBloc()),
      BlocProvider<PermissionBloc>(create: (context) => PermissionBloc()),
      BlocProvider<SyncBloc>(create: (context) => MockSyncBloc()),
      BlocProvider<UserFileBloc>(create: (context) => MockUserFileBloc()),
      BlocProvider<SortableBloc>(create: (context) => MockSortableBloc()),
      BlocProvider<GenericBloc>(create: (context) => MockGenericBloc()),
      BlocProvider<MemoplannerSettingBloc>(
          create: (context) => MockMemoplannerSettingsBloc()),
      BlocProvider<DayPickerBloc>(create: (context) => MockDayPickerBloc()),
      BlocProvider<DayActivitiesBloc>(
          create: (context) => MockDayActivitiesBloc()),
      BlocProvider<ActivitiesOccasionBloc>(
          create: (context) => MockActivitiesOccasionBloc()),
      BlocProvider<AlarmBloc>(create: (context) => MockAlarmBloc()),
      BlocProvider<NotificationBloc>(
          create: (context) => MockNotificationBloc()),
      BlocProvider<CalendarViewBloc>(
          create: (context) => MockCalendarViewBloc()),
      BlocProvider<LicenseBloc>(create: (context) => MockLicenseBloc()),
    ], child: child);
  }
}

class MockFirebasePushService extends Mock implements FirebasePushService {}

class MockFirebaseMessaging extends Mock implements FirebaseMessaging {}

class MockActivityDb extends Mock implements ActivityDb {}

class MockGenericDb extends Mock implements GenericDb {
  MockGenericDb() {
    when(getAllNonDeletedMaxRevision()).thenAnswer((_) => Future.value([]));
    when(getAllDirty()).thenAnswer((_) => Future.value([]));
    when(insertAndAddDirty(any)).thenAnswer((_) => Future.value(true));
  }
}

class MockUserFileDb extends Mock implements UserFileDb {
  @override
  Future<Iterable<UserFile>> getAllLoadedFiles() => Future.value([]);
}

class MockUserDb extends Mock implements UserDb {}

class MockSettingsDb extends Mock implements SettingsDb {
  MockSettingsDb() {
    when(textToSpeech).thenReturn(true);
    when(leftCategoryExpanded).thenReturn(true);
    when(rightCategoryExpanded).thenReturn(true);
  }
}

class MockSortableDb extends Mock implements SortableDb {}

class MockDatabase extends Mock implements Database {
  MockDatabase() {
    when(rawQuery(any)).thenAnswer((_) => Future.value([]));
    when(query(
      any,
      columns: ['dirty', 'revision'],
      where: 'id = ?',
      whereArgs: anyNamed('whereArgs'),
    )).thenAnswer((_) => Future.value([]));
    when(rawQuery(any, any)).thenAnswer((_) => Future.value([]));
    when(batch()).thenAnswer((_) => MockBatch());
  }
}

class MockBatch extends Mock implements Batch {}

class MockBaseUrlDb extends Mock implements BaseUrlDb {}

class MockSeagullLogger extends Mock implements SeagullLogger {}

class MockFileStorage extends Mock implements FileStorage {}

class MockAnalyticsService extends Mock implements AnalyticsService {}

class MockFlutterTts extends Mock implements FlutterTts {
  MockFlutterTts() {
    when(speak(any)).thenAnswer((realInvocation) => Future.value());
  }
}

class MockMultipartRequestBuilder extends Mock
    implements MultipartRequestBuilder {}

class MockMultipartRequest extends Mock implements MultipartRequest {}

class MockedClient extends Mock implements BaseClient {}

class MockFlutterLocalNotificationsPlugin extends Mock
    implements FlutterLocalNotificationsPlugin {
  MockFlutterLocalNotificationsPlugin() {
    when(cancelAll()).thenAnswer((realInvocation) => Future.value());
  }
}

class MockActivitiesBloc extends MockBloc<ActivitiesEvent, ActivitiesState>
    implements ActivitiesBloc {}

class MockActivitiesOccasionBloc
    extends MockBloc<ActivitiesOccasionEvent, ActivitiesOccasionState>
    implements ActivitiesOccasionBloc {}

class MockDayActivitiesBloc
    extends MockBloc<DayActivitiesBloc, DayActivitiesState>
    implements DayActivitiesBloc {}

class MockDayPickerBloc extends MockBloc<DayPickerBloc, DayPickerState>
    implements DayPickerBloc {}

class MockMemoplannerSettingsBloc
    extends MockBloc<MemoplannerSettingsEvent, MemoplannerSettingsState>
    implements MemoplannerSettingBloc {}

class MockSettingsBloc extends MockBloc<SettingsEvent, SettingsState>
    implements SettingsBloc {}

class MockAuthenticationBloc
    extends MockBloc<AuthenticationEvent, AuthenticationState>
    implements AuthenticationBloc {}

class MockAlarmNavigator extends Mock implements AlarmNavigator {}

class MockBloc<E, S> extends Mock {
  Stream<S> get stream => Stream.empty();
}

extension TtsVerifier on WidgetTester {
  Future verifyTts(Finder finder,
      {String contains, String exact, bool warnIfMissed = true}) async {
    await longPress(finder, warnIfMissed: warnIfMissed);
    final arg = verify(GetIt.I<FlutterTts>().speak(captureAny)).captured.first
        as String;
    if (contains != null) {
      expect(arg.toLowerCase().contains(contains.toLowerCase()), isTrue,
          reason: '$arg does not contain $contains');
    }
    if (exact != null) {
      expect(arg, exact);
    }
  }

  Future verifyNoTts(Finder finder) async {
    await longPress(finder);
    verifyNever(GetIt.I<FlutterTts>().speak(any));
  }
}

extension TapLink on CommonFinders {
  bool _tapTextSpan(RichText richText, String text) {
    return !richText.text.visitChildren(
      (InlineSpan visitor) {
        if (visitor is TextSpan && visitor.text == text) {
          (visitor.recognizer as TapGestureRecognizer).onTap();
          return false;
        }
        return true;
      },
    );
  }

  Finder tapTextSpan(String text) {
    return byWidgetPredicate(
      (widget) => widget is RichText && _tapTextSpan(widget, text),
    );
  }
}

class MockHttpClient extends Mock implements HttpClient {}

class MockHttpClientRequest extends Mock implements HttpClientRequest {}

class MockHttpClientResponse extends Mock implements HttpClientResponse {}

class MockHttpHeaders extends Mock implements HttpHeaders {}

R provideMockedNetworkImages<R>(R Function() body) => HttpOverrides.runZoned(
      body,
      createHttpClient: (_) => createMockImageHttpClient(kTransparentImage),
    );

// Returns a mock HTTP client that responds with an image to all requests.
MockHttpClient createMockImageHttpClient(List<int> imageBytes) {
  final client = MockHttpClient();
  final request = MockHttpClientRequest();
  final response = MockHttpClientResponse();
  final headers = MockHttpHeaders();

  when(client.getUrl(any))
      .thenAnswer((_) => Future<HttpClientRequest>.value(request));
  when(request.headers).thenReturn(headers);
  when(request.close())
      .thenAnswer((_) => Future<HttpClientResponse>.value(response));
  when(response.contentLength).thenReturn(imageBytes.length);
  when(response.statusCode).thenReturn(HttpStatus.ok);
  when(response.compressionState)
      .thenReturn(HttpClientResponseCompressionState.notCompressed);
  when(response.listen(any)).thenAnswer((Invocation invocation) {
    final void Function(List<int>) onData = invocation.positionalArguments[0];
    final void Function() onDone = invocation.namedArguments[#onDone];
    final void Function(Object, [StackTrace]) onError =
        invocation.namedArguments[#onError];
    final bool cancelOnError = invocation.namedArguments[#cancelOnError];

    return Stream<List<int>>.fromIterable(<List<int>>[imageBytes]).listen(
        onData,
        onDone: onDone,
        onError: onError,
        cancelOnError: cancelOnError);
  });

  return client;
}
