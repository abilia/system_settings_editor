// @dart=2.9

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:seagull/db/all.dart';
import 'package:seagull/models/all.dart';

void verifySyncGeneric(
  WidgetTester tester,
  GenericDb genericDb, {
  String key,
  dynamic matcher,
}) {
  final v = verify(genericDb.insertAndAddDirty(captureAny));
  expect(v.callCount, 1);
  final l = v.captured.single.toList() as List<Generic<GenericData>>;
  final d = l.map((e) => e.data).firstWhere((data) => data.identifier == key)
      as MemoplannerSettingData;
  expect(d.data, matcher);
}

void verifyUnsyncGeneric(
  WidgetTester tester,
  GenericDb genericDb, {
  String key,
  dynamic matcher,
}) {
  verifyNever(genericDb.insertAndAddDirty(captureAny));
  final v = verify(genericDb.insert(captureAny));
  expect(v.callCount, 1);
  final l = v.captured.single.toList() as List<DbModel<Generic<GenericData>>>;
  final d = l
      .map((e) => e.model.data)
      .firstWhere((data) => data.identifier == key) as MemoplannerSettingData;
  expect(d.data, matcher);
}

void verifyGenerics(
  WidgetTester tester,
  GenericDb genericDb, {
  Map<String, dynamic> keyMatch,
}) {
  final v = verify(genericDb.insertAndAddDirty(captureAny));
  expect(v.callCount, 1);
  final l = v.captured.single.toList() as List<Generic<GenericData>>;
  for (var kvp in keyMatch.entries) {
    final d = l
        .whereType<Generic<MemoplannerSettingData>>()
        .firstWhere((element) => element.data.identifier == kvp.key);
    expect(d.data.data, kvp.value);
  }
}
