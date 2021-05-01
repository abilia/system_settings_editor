import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart';
import 'package:intent/flag.dart';
import 'package:mockito/mockito.dart';
import 'package:seagull/analytics/analytics_service.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/db/all.dart';
import 'package:seagull/fakes/all.dart';
import 'package:seagull/logging.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/repository/all.dart';
import 'package:seagull/storage/all.dart';
import 'package:seagull/ui/all.dart';
import 'package:seagull/ui/widget_test_keys.dart';
import 'package:seagull/utils/all.dart';
import 'package:shared_preferences/shared_preferences.dart';

extension MockSharedPreferences on SharedPreferences {
  static Future<SharedPreferences> getInstance({bool loggedIn = true}) {
    SharedPreferences.setMockInitialValues({
      if (loggedIn) TokenDb.tokenKey: Fakes.token,
    });
    return SharedPreferences.getInstance();
  }
}

final AlarmScheduler noAlarmScheduler = ((a, b, c, d, e) async {});

class MockNavigatorObserver extends Mock implements NavigatorObserver {}

class MockUserRepository extends Mock implements UserRepository {}

class MockHttpClient extends Mock implements Client {}

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

class MockCalendarViewBloc
    extends MockBloc<CalendarViewEvent, CalendarViewState>
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
  }
}

class MockUserFileDb extends Mock implements UserFileDb {
  @override
  Future<Iterable<UserFile>> getAllLoadedFiles() => Future.value([]);
}

class MockUserDb extends Mock implements UserDb {}

class MockSettingsDb extends Mock implements SettingsDb {}

class MockSortableDb extends Mock implements SortableDb {}

class MockDatabase extends Mock implements Database {}

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

extension OurEnterText on WidgetTester {
  Future<void> enterText_(Finder finder, String text) async {
    await tap(finder, warnIfMissed: false);
    await pumpAndSettle();
    await enterText(find.byKey(TestKey.input), text);
    await pumpAndSettle();
    await tap(find.byType(OkButton).first);
    await pumpAndSettle();
  }

  Future verifyTts(Finder finder, {String contains, String exact}) async {
    await longPress(finder, warnIfMissed: false);
    final arg = verify(GetIt.I<FlutterTts>().speak(captureAny)).captured.first;
    if (contains != null) {
      expect(arg.contains(contains), isTrue,
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

// https://github.com/Baseflow/flutter-permission-handler/issues/262#issuecomment-702691396
Set<Permission> checkedPermissions = {};
Set<Permission> requestedPermissions = {};
int openAppSettingsCalls = 0;
int openSystemAlertSettingCalls = 0;
void setupPermissions(
    [Map<Permission, PermissionStatus> permissions = const {}]) {
  checkedPermissions = {};
  requestedPermissions = {};
  openAppSettingsCalls = 0;
  openSystemAlertSettingCalls = 0;
  MethodChannel('flutter.baseflow.com/permissions/methods')
      .setMockMethodCallHandler(
    (MethodCall methodCall) async {
      switch (methodCall.method) {
        case 'requestPermissions':
          requestedPermissions.addAll(
            (methodCall.arguments as List)
                .cast<int>()
                .map((i) => Permission.values[i]),
          );
          return permissions
              .map((key, value) => MapEntry<int, int>(key.value, value.value));
        case 'checkPermissionStatus':
          final askedPermission =
              Permission.values[methodCall.arguments as int];
          checkedPermissions.add(askedPermission);
          return (permissions[askedPermission]).value;
        case 'openAppSettings':
          openAppSettingsCalls++;
          break;
      }
    },
  );
  MethodChannel('intent').setMockMethodCallHandler(
    (MethodCall methodCall) async {
      print(methodCall);
      switch (methodCall.method) {
        case 'startActivity':
          if (methodCall.arguments['data'] == 'package:pkgName' &&
              methodCall.arguments['action'] ==
                  'android.settings.action.MANAGE_OVERLAY_PERMISSION' &&
              (methodCall.arguments['flag'] as List)
                  .contains(Flag.FLAG_ACTIVITY_EXCLUDE_FROM_RECENTS)) {
            openSystemAlertSettingCalls++;
          }
      }
    },
  );
  MethodChannel('plugins.flutter.io/package_info').setMockMethodCallHandler(
    (MethodCall methodCall) async {
      switch (methodCall.method) {
        case 'getAll':
          return {
            'appName': 'MPGOTEST',
            'packageName': 'pkgName',
            'version': '9.9.9',
            'buildNumber': '12345',
          };
      }
    },
  );
}

extension PermissionStatusValue on PermissionStatus {
  int get value {
    switch (this) {
      case PermissionStatus.denied:
        return 0;
      case PermissionStatus.granted:
        return 1;
      case PermissionStatus.restricted:
        return 2;
      case PermissionStatus.limited:
        return 3;
      case PermissionStatus.permanentlyDenied:
        return 4;
      default:
        return 3;
    }
  }
}
