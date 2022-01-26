import 'package:flutter_test/flutter_test.dart';
import 'package:seagull/db/all.dart';
import 'package:seagull/models/all.dart';
import 'package:shared_preferences/shared_preferences.dart';

main() {
  test('Persist login info', () async {
    SharedPreferences.setMockInitialValues({});
    SharedPreferences pref = await SharedPreferences.getInstance();
    final loginDb = LoginDb(pref);

    expect(loginDb.getLoginInfo(), null);

    const loginInfo =
        LoginInfo(token: 'token', endDate: 1, renewToken: 'renew');
    await loginDb.persistLoginInfo(loginInfo);
    expect(loginDb.getLoginInfo(), loginInfo);
  });
}
