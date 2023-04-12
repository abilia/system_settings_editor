import 'package:auth/db/login_db.dart';
import 'package:auth/models/login_info.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:test/test.dart';

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
