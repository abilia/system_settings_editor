import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:seagull/db/all.dart';
import 'package:seagull/models/all.dart';

Future verifyGeneric(
  WidgetTester tester,
  GenericDb genericDb, {
  String key,
  dynamic matcher,
}) async {
  final v = verify(genericDb.insertAndAddDirty(captureAny));
  expect(v.callCount, 1);
  final l = v.captured.single.toList() as List<Generic<GenericData>>;
  final d = l.map((e) => e.data).firstWhere((data) => data.identifier == key)
      as MemoplannerSettingData;
  expect(d.data, matcher);
}

Future verifyGenerics(
  WidgetTester tester,
  GenericDb genericDb, {
  Map<String, dynamic> keyMatch,
}) async {
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
