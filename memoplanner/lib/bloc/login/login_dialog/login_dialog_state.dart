part of 'login_dialog_cubit.dart';

abstract class LoginDialogState {
  LoginDialogState();
}

class LoginDialogReady extends LoginDialogState {
  LoginDialogReady();
}

class LoginDialogNotReady extends LoginDialogState {
  final bool sortablesLoaded;
  final bool termsOfUseLoaded;

  bool get dialogsReady => sortablesLoaded && termsOfUseLoaded;

  LoginDialogNotReady({
    required this.sortablesLoaded,
    required this.termsOfUseLoaded,
  });

  factory LoginDialogNotReady.initial() => LoginDialogNotReady(
        sortablesLoaded: false,
        termsOfUseLoaded: false,
      );

  LoginDialogNotReady copyWith({
    bool? sortablesLoaded,
    bool? termsOfUseLoaded,
  }) =>
      LoginDialogNotReady(
        sortablesLoaded: sortablesLoaded ?? this.sortablesLoaded,
        termsOfUseLoaded: termsOfUseLoaded ?? this.termsOfUseLoaded,
      );
}
