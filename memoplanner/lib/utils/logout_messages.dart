import 'package:seagull/bloc/authentication/authentication_bloc.dart';
import 'package:seagull/i18n/translations.g.dart';

extension LogoutMessage on LoggedOutReason {
  String header(Translated translate) {
    switch (this) {
      case LoggedOutReason.licenseExpired:
        return translate.licenseExpired;
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
      default:
        return '';
    }
  }
}
