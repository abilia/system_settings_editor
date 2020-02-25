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
  final mockActivityDb = MockActivityDb();
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
    activityDb: mockActivityDb,
    userId: userId,
    authToken: Fakes.token,
  );

  test('Save activities saves to db', () async {
    // Act
    await activityRepo.saveActivities(activities);
    // Assert
    verify(mockActivityDb.insertDirtyActivities(activities));
  });

  test('Get dirty gets dirty from db', () async {
    await activityRepo.getDirtyActivities();
    verify(mockActivityDb.getDirtyActivities());
  });

  test('Insert activities inserts to db', () async {
    await activityRepo.insertActivities(activities);
    verify(mockActivityDb.insertActivities(activities));
  });

  test('Post activities gets correct answer', () async {
    // Arrange
    final jsonString = '''
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
          ''';
    when(
      mockClient.post(
        '$baseUrl/api/v1/data/$userId/activities',
        headers: jsonAuthHeader(Fakes.token),
        body: jsonEncode(activities),
      ),
    ).thenAnswer(
      (_) => Future.value(
        Response(
          jsonString,
          200,
        ),
      ),
    );

    // Act
    final result = await activityRepo.postActivities(activities);
    final expected = ActivityUpdateResponse.fromJson(json.decode(jsonString));

    // Assert
    expect(result, expected);
  });

  test('postActivities throws exception when status not 200', () async {
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
          '',
          401,
        ),
      ),
    );

    // Act and expect
    expect(() => activityRepo.postActivities(activities), throwsException);
  });

  test('synchronizeLocalWithBackend updates revision from backend', () async {
    // Arrange
    final newRevision = 110;
    final syncToBackendResponse = '''
          {
            "previousRevision" : 100,
            "dataRevisionUpdates" : [ {
              "id" : "${successActivity.id}",
              "newRevision" : $newRevision
            } ],
            "failedUpdates" : []
          }
          ''';
    final activities = [successActivity.copyWith(dirty: 1)];
    when(mockActivityDb.getDirtyActivities())
        .thenAnswer((_) => Future.value(activities));
    when(mockClient.post(
      '$baseUrl/api/v1/data/$userId/activities',
      headers: jsonAuthHeader(Fakes.token),
      body: jsonEncode(activities),
    )).thenAnswer((_) => Future.value(
          Response(
            syncToBackendResponse,
            200,
          ),
        ));
    when(mockActivityDb.insertActivities(
            [successActivity.copyWith(revision: newRevision)]))
        .thenAnswer((_) => Future.value(List(1)));

    // Act
    await activityRepo.synchronizeLocalWithBackend();

    // Expect
    verify(mockClient.post(
      '$baseUrl/api/v1/data/$userId/activities',
      headers: jsonAuthHeader(Fakes.token),
      body: jsonEncode(activities),
    ));
    verify(mockActivityDb
        .insertActivities([successActivity.copyWith(revision: newRevision)]));
  });

  test('synchronizeLocalWithBackend - failed sync fetches from backend',
      () async {
    // Arrange
    final failedRevision = 99;
    final syncToBackendResponse = '''
          {
            "previousRevision" : 100,
            "dataRevisionUpdates" : [],
            "failedUpdates" : [
              {
              "id" : "${failedActivity.id}",
              "newRevision" : $failedRevision
            }
            ]
          }
          ''';
    final activities = [failedActivity.copyWith(dirty: 1)];
    when(mockActivityDb.getDirtyActivities())
        .thenAnswer((_) => Future.value(activities));
    when(mockClient.post(
      '$baseUrl/api/v1/data/$userId/activities',
      headers: jsonAuthHeader(Fakes.token),
      body: jsonEncode(activities),
    )).thenAnswer((_) => Future.value(
          Response(
            syncToBackendResponse,
            200,
          ),
        ));

    when(mockClient.get(
            '$baseUrl/api/v1/data/$userId/activities?revision=$failedRevision',
            headers: authHeader(Fakes.token)))
        .thenAnswer((_) => (Future.value(
              Response(
                json.encode([
                  failedActivity.copyWith(revision: failedRevision).toJson()
                ]),
                200,
              ),
            )));

    // Act
    await activityRepo.synchronizeLocalWithBackend();

    // Expect/Verify
    verify(mockActivityDb
        .insertActivities([failedActivity.copyWith(revision: failedRevision)]));
  });
}
