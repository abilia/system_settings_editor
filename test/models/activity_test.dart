import 'dart:collection';
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:seagull/models/activity.dart';
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
          "checkable" : false,
          "removeAfter" : false,
          "secret" : false,
          "fileId" : "1a1b1678-781e-4b6f-9518-b6858560433f"
        } ]''';
    final resultList = (json.decode(response) as List)
        .map((e) => Activity.fromJson(e))
        .toList();
    expect(resultList.length, 1);
    final result = resultList.first;
    expect(result.id, "33451ee6-cec6-4ce0-b515-f58767b13c8f");
    // expect(result.owner, 104);
    expect(result.revision, 100);
    // expect(result.revisionTime, 0);
    expect(result.deleted, false);
    expect(result.seriesId, "33451ee6-cec6-4ce0-b515-f58767b13c8f");
    // expect(result.groupActivityId, null);
    expect(result.title, "Title");
    // expect(result.timezone, "Europe/Stockholm");
    expect(result.icon, "/images/play.png");
    // expect(result.signedOffDates, null);
    expect(result.infoItem, null);
    expect(result.reminderBefore, UnmodifiableListView([]));
    // expect(result.extras, null);
    expect(result.recurrentType, 0);
    expect(result.recurrentData, 0);
    expect(result.alarmType, 0);
    expect(result.duration, 3600000);
    expect(result.category, 0);
    expect(result.startTime, 1570105439424);
    expect(result.endTime, 1570109039424);
    expect(result.fullDay, false);
    // expect(result.checkable, false);
    // expect(result.removeAfter, false);
    // expect(result.secret, false);
    expect(result.fileId, "1a1b1678-781e-4b6f-9518-b6858560433f");
  });

  test('create, serialize and deserialize test', () {
    final now = DateTime.now().millisecondsSinceEpoch;
    final fileId = Uuid().v4();
    final duration = Duration(minutes: 90).inMilliseconds;
    final reminders = {
      Duration(minutes: 5).inMilliseconds,
      Duration(hours: 1).inMilliseconds
    };

    final activity = Activity.createNew(
        title: "An interesting title",
        category: 4,
        duration: duration,
        reminderBefore: reminders,
        startTime: now,
        recurrentData: 1,
        recurrentType: 1,
        fileId: fileId);
    final asJson = activity.toJson();
    final deserializedActivity = Activity.fromJson(asJson);
    expect(deserializedActivity, activity);
    expect(deserializedActivity.id, activity.id);
    expect(deserializedActivity.seriesId, activity.seriesId);
    expect(deserializedActivity.title, activity.title);
    expect(deserializedActivity.category, activity.category);
    expect(deserializedActivity.duration, activity.duration);
    expect(deserializedActivity.reminderBefore, activity.reminderBefore);
    expect(deserializedActivity.startTime, activity.startTime);
    expect(deserializedActivity.endTime, activity.endTime);
    expect(deserializedActivity.fileId, activity.fileId);
    expect(deserializedActivity.icon, activity.icon);
    expect(deserializedActivity.recurrentType, activity.recurrentType);
    expect(deserializedActivity.recurrentData, activity.recurrentData);
    expect(deserializedActivity.deleted, activity.deleted);
    expect(deserializedActivity.revision, activity.revision);
    expect(deserializedActivity.alarmType, activity.alarmType);
  });
}
