import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:seagull/config.dart';
import 'package:seagull/models/all.dart';

import '../mocks_and_fakes/shared.mocks.dart';

void verifySyncGeneric(
  WidgetTester tester,
  MockGenericDb genericDb, {
  required String key,
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
  MockGenericDb genericDb, {
  required String key,
  dynamic matcher,
}) {
  if (Config.isMP) {
    return verifySyncGeneric(tester, genericDb, key: key, matcher: matcher);
  }
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
  MockGenericDb genericDb, {
  required Map<String, dynamic> keyMatch,
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

Generic<MemoplannerSettingData> memoplannerSetting(
    bool value, String identifier) {
  return Generic.createNew<MemoplannerSettingData>(
    data: MemoplannerSettingData.fromData(
      data: value,
      identifier: identifier,
    ),
  );
}
