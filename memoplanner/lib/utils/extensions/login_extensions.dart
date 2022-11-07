import 'package:memoplanner/bloc/all.dart';
import 'package:memoplanner/i18n/all.dart';

extension LoginFailureErrorMessage on LoginFailureCause {
  String heading(Translated translate) {
    switch (this) {
      case LoginFailureCause.licenseExpired:
        return translate.licenseExpired;
      default:
        return translate.error;
    }
  }

  String message(Translated translate) {
    switch (this) {
      case LoginFailureCause.credentials:
        return translate.wrongCredentials;
      case LoginFailureCause.noConnection:
        return translate.noConnection;
      case LoginFailureCause.licenseExpired:
        return translate.licenseExpiredMessage;
      case LoginFailureCause.noLicense:
        return translate.noLicense;
      case LoginFailureCause.noUsername:
        return translate.enterUsername;
      case LoginFailureCause.noPassword:
        return translate.enterPassword;
      case LoginFailureCause.unsupportedUserType:
        return translate.userTypeNotSupported;
      default:
        return '';
    }
  }
}
