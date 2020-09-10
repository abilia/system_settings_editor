import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/utils/all.dart';
import 'package:uuid/uuid.dart';

void main() {
  test('parse json test', () {
    final response = '''[ {
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
          "fileId" : "1a1b1678-781e-4b6f-9518-b6858560433f"
        } ]''';
    final resultList = (json.decode(response) as List)
        .map((e) => DbActivity.fromJson(e))
        .toList();
    expect(resultList.length, 1);
    final result = resultList.first.activity;
    expect(result.id, '33451ee6-cec6-4ce0-b515-f58767b13c8f');
    // expect(result.owner, 104);
    expect(resultList.first.revision, 100);
    // expect(result.revisionTime, 0);
    expect(result.deleted, false);
    expect(result.seriesId, '33451ee6-cec6-4ce0-b515-f58767b13c8f');
    // expect(result.groupActivityId, null);
    expect(result.title, 'Title');
    // expect(result.timezone, "Europe/Stockholm");
    expect(result.icon, '/images/play.png');
    expect(result.signedOffDates, [
      DateTime(2020, 02, 12),
      DateTime(2020, 02, 13),
      DateTime(2020, 02, 15),
      DateTime(2020, 02, 20),
      DateTime(2020, 02, 27),
    ]);
    expect(result.infoItem, InfoItem.none);
    expect(result.reminderBefore,
        [1.days().inMilliseconds, 5.minutes().inMilliseconds]);
    expect(result.reminders, [1.days(), 5.minutes()]);
    // expect(result.extras, null);
    expect(result.recurs.type, 0);
    expect(result.recurs.data, 0);
    expect(result.alarmType, 0);
    expect(result.duration, 3600000.milliseconds());
    expect(result.category, 0);
    expect(result.startTime, 1570105439424.fromMillisecondsSinceEpoch());
    expect(result.recurs.endTime, 1570109039424);
    expect(result.fullDay, false);
    expect(result.checkable, true);
    expect(result.removeAfter, false);
    expect(result.secret, false);
    expect(result.fileId, '1a1b1678-781e-4b6f-9518-b6858560433f');
  });
  test('parse json with nulls test', () {
    final response = '''[ {
          "id" : "33451ee6-cec6-4ce0-b515-f58767b13c8f",
          "owner" : 104,
          "revision" : 100,
          "revisionTime" : 0,
          "deleted" : false,
          "seriesId" : "33451ee6-cec6-4ce0-b515-f58767b13c8f",
          "groupActivityId" : null,
          "title" : "Title",
          "timezone" : "Europe/Stockholm",
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

    // expect(result.groupActivityId, null);
    expect(result.icon, null);
    expect(result.signedOffDates, []);
    expect(result.infoItem, InfoItem.none);
    expect(result.reminderBefore, []);
    expect(result.reminders, []);
    // expect(result.extras, null);
    expect(result.fileId, null);
  });
  test('parse json with empty string test', () {
    final response = '''[ {
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
    expect(result.icon, null);
    expect(result.signedOffDates, []);
    expect(result.infoItem, InfoItem.none);
    expect(result.reminderBefore, []);
    expect(result.reminders, []);
    // expect(result.extras, null);
    expect(result.fileId, null);
  });

  test('create, serialize and deserialize test', () {
    final now = DateTime(2020, 02, 02, 02, 02, 02, 02);
    final fileId = Uuid().v4();
    final duration = Duration(minutes: 90);
    final reminders = {
      Duration(minutes: 5).inMilliseconds,
      Duration(hours: 1).inMilliseconds
    };
    final infoItem = NoteInfoItem('just a note');

    final activity = Activity.createNew(
      title: 'An interesting title',
      category: 4,
      duration: duration,
      reminderBefore: reminders,
      startTime: now,
      recurs: Recurs.biWeeklyOnDays(evens: [
        DateTime.monday,
        DateTime.saturday,
      ]),
      fileId: fileId,
      checkable: true,
      signedOffDates: [DateTime(2000, 02, 20)],
      infoItem: infoItem,
    );
    final dbActivity = activity.wrapWithDbModel();
    final asJson = dbActivity.toJson();
    final deserializedDbActivity = DbActivity.fromJson(asJson);
    final deserializedActivity = deserializedDbActivity.activity;
    expect(deserializedActivity.id, activity.id);
    expect(deserializedActivity.seriesId, activity.seriesId);
    expect(deserializedActivity.title, activity.title);
    expect(deserializedActivity.category, activity.category);
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
    expect(deserializedActivity, activity);
  });

  test('Copy with null', () {
    final now = DateTime(2020, 02, 02, 02, 02, 02, 02);
    final toCopy = Activity.createNew(
      title: 'Title',
      startTime: now,
      fileId: null,
    );
    final fileId = 'fileId';
    final original = Activity.createNew(
      title: 'Title',
      startTime: now,
      fileId: fileId,
    );
    final copy = original.copyActivity(toCopy);
    expect(copy.fileId, null);
  });
}
