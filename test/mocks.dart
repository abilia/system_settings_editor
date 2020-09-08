import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart';
import 'package:mockito/mockito.dart';
import 'package:seagull/analytics/analytics_service.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/db/all.dart';
import 'package:seagull/logging.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/repository/all.dart';
import 'package:seagull/storage/all.dart';
import 'package:seagull/ui/components/widget_test_keys.dart';

final AlarmScheduler noAlarmScheduler = ((a, b, c, d) async {});

class MockNavigatorObserver extends Mock implements NavigatorObserver {}

class MockUserRepository extends Mock implements UserRepository {}

class MockHttpClient extends Mock implements Client {}

class MockActivityRepository extends Mock implements ActivityRepository {}

class MockSortableRepository extends Mock implements SortableRepository {}

class MockUserFileRepository extends Mock implements UserFileRepository {}

class MockTokenDb extends Mock implements TokenDb {}

class MockPushBloc extends Mock implements PushBloc {}

class MockSyncBloc extends Mock implements SyncBloc {}

class MockSortableBloc extends Mock implements SortableBloc {}

class MockUserFileBloc extends Mock implements UserFileBloc {}

class MockImageArchiveBloc extends MockBloc<SortableArchiveEvent,
        SortableArchiveState<ImageArchiveData>>
    implements SortableArchiveBloc<ImageArchiveData> {}

class MockFirebasePushService extends Mock implements FirebasePushService {}

class MockFirebaseMessaging extends Mock implements FirebaseMessaging {}

class MockActivityDb extends Mock implements ActivityDb {}

class MockUserFileDb extends Mock implements UserFileDb {}

class MockUserDb extends Mock implements UserDb {}

class MockLicenseDb extends Mock implements LicenseDb {}

class MockSettingsDb extends Mock implements SettingsDb {}

class MockDatabase extends Mock implements Database {}

class MockBatch extends Mock implements Batch {}

class MockBaseUrlDb extends Mock implements BaseUrlDb {}

class MockSeagullLogger extends Mock implements SeagullLogger {}

class MockFileStorage extends Mock implements FileStorage {}

class MockAnalyticsService extends Mock implements AnalyticsService {}

class MockMultipartRequestBuilder extends Mock
    implements MultipartRequestBuilder {}

class MockMultipartRequest extends Mock implements MultipartRequest {}

class MockedClient extends Mock implements BaseClient {}

class MockFlutterLocalNotificationsPlugin extends Mock
    implements FlutterLocalNotificationsPlugin {}

class MockActivitiesBloc extends MockBloc<ActivitiesEvent, ActivitiesState>
    implements ActivitiesBloc {}

class MockActivitiesOccasionBloc extends Mock
    implements ActivitiesOccasionBloc {}

class MockDayActivitiesBloc
    extends MockBloc<DayActivitiesBloc, DayActivitiesState>
    implements DayActivitiesBloc {}

class MockDayPickerBloc extends MockBloc<DayPickerBloc, DayPickerState>
    implements DayPickerBloc {}

class MockSettingsBloc extends MockBloc<SettingsEvent, SettingsState>
    implements SettingsBloc {}

class MockAuthenticationBloc
    extends MockBloc<AuthenticationEvent, AuthenticationState>
    implements AuthenticationBloc {}

class MockBloc<E, S> extends Mock {
  @override
  dynamic noSuchMethod(Invocation invocation) {
    final memberName = invocation.memberName.toString().split('"')[1];
    final result = super.noSuchMethod(invocation);
    return (memberName == 'skip' && result == null)
        ? Stream<S>.empty()
        : result;
  }
}

extension OurEnterText on WidgetTester {
  Future<void> enterText_(Finder finder, String text) async {
    await tap(finder);
    await pump();
    await enterText(find.byKey(TestKey.input), text);
    await pump();
    await tap(find.byKey(TestKey.okDialog).first);
    await pump();
  }
}
