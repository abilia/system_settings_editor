import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart';
import 'package:mockito/mockito.dart';
import 'package:seagull/fakes/all.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/repository/all.dart';
import 'package:seagull/utils/all.dart';

import '../../mocks.dart';

void main() {
  final baseUrl = 'oneUrl';
  final mockClient = MockedClient();
  final mockActivityDb = MockActivityDb();
  final userId = 1;
  final startTime = DateTime(2020, 12, 12, 12, 12);
  final successActivity = Activity.createNew(
    title: 'title',
    startTime: startTime,
    category: 0,
    reminderBefore: [],
  ).wrapWithDbModel();
  final failedActivity = Activity.createNew(
    title: 'title2',
    startTime: startTime,
    category: 0,
    reminderBefore: [],
  ).wrapWithDbModel();
  final dbActivities = [successActivity, failedActivity];
  final activities = dbActivities.map((a) => a.activity);

  final activityRepo = ActivityRepository(
    baseUrl: baseUrl,
    client: mockClient,
    activityDb: mockActivityDb,
    userId: userId,
    authToken: Fakes.token,
  );

  test('Save activities saves to db', () async {
    // Act
    await activityRepo.save(activities);
    // Assert
    verify(mockActivityDb.insertAndAddDirty(activities));
  });

  test('Post activities gets correct answer', () async {
    // Arrange
    final jsonString = '''
          {
            "previousRevision" : 100,
            "dataRevisionUpdates" : [ {
              "id" : "${successActivity.activity.id}",
              "newRevision" : 102
            } ],
            "failedUpdates" : [ {
              "id" : "${failedActivity.activity.id}",
              "newRevision" : 101
            } ]
          }
          ''';
    when(
      mockClient.post(
        '$baseUrl/api/v2/data/$userId/activities'.toUri(),
        headers: jsonAuthHeader(Fakes.token),
        body: jsonEncode(dbActivities),
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
    final result = await activityRepo.postData(dbActivities);
    final expected = DataUpdateResponse.fromJson(json.decode(jsonString));

    // Assert
    expect(result, expected);
  });

  test('postActivities throws exception when status not 200', () async {
    // Arrange
    when(
      mockClient.post(
        '$baseUrl/api/v2/data/$userId/activities'.toUri(),
        headers: jsonAuthHeader(Fakes.token),
        body: jsonEncode(dbActivities),
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
    expect(() => activityRepo.postData(dbActivities), throwsException);
  });

  test('synchronizeLocalWithBackend updates revision from backend', () async {
    // Arrange
    final newRevision = 110;
    final syncToBackendResponse = '''
          {
            "previousRevision" : 100,
            "dataRevisionUpdates" : [ {
              "id" : "${successActivity.activity.id}",
              "newRevision" : $newRevision
            } ],
            "failedUpdates" : []
          }
          ''';
    final firstDirty = 1;
    final activities = [successActivity.copyWith(dirty: 1)];
    when(mockActivityDb.getAllDirty())
        .thenAnswer((_) => Future.value(activities));
    when(mockClient.post(
      '$baseUrl/api/v2/data/$userId/activities'.toUri(),
      headers: jsonAuthHeader(Fakes.token),
      body: jsonEncode(activities),
    )).thenAnswer((_) => Future.value(
          Response(
            syncToBackendResponse,
            200,
          ),
        ));
    when(mockActivityDb
            .insert([successActivity.copyWith(revision: newRevision)]))
        .thenAnswer((_) => Future.value(List.filled(1, null)));
    final newDirty = 5;
    when(mockActivityDb.getById(successActivity.activity.id))
        .thenAnswer((_) => Future.value(successActivity.copyWith(dirty: 5)));

    // Act
    await activityRepo.synchronize();

    // Expect
    verify(mockClient.post(
      '$baseUrl/api/v2/data/$userId/activities'.toUri(),
      headers: jsonAuthHeader(Fakes.token),
      body: jsonEncode(activities),
    ));
    verify(mockActivityDb.insert([
      successActivity.copyWith(
          revision: newRevision, dirty: newDirty - firstDirty)
    ]));
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
              "id" : "${failedActivity.activity.id}",
              "newRevision" : $failedRevision
            }
            ]
          }
          ''';
    final activities = [failedActivity.copyWith(dirty: 1)];
    when(mockActivityDb.getAllDirty())
        .thenAnswer((_) => Future.value(activities));
    when(mockActivityDb.getLastRevision()).thenAnswer((_) => Future.value(100));
    when(mockClient.post(
      '$baseUrl/api/v2/data/$userId/activities'.toUri(),
      headers: jsonAuthHeader(Fakes.token),
      body: jsonEncode(activities),
    )).thenAnswer((_) => Future.value(
          Response(
            syncToBackendResponse,
            200,
          ),
        ));

    when(mockClient.get(
            '$baseUrl/api/v1/data/$userId/activities?revision=$failedRevision'.toUri(),
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
    await activityRepo.synchronize();

    // Expect/Verify
    verify(mockActivityDb
        .insert([failedActivity.copyWith(revision: failedRevision)]));
  });

  test('synchronize - calls fetch before posting', () async {
    // Arrange
    when(mockActivityDb.getLastRevision()).thenAnswer((_) => Future.value(1));
    when(mockClient.get(any, headers: anyNamed('headers')))
        .thenAnswer((_) => Future.value(Response('[]', 200)));
    when(mockActivityDb.getAllDirty()).thenAnswer((_) => Future.value([]));

    // Act
    await activityRepo.synchronize();

    // Verify
    verifyInOrder([
      mockActivityDb.getLastRevision(),
      mockClient.get(any, headers: anyNamed('headers')),
      mockActivityDb.insert([]),
      mockActivityDb.getAllDirty(),
    ]);
  });
}
