import 'package:seagull/bloc/all.dart';
import 'package:seagull/i18n/all.dart';
import 'package:seagull/models/all.dart';

extension CreateAccountErrorMessage on CreateAccountFailed {
  String errorMessage(Translated translate) {
    switch (failure) {
      case CreateAccountFailure.NoUsername:
        return translate.enterUsername;
      case CreateAccountFailure.UsernameToShort:
        return translate.usernameToShort;
      case CreateAccountFailure.NoPassword:
        return translate.enterPassword;
      case CreateAccountFailure.PasswordToShort:
        return translate.passwordToShort;
      case CreateAccountFailure.NoConfirmPassword:
        return translate.confirmPassword;
      case CreateAccountFailure.PasswordMismatch:
        return translate.passwordMismatch;
      case CreateAccountFailure.TermsOfUse:
        return translate.confirmTermsOfUse;
      case CreateAccountFailure.PrivacyPolicy:
        return translate.confirmPrivacyPolicy;
      case CreateAccountFailure.UsernameTaken:
        return translate.usernameTaken;
      case CreateAccountFailure.NoConnection:
        return translate.noConnection;
      default:
        return '${translate.unknownError}\n$message';
    }
  }
}
