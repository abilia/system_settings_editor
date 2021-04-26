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
