import 'package:shared_preferences/shared_preferences.dart';

class TermsOfUseDb {
  static const String _termsOfUseRecord = 'termsOfUseRecord';

  final SharedPreferences preferences;

  TermsOfUseDb(this.preferences);

  Future<void> setTermsOfUseAccepted(bool termsOfUseAccepted) =>
      preferences.setBool(_termsOfUseRecord, termsOfUseAccepted);

  bool get termsOfUseAccepted =>
      preferences.getBool(_termsOfUseRecord) ?? false;
}
