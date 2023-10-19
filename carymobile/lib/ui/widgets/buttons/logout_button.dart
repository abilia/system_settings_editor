import 'package:auth/auth.dart';
import 'package:carymessenger/l10n/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LogoutButton extends StatelessWidget {
  const LogoutButton({super.key});

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: () =>
          context.read<AuthenticationBloc>().add(const LoggedOut()),
      child: Text(Lt.of(context).log_out),
    );
  }
}
