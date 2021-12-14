import 'package:battery_plus/battery_plus.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart';
import 'package:mocktail/mocktail.dart';
import 'package:record/record.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'package:seagull/db/all.dart';
import 'package:seagull/repository/all.dart';
import 'package:seagull/storage/all.dart';

export 'package:mocktail/mocktail.dart';

// Repository
class MockActivityRepository extends Mock implements ActivityRepository {}

class MockUserRepository extends Mock implements UserRepository {}

class MockUserFileRepository extends Mock implements UserFileRepository {}

class MockSortableRepository extends Mock implements SortableRepository {}

// Db
class MockActivityDb extends Mock implements ActivityDb {}

class MockUserFileDb extends Mock implements UserFileDb {}

class MockUserDb extends Mock implements UserDb {}

class MockTokenDb extends Mock implements TokenDb {}

class MockLicenseDb extends Mock implements LicenseDb {}

class MockDatabase extends Mock implements Database {}

class MockSettingsDb extends Mock implements SettingsDb {}

class MockGenericDb extends Mock implements GenericDb {}

class MockSortableDb extends Mock implements SortableDb {}

class MockScrollController extends Mock implements ScrollController {}

class MockScrollPosition extends Mock implements ScrollPosition {}

class MockBaseClient extends Mock implements BaseClient {}

// Storage
class MockFileStorage extends Mock implements FileStorage {}

// Plugin
class MockRecord extends Mock implements Record {}

class MockFirebasePushService extends Mock implements FirebasePushService {}

class MockFlutterLocalNotificationsPlugin extends Mock
    implements FlutterLocalNotificationsPlugin {}

// Misc

class MockNotification extends Mock implements Notification {}

class MockMultipartRequestBuilder extends Mock
    implements MultipartRequestBuilder {}

class MockMultipartRequest extends Mock implements MultipartRequest {}

class Notification {
  mockCancelAll() {}
}

class MockConnectivity extends Mock implements Connectivity {}

class MockBattery extends Mock implements Battery {}
