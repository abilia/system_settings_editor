part of 'login_page.dart';

class LoginErrorListener extends StatelessWidget {
  final Widget child;
  const LoginErrorListener({required this.child, super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<LoginCubit, LoginState>(
      listener: (context, state) {
        if (state is LoginFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Container(
                height: 40,
                margin: const EdgeInsets.only(bottom: 120),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: ShapeDecoration(
                  color: abiliaBlack80,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Center(
                  child: Text(
                    userFacingMessage(state.cause, Lt.of(context)),
                    style: bodyMediumWhite,
                  ),
                ),
              ),
              backgroundColor: Colors.transparent,
              elevation: 1000,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
      child: child,
    );
  }

  String userFacingMessage(LoginFailureCause cause, Lt translate) {
    switch (cause) {
      case LoginFailureCause.credentials:
        return translate.wrong_username_or_password;
      case LoginFailureCause.licenseExpired:
        return translate.license_expired;
      case LoginFailureCause.noLicense:
        return translate.no_license;
      case LoginFailureCause.noUsername:
      case LoginFailureCause.noPassword:
      case LoginFailureCause.noConnection:
      case LoginFailureCause.unsupportedUserType:
      case LoginFailureCause.notEmptyDatabase:
      case LoginFailureCause.tooManyAttempts:
        return cause.name;
    }
  }
}
