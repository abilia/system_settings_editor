import 'package:auth/bloc/authentication/authentication_bloc.dart';
import 'package:auth/bloc/license/license_cubit.dart';
import 'package:calendar_events/calendar_events.dart';
import 'package:carymessenger/copied_providers.dart';
import 'package:carymessenger/cubit/alarm_cubit.dart';
import 'package:carymessenger/ui/pages/alarm_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AuthenticatedListener extends StatelessWidget {
  final Widget child;

  const AuthenticatedListener({required this.child, super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<LicenseCubit, LicenseState>(
          listener: (context, state) async {
            if (state is! ValidLicense) {
              BlocProvider.of<AuthenticationBloc>(context).add(
                const LoggedOut(
                  loggedOutReason: LoggedOutReason.noLicense,
                ),
              );
            }
          },
        ),
        BlocListener<AlarmCubit, ActivityDay?>(
          listener: (context, state) async {
            if (state != null) {
              final authProviders = copiedAuthProviders(context);
              await Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute<void>(
                  builder: (_) => AlarmPage(
                    activityDay: state,
                    providers: authProviders,
                  ),
                ),
                (route) => route.isFirst,
              );
            }
          },
        ),
      ],
      child: child,
    );
  }
}
