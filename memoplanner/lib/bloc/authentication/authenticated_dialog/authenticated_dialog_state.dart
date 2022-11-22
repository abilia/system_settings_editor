part of 'authenticated_dialog_cubit.dart';

abstract class AuthenticatedDialogState {
  final TermsOfUse termsOfUse;

  const AuthenticatedDialogState(this.termsOfUse);
}

class AuthenticatedDialogReady extends AuthenticatedDialogState {
  const AuthenticatedDialogReady(TermsOfUse termsOfUse) : super(termsOfUse);
}

class AuthenticatedDialogNotReady extends AuthenticatedDialogState {
  final bool sortablesLoaded;
  final bool termsOfUseLoaded;

  bool get dialogsReady => sortablesLoaded && termsOfUseLoaded;

  const AuthenticatedDialogNotReady({
    required TermsOfUse termsOfUse,
    required this.sortablesLoaded,
    required this.termsOfUseLoaded,
  }) : super(termsOfUse);

  factory AuthenticatedDialogNotReady.initial() => AuthenticatedDialogNotReady(
        sortablesLoaded: false,
        termsOfUseLoaded: false,
        termsOfUse: TermsOfUse.notAccepted(),
      );

  AuthenticatedDialogNotReady copyWith({
    bool? sortablesLoaded,
    bool? termsOfUseLoaded,
    TermsOfUse? termsOfUse,
  }) =>
      AuthenticatedDialogNotReady(
        sortablesLoaded: sortablesLoaded ?? this.sortablesLoaded,
        termsOfUseLoaded: termsOfUseLoaded ?? this.termsOfUseLoaded,
        termsOfUse: termsOfUse ?? this.termsOfUse,
      );
}
