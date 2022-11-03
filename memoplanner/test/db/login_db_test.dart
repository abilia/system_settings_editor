import 'package:flutter_test/flutter_test.dart';
import 'package:memoplanner/db/all.dart';
import 'package:memoplanner/models/all.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('Persist login info', () async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    final loginDb = LoginDb(preferences);

    expect(loginDb.getLoginInfo(), null);

    const loginInfo =
        LoginInfo(token: 'token', endDate: 1, renewToken: 'renew');
    await loginDb.persistLoginInfo(loginInfo);
    expect(loginDb.getLoginInfo(), loginInfo);
  });
}
