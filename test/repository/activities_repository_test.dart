import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart';
import 'package:mockito/mockito.dart';
import 'package:seagull/fakes/all.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/repository/all.dart';

import '../mocks.dart';

void main() {
  final baseUrl = 'oneUrl';
  final mockClient = MockClient();
  final mockActivitiesDb = MockActivityDb();
  final userId = 1;
  final startTime = DateTime(2020, 12, 12, 12, 12);
  final successActivity = Activity.createNew(
    title: 'title',
    startTime: startTime.millisecondsSinceEpoch,
    duration: 0,
    category: 0,
    reminderBefore: [],
  );
  final failedActivity = Activity.createNew(
    title: 'title2',
    startTime: startTime.millisecondsSinceEpoch,
    duration: 0,
    category: 0,
    reminderBefore: [],
  );
  final activities = [successActivity, failedActivity];

  final activityRepo = ActivityRepository(
      baseUrl: baseUrl,
      client: mockClient,
      activitiesDb: mockActivitiesDb,
      authToken: Fakes.token,
      userId: userId);

  test('Successfully saved are stored and returned', () async {
    // Arrange
    when(
      mockClient.post(
        '$baseUrl/api/v1/data/$userId/activities',
        headers: jsonAuthHeader(Fakes.token),
        body: jsonEncode(activities),
      ),
    ).thenAnswer(
      (_) => Future.value(
        Response(
          '''
          {
            "previousRevision" : 100,
            "dataRevisionUpdates" : [ {
              "id" : "${successActivity.id}",
              "newRevision" : 102
            } ],
            "failedUpdates" : [ {
              "id" : "${failedActivity.id}",
              "newRevision" : 101
            } ]
          }
          ''',
          200,
        ),
      ),
    );
    final expectedResult = [successActivity.copyWith(revision: 102)];

    // Act
    final result = await activityRepo.saveActivities(activities);
    // Assert
    verify(mockActivitiesDb.insertActivities(expectedResult));
    expect(result, expectedResult);
  });

  test('offline case', () async {
    // Arrange
    when(
      mockClient.post(
        '$baseUrl/api/v1/data/$userId/activities',
        headers: authHeader(Fakes.token),
        body: jsonEncode(activities),
      ),
    ).thenThrow(Exception());

    // Act
    // Assert
    expect(activityRepo.saveActivities(activities), throwsA(anything));
  }, skip: '🧚‍♂️we🏂dont🕴️have🧞‍♀️an💂offline🕵️case👩‍🚀yet🌚');
}
