import 'package:auth/auth.dart';
import 'package:carymessenger/ui/pages/widgets/agenda.dart';
import 'package:carymessenger/ui/pages/widgets/clock_and_date.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MainPage extends StatelessWidget {
  final Authenticated authenticated;

  const MainPage({
    required this.authenticated,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 24.0),
          child: Column(
            children: [
              const ClockAndDate(),
              const Expanded(
                child: Agenda(),
              ),
              FilledButton(
                onPressed: () =>
                    context.read<AuthenticationBloc>().add(const LoggedOut()),
                child: const Text('Log out'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
