import 'package:auth/auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LogoutButton extends StatelessWidget {
  const LogoutButton({super.key});

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: () =>
          context.read<AuthenticationBloc>().add(const LoggedOut()),
      child: const Text('Log out'),
    );
  }
}
