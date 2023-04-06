import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:memoplanner/models/all.dart';
import 'package:memoplanner/utils/all.dart';
import 'package:timezone/timezone.dart';
import 'package:uuid/uuid.dart';

void main() {
  const localTimezoneName = 'Local/Timezone';

  setUp(() async {
    setLocalLocation(Location(localTimezoneName, [], [], []));
  });

  test('parse json test', () {
    const response = '''[ {
          "id" : "33451ee6-cec6-4ce0-b515-f58767b13c8f",
          "owner" : 104,
          "revision" : 100,
          "revisionTime" : 0,
          "deleted" : false,
          "seriesId" : "33451ee6-cec6-4ce0-b515-f58767b13c8f",
          "groupActivityId" : null,
          "title" : "Title",
          "timezone" : "Europe/Stockholm",
          "icon" : "/images/play.png",
          "signedOffDates" : "H4sIAAAAAAAAADMy0DUw0jU0sjaCMIxhDFMow8gAxjAHABLmPcgsAAAA",
          "infoItem" : null,
          "reminderBefore" : "86400000;300000",
          "extras" : "extra extra",
          "recurrentType" : 0,
          "recurrentData" : 0,
          "alarmType" : 0,
          "duration" : 3600000,
          "category" : 0,
          "startTime" : 1570105439424,
          "endTime" : 1570109039424,
          "fullDay" : false,
          "checkable" : true,
          "removeAfter" : false,
          "secret" : false,
          "fileId" : "1a1b1678-781e-4b6f-9518-b6858560433f"
        } ]''';
    final resultList = (json.decode(response) as List)
        .map((e) => DbActivity.fromJson(e))
        .toList();
    expect(resultList.length, 1);
    final result = resultList.first.activity;
    expect(result.id, '33451ee6-cec6-4ce0-b515-f58767b13c8f');
    expect(resultList.first.revision, 100);
    expect(result.deleted, false);
    expect(result.seriesId, '33451ee6-cec6-4ce0-b515-f58767b13c8f');
    expect(result.title, 'Title');
    expect(result.icon, '/images/play.png');
    expect(result.signedOffDates, [
      '20-02-12',
      '20-02-13',
      '20-02-15',
      '20-02-20',
      '20-02-27',
    ]);
    expect(result.infoItem, InfoItem.none);
    expect(result.reminderBefore,
        [1.days().inMilliseconds, 5.minutes().inMilliseconds]);
    expect(result.reminders, [1.days(), 5.minutes()]);
    expect(result.recurs.type, 0);
    expect(result.recurs.data, 0);
    expect(result.alarmType, 0);
    expect(result.duration, 3600000.milliseconds());
    expect(result.category, Category.right);
    expect(result.startTime, 1570105439424.fromMillisecondsSinceEpoch());
    expect(result.recurs.endTime, 1570109039424);
    expect(result.fullDay, false);
    expect(result.checkable, true);
    expect(result.removeAfter, false);
    expect(result.secret, false);
    expect(result.fileId, '1a1b1678-781e-4b6f-9518-b6858560433f');
    expect(result.timezone, 'Europe/Stockholm');
    expect(result.extras, Extras.empty);
  });

  test('parse json with nulls test', () {
    const response = '''[ {
          "id" : "33451ee6-cec6-4ce0-b515-f58767b13c8f",
          "owner" : 104,
          "revision" : 100,
          "revisionTime" : 0,
          "deleted" : false,
          "seriesId" : "33451ee6-cec6-4ce0-b515-f58767b13c8f",
          "groupActivityId" : null,
          "title" : "Title",
          "timezone" : null,
          "icon" : null,
          "signedOffDates" : null,
          "infoItem" : null,
          "reminderBefore" : null,
          "extras" : null,
          "recurrentType" : 0,
          "recurrentData" : 0,
          "alarmType" : 0,
          "duration" : 3600000,
          "category" : 0,
          "startTime" : 1570105439424,
          "endTime" : 1570109039424,
          "fullDay" : false,
          "checkable" : true,
          "removeAfter" : false,
          "secret" : false,
          "fileId" : null
        } ]''';
    final resultList = (json.decode(response) as List)
        .map((e) => DbActivity.fromJson(e))
        .toList();
    expect(resultList.length, 1);
    final result = resultList.first.activity;

    expect(result.icon, '');
    expect(result.signedOffDates, []);
    expect(result.infoItem, InfoItem.none);
    expect(result.reminderBefore, []);
    expect(result.reminders, []);
    expect(result.fileId, '');
    expect(result.timezone, localTimezoneName);
    expect(result.extras, Extras.empty);
    for (var p in result.props) {
      expect(p, isNotNull);
    }
  });

  test('parse json with title null', () {
    const response = '''{
          "id" : "33451ee6-cec6-4ce0-b515-f58767b13c8f",
          "owner" : 104,
          "revision" : 100,
          "revisionTime" : 0,
          "deleted" : false,
          "seriesId" : "33451ee6-cec6-4ce0-b515-f58767b13c8f",
          "groupActivityId" : null,
          "title" : null,
          "timezone" : null,
          "icon" : null,
          "signedOffDates" : null,
          "infoItem" : null,
          "reminderBefore" : null,
          "extras" : null,
          "recurrentType" : 0,
          "recurrentData" : 0,
          "alarmType" : 0,
          "duration" : 3600000,
          "category" : 0,
          "startTime" : 1570105439424,
          "endTime" : 1570109039424,
          "fullDay" : false,
          "checkable" : true,
          "removeAfter" : false,
          "secret" : false,
          "fileId" : "33451ee6-cec6-4ce0-b515-f58767b13c8f"
        }''';
    final result = DbActivity.fromJson(json.decode(response)).activity;
    expect(result.title, '');
    for (var p in result.props) {
      expect(p, isNotNull);
    }
  });

  test('empty timezone gets local timezone', () {
    const response = '''{
          "id" : "33451ee6-cec6-4ce0-b515-f58767b13c8f",
          "owner" : 104,
          "revision" : 100,
          "revisionTime" : 0,
          "deleted" : false,
          "seriesId" : "33451ee6-cec6-4ce0-b515-f58767b13c8f",
          "groupActivityId" : null,
          "title" : null,
          "timezone": "",
          "icon" : null,
          "signedOffDates" : null,
          "infoItem" : null,
          "reminderBefore" : null,
          "extras" : null,
          "recurrentType" : 0,
          "recurrentData" : 0,
          "alarmType" : 0,
          "duration" : 3600000,
          "category" : 0,
          "startTime" : 1570105439424,
          "endTime" : 1570109039424,
          "fullDay" : false,
          "checkable" : true,
          "removeAfter" : false,
          "secret" : false,
          "fileId" : "33451ee6-cec6-4ce0-b515-f58767b13c8f"
        }''';
    final result = DbActivity.fromJson(json.decode(response)).activity;
    expect(result.timezone, localTimezoneName);
  });

  test('parse json with empty string test', () {
    const response = '''[ {
          "id" : "33451ee6-cec6-4ce0-b515-f58767b13c8f",
          "owner" : 104,
          "revision" : 100,
          "revisionTime" : 0,
          "deleted" : false,
          "seriesId" : "33451ee6-cec6-4ce0-b515-f58767b13c8f",
          "groupActivityId" : "",
          "title" : "Title",
          "timezone" : "Europe/Stockholm",
          "icon" : "",
          "signedOffDates" : "",
          "infoItem" : "",
          "reminderBefore" : "",
          "extras" : "",
          "recurrentType" : 0,
          "recurrentData" : 0,
          "alarmType" : 0,
          "duration" : 3600000,
          "category" : 0,
          "startTime" : 1570105439424,
          "endTime" : 1570109039424,
          "fullDay" : false,
          "checkable" : true,
          "removeAfter" : false,
          "secret" : false,
          "fileId" : ""
        } ]''';
    final resultList = (json.decode(response) as List)
        .map((e) => DbActivity.fromJson(e))
        .toList();
    expect(resultList.length, 1);
    final result = resultList.first.activity;

    // expect(result.groupActivityId, null);
    expect(result.icon, '');
    expect(result.signedOffDates, []);
    expect(result.infoItem, InfoItem.none);
    expect(result.reminderBefore, []);
    expect(result.reminders, []);
    // expect(result.extras, null);
    expect(result.fileId, '');
    expect(result.extras, Extras.empty);
  });

  test('create, serialize and deserialize test', () {
    final now = DateTime(2020, 02, 02, 02, 02, 02, 02);
    final fileId = const Uuid().v4();
    const duration = Duration(minutes: 90);
    final reminders = {
      const Duration(minutes: 5).inMilliseconds,
      const Duration(hours: 1).inMilliseconds
    };
    const infoItem = NoteInfoItem('just a note');

    final activity = Activity.createNew(
      title: 'An interesting title',
      category: 4,
      duration: duration,
      reminderBefore: reminders,
      startTime: now,
      timezone: 'aTimeZone',
      recurs: Recurs.biWeeklyOnDays(evens: const [
        DateTime.monday,
        DateTime.saturday,
      ]),
      fileId: fileId,
      checkable: true,
      signedOffDates: const ['00-02-20'],
      infoItem: infoItem,
      extras: Extras.createNew(
        startTimeExtraAlarm: AbiliaFile.from(path: 'startTimeExtraAlarm'),
      ),
    );
    final dbActivity = activity.wrapWithDbModel();
    final asJson = dbActivity.toJson();
    final deserializedDbActivity = DbActivity.fromJson(asJson);
    final deserializedActivity = deserializedDbActivity.activity;
    expect(deserializedActivity.id, activity.id);
    expect(deserializedActivity.seriesId, activity.seriesId);
    expect(deserializedActivity.title, activity.title);
    expect(deserializedActivity.category, 4);
    expect(activity.category, 4);
    expect(deserializedActivity.duration, activity.duration);
    expect(deserializedActivity.reminderBefore, activity.reminderBefore);
    expect(deserializedActivity.startTime, activity.startTime);
    expect(deserializedActivity.recurs.endTime, activity.recurs.endTime);
    expect(deserializedActivity.fileId, activity.fileId);
    expect(deserializedActivity.icon, activity.icon);
    expect(deserializedActivity.recurs.type, activity.recurs.type);
    expect(deserializedActivity.recurs.data, activity.recurs.data);
    expect(deserializedActivity.deleted, activity.deleted);
    expect(deserializedDbActivity.revision, dbActivity.revision);
    expect(deserializedActivity.alarmType, activity.alarmType);
    expect(deserializedActivity.checkable, activity.checkable);
    expect(deserializedActivity.removeAfter, activity.removeAfter);
    expect(deserializedActivity.secret, activity.secret);
    expect(deserializedActivity.signedOffDates, activity.signedOffDates);
    expect(deserializedActivity.infoItem, activity.infoItem);
    expect(deserializedActivity.extras, activity.extras);
    expect(deserializedActivity, activity);
  });

  test('Copy with empty', () {
    final now = DateTime(2020, 02, 02, 02, 02, 02, 02);
    final toCopy = Activity.createNew(
      title: 'Title',
      startTime: now,
    );
    const fileId = 'fileId';
    final original = Activity.createNew(
      title: 'Title',
      startTime: now,
      fileId: fileId,
    );
    final copy = original.copyActivity(toCopy);
    expect(copy.fileId, '');
  });

  test('same values in db and json', () {
    final now = DateTime(2020, 02, 02, 02, 02, 02, 02);
    final a = Activity(
      title: 'Title',
      calendarId: 'calendarID',
      startTime: now,
      fileId: 'fileId',
      icon: 'icon',
      extras: Extras.createNew(
          startTimeExtraAlarm: AbiliaFile.from(path: 'startTimeExtraAlarm')),
      timezone: 'time/zone',
    );
    final dbModel = a.wrapWithDbModel();
    final json = dbModel.toJson()..remove('secretExemptions');
    final db = dbModel.toMapForDb()
      ..remove('dirty')
      ..remove('secret_exemptions');
    final jsonWithoutBool = json.values
        .map((value) => value is bool ? (value ? 1 : 0) : value)
        .toList();

    expect(jsonWithoutBool, containsAll(db.values));
  });

  test('infoItem is null or empty (Bug SGC-328)', () {
    final now = DateTime(2020, 02, 02, 02, 02, 02, 02);
    final a = Activity.createNew(
      title: 'Title',
      startTime: now,
      fileId: '',
    );
    final dbModel = a.wrapWithDbModel();
    final json = dbModel.toJson();
    final db = dbModel.toMapForDb();

    final dbInfoItem = db['info_item'];
    final jsonInfoItem = json['infoItem'];
    expect(dbInfoItem, anyOf(isNull, isEmpty));
    expect(jsonInfoItem, anyOf(isNull, isEmpty));
  });

  test(
      'newly created activity has endTime larger then start time (BUG SGC-351)',
      () {
    final now = DateTime(2020, 10, 13, 10, 09, 23);
    final a = Activity.createNew(
      title: 'A bug test',
      startTime: now,
    );
    final dbModel = a.wrapWithDbModel();

    final dbMap = dbModel.toMapForDb();
    final json = dbModel.toJson();
    final jEndTime = json['endTime'];
    final dbEndTime = dbMap['end_time'];

    expect(a.recurs.endTime, greaterThanOrEqualTo(now.millisecondsSinceEpoch));
    expect(jEndTime, a.recurs.endTime);
    expect(dbEndTime, a.recurs.endTime);
  });

  test('Bug SGC-867 extras not saved on change', () {
    const response = '''{
      "id": "13e4085c-dfbc-4d8c-8c81-7bad32a0a8b4",
      "owner": 356,
      "revision": 1,
      "revisionTime": 0,
      "deleted": false,
      "seriesId": "13e4085c-dfbc-4d8c-8c81-7bad32a0a8b4",
      "groupActivityId": null,
      "title": "af",
      "timezone": "Europe/Stockholm",
      "icon": null,
      "signedOffDates": null,
      "infoItem": "",
      "reminderBefore": "",
      "extras": "{\\"startTimeExtraAlarm\\":\\"/handi/user/voicenotes/voice_recording_30ee75a1-6c2f-4fcd-9f06-d2365e6012b0.wav\\",\\"startTimeExtraAlarmFileId\\":\\"30ee75a1-6c2f-4fcd-9f06-d2365e6012b0\\"}",
      "recurrentType": 0,
      "recurrentData": 0,
      "alarmType": 100,
      "duration": 0,
      "category": 0,
      "startTime": 1625049000000,
      "endTime": 1625049000000,
      "fullDay": false,
      "checkable": false,
      "removeAfter": false,
      "secret": false,
      "description": null,
      "textToSpeech": false,
      "showInDayplan": true,
      "calendarId": "36a50dae-bede-4bdb-89ec-10229777c889",
      "secretExemptions" : [],
      "fileId": null
}''';
    final decoded = json.decode(response) as Map<String, dynamic>;
    final parsed = DbActivity.fromJson(decoded);
    final dbMap = parsed.toMapForDb();
    final fromDBmap = DbActivity.fromDbMap(dbMap);
    final toJson = fromDBmap.toJson();

    expect(fromDBmap, parsed);
    final encoded = json.encode(toJson);
    final decoded2 = json.decode(encoded) as Map<String, dynamic>;
    final parsed2 = DbActivity.fromJson(decoded2);
    final dbMap2 = parsed2.toMapForDb();
    expect(decoded.keys, containsAll(decoded2.keys));
    expect(decoded.values, containsAll(decoded2.values));
    expect(parsed, parsed2);
    expect(dbMap, dbMap2);
  });
  group('none recurring endTime', () {
    test('new, no duration correct endTime', () {
      final st = DateTime(2022, 2, 22, 22, 22);
      final a = Activity.createNew(startTime: st);
      expect(a.recurs.end, st);
    });

    test('new with duration correct endTime', () {
      final st = DateTime(2022, 2, 22, 22, 22);
      final d = 1.hours();
      final a = Activity.createNew(startTime: st, duration: d);
      expect(a.recurs.end, st.add(d));
    });

    test('new fullday correct endTime', () {
      final st = DateTime(2022, 2, 22, 22, 22);
      final expected = DateTime(2022, 2, 22, 23, 59, 59, 999);
      final d = 1.hours();
      final a = Activity.createNew(startTime: st, duration: d, fullDay: true);
      expect(a.recurs.end, expected);
    });

    test('copy, no duration correct endTime', () {
      final st = DateTime(100);
      final a = Activity.createNew(startTime: st);
      final st2 = DateTime(2022, 2, 22, 22, 22);
      final a2 = a.copyWith(startTime: st2);
      expect(a2.recurs.end, st2);
    });

    test('copy with duration correct endTime', () {
      final st = DateTime(2022, 2, 22, 22, 22);
      final d = 1.hours();
      final a = Activity.createNew(startTime: st, duration: d);
      final d2 = 23.hours();
      final a2 = a.copyWith(duration: d2);
      expect(a2.recurs.end, st.add(d2));
    });

    test('copy fullday correct endTime', () {
      final st = DateTime(2022, 2, 22, 22, 22);
      final expected = DateTime(2022, 2, 22, 23, 59, 59, 999);
      final d = 1.hours();
      final a = Activity.createNew(startTime: st, duration: d);
      final a2 = a.copyWith(fullDay: true);
      expect(a2.recurs.end, expected);
    });

    test('copy recurring correct endTime', () {
      final st = DateTime(2022, 2, 22, 22, 22);
      final d = 1.hours();
      final a = Activity.createNew(
        startTime: st,
        duration: d,
        recurs: Recurs.everyDay,
      );

      final a2 = a.copyWith(recurs: Recurs.not);
      expect(a.recurs.end, Recurs.noEndDate);
      expect(a2.recurs.end, st.add(d));
    });

    test('copy recurring fullday correct endTime', () {
      final st = DateTime(2022, 2, 22, 22, 22);
      final expected = DateTime(2022, 2, 22, 23, 59, 59, 999);
      final d = 1.hours();
      final a = Activity.createNew(
        startTime: st,
        duration: d,
        fullDay: true,
        recurs: Recurs.everyDay,
      );

      final a2 = a.copyWith(recurs: Recurs.not);
      expect(a.recurs.end, Recurs.noEndDate);
      expect(a2.recurs.end, expected);
    });

    test('calendar with calendarId stored', () {
      const calId = 'calendarId';

      final amodel = Activity.createNew(
        startTime: DateTime(2022, 2, 22, 22, 22),
        calendarId: calId,
      ).wrapWithDbModel();

      final json = amodel.toJson();
      expect(json['calendarId'], calId);
      final dbMap = amodel.toMapForDb();
      expect(dbMap['calendar_id'], calId);
    });

    test('calendar without calendarId toJson is ignored', () {
      final json = Activity.createNew(
        startTime: DateTime(2022, 2, 22, 22, 22),
      ).wrapWithDbModel().toJson();
      expect(json['calendarId'], isNull);
    });
  });
}
