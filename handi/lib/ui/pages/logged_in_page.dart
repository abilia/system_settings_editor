import 'package:auth/auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LoggedInPage extends StatelessWidget {
  final Authenticated authenticated;
  const LoggedInPage({
    required this.authenticated,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(child: Text('${authenticated.user}')),
          OutlinedButton(
            onPressed: () =>
                context.read<AuthenticationBloc>().add(const LoggedOut()),
            child: const Text('Log out'),
          ),
        ],
      ),
    ));
  }
}
