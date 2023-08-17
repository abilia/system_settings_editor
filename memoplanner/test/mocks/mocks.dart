import 'package:audioplayers/audioplayers.dart';
import 'package:battery_plus/battery_plus.dart';
import 'package:calendar/all.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:memoplanner/bloc/all.dart';
import 'package:memoplanner/db/all.dart';
import 'package:memoplanner/repository/all.dart';

import 'package:memoplanner/utils/all.dart';
import 'package:mocktail/mocktail.dart';
import 'package:record/record.dart';
import 'package:seagull_analytics/seagull_analytics.dart';
import 'package:text_to_speech/text_to_speech.dart';

export 'package:mocktail/mocktail.dart';

// Db

class MockDatabase extends Mock implements Database {}

class MockSettingsDb extends Mock implements SettingsDb {}

class MockSessionsDb extends Mock implements SessionsDb {}

class MockDeviceDb extends Mock implements DeviceDb {}

class MockCalendarDb extends Mock implements CalendarDb {}

class MockSortableDb extends Mock implements SortableDb {}

class MockVoiceDb extends Mock implements VoiceDb {}

class MockScrollController extends Mock implements ScrollController {}

class MockScrollPosition extends Mock implements ScrollPosition {}

// Plugin
class MockRecord extends Mock implements Record {}

class MockFlutterLocalNotificationsPlugin extends Mock
    implements FlutterLocalNotificationsPlugin {}

class MockAndroidFlutterLocalNotificationsPlugin extends Mock
    implements AndroidFlutterLocalNotificationsPlugin {}

class MockAudioPlayer extends Mock implements AudioPlayer {}

MockAudioPlayer mockAudioPlayerFactory() {
  final mockAudioPlayer = MockAudioPlayer();
  when(() => mockAudioPlayer.play(any())).thenAnswer((invocation) async {});
  when(() => mockAudioPlayer.onPlayerComplete)
      .thenAnswer((invocation) => const Stream.empty());
  when(() => mockAudioPlayer.onPositionChanged)
      .thenAnswer((invocation) => const Stream.empty());
  when(() => mockAudioPlayer.dispose()).thenAnswer((invocation) async {});
  when(() => mockAudioPlayer.stop()).thenAnswer((invocation) async {});
  return mockAudioPlayer;
}

// Misc

class MockNotification extends Mock implements Notification {}

class Notification {
  void mockCancelAll() {}
}

class MockConnectivity extends Mock implements Connectivity {}

class MockMyAbiliaConnection extends Mock implements MyAbiliaConnection {}

class MockBattery extends Mock implements Battery {}

class MockSpeechSettingsCubit extends Mock implements SpeechSettingsCubit {}

class MockVoiceRepository extends Mock implements VoiceRepository {}

class MockDeviceRepository extends Mock implements DeviceRepository {}

class MockFactoryResetRepository extends Mock
    implements FactoryResetRepository {}

class MockTtsHandler extends Mock implements TtsHandler {}

class MockSeagullAnalytics extends Mock implements SeagullAnalytics {}

class MockUserFileState extends Mock implements UserFileState {}
