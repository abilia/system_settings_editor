import 'package:flutter_test/flutter_test.dart';

import 'package:memoplanner/config.dart';
import 'package:seagull_fakes/all.dart';

void verifyUnsyncedGenericMP(
  WidgetTester tester,
  MockGenericDb genericDb, {
  required String key,
  matcher,
}) {
  if (Config.isMP) {
    return verifySyncGeneric(tester, genericDb, key: key, matcher: matcher);
  }
  return verifyUnsyncedGeneric(tester, genericDb, key: key, matcher: matcher);
}
