part of 'login_dialog_cubit.dart';

abstract class LoginDialogState {
  final TermsOfUse termsOfUse;

  const LoginDialogState(this.termsOfUse);
}

class LoginDialogReady extends LoginDialogState {
  const LoginDialogReady(TermsOfUse termsOfUse) : super(termsOfUse);
}

class LoginDialogNotReady extends LoginDialogState {
  final bool sortablesLoaded;
  final bool termsOfUseLoaded;

  bool get dialogsReady => sortablesLoaded && termsOfUseLoaded;

  const LoginDialogNotReady({
    required TermsOfUse termsOfUse,
    required this.sortablesLoaded,
    required this.termsOfUseLoaded,
  }) : super(termsOfUse);

  factory LoginDialogNotReady.initial() => LoginDialogNotReady(
        sortablesLoaded: false,
        termsOfUseLoaded: false,
        termsOfUse: TermsOfUse.notAccepted(),
      );

  LoginDialogNotReady copyWith({
    bool? sortablesLoaded,
    bool? termsOfUseLoaded,
    TermsOfUse? termsOfUse,
  }) =>
      LoginDialogNotReady(
        sortablesLoaded: sortablesLoaded ?? this.sortablesLoaded,
        termsOfUseLoaded: termsOfUseLoaded ?? this.termsOfUseLoaded,
        termsOfUse: termsOfUse ?? this.termsOfUse,
      );
}
