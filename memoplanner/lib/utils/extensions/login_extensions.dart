import 'package:memoplanner/bloc/all.dart';
import 'package:memoplanner/l10n/all.dart';

extension LoginFailureErrorMessage on LoginFailureCause {
  String heading(Lt translate) {
    switch (this) {
      case LoginFailureCause.licenseExpired:
        return translate.licenseExpired;
      default:
        return translate.error;
    }
  }

  String message(Lt translate) {
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
      case LoginFailureCause.notEmptyDatabase:
        return translate.unknownError;
      case LoginFailureCause.tooManyAttempts:
        return translate.tooManyAttempts;
      default:
        return '';
    }
  }
}
