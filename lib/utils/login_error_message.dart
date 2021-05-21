import 'package:seagull/bloc/all.dart';
import 'package:seagull/i18n/all.dart';

extension LoginFailureErrorMessage on LoginFailureCause {
  String heading(Translated translate) {
    switch (this) {
      case LoginFailureCause.LicenseExpired:
        return translate.licenseExpired;
      default:
        return translate.error;
    }
  }

  String message(Translated translate) {
    switch (this) {
      case LoginFailureCause.Credentials:
        return translate.wrongCredentials;
      case LoginFailureCause.NoConnection:
        return translate.noConnection;
      case LoginFailureCause.LicenseExpired:
        return translate.licenseExpiredMessage;
      case LoginFailureCause.NoLicense:
        return translate.noLicense;
      case LoginFailureCause.NoUsername:
        return translate.enterUsername;
      case LoginFailureCause.NoPassword:
        return translate.enterPassword;
      default:
        return '';
    }
  }
}
