import 'package:auth/auth.dart';
import 'package:memoplanner/i18n/translations.g.dart';

extension LogoutMessage on LoggedOutReason {
  String header(Translated translate) {
    switch (this) {
      case LoggedOutReason.licenseExpired:
        return translate.licenseExpired;
      case LoggedOutReason.unauthorized:
        return translate.unauthorizedHeader;
      default:
        return translate.error;
    }
  }

  String message(Translated translate) {
    switch (this) {
      case LoggedOutReason.licenseExpired:
        return translate.licenseExpiredMessage;
      case LoggedOutReason.noLicense:
        return translate.noLicense;
      case LoggedOutReason.unauthorized:
        return translate.unauthorizedMessage;
      default:
        return '';
    }
  }
}
