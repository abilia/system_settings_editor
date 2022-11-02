import 'package:flutter_test/flutter_test.dart';
import 'package:seagull/config.dart';

void main() {
  test('mp flavor. will fail if flavor is mpgo and Config.isMP is true',
      () async {
    expect(Config.isMP, const String.fromEnvironment('flavor') == 'mp');
  });
}
