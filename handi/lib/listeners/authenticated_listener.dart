import 'package:auth/bloc/authentication/authentication_bloc.dart';
import 'package:auth/bloc/license/license_cubit.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AuthenticatedListener extends StatelessWidget {
  final Widget child;

  const AuthenticatedListener({required this.child, super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<LicenseCubit, LicenseState>(
      listener: (context, state) async {
        if (state is! ValidLicense) {
          BlocProvider.of<AuthenticationBloc>(context).add(
            const LoggedOut(
              loggedOutReason: LoggedOutReason.noLicense,
            ),
          );
        }
      },
      child: child,
    );
  }
}
