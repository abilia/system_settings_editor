import 'package:auth/auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:handi/bloc/base_url_cubit.dart';
import 'package:repository_base/end_point.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<LoginCubit>().state;
    return Scaffold(
      body: BlocListener<LoginCubit, LoginState>(
        listener: (context, state) {
          if (state is LoginFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.cause.name),
              ),
            );
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Username'),
                  Tooltip(
                    message: 'Username',
                    child: TextField(
                      onChanged: context.read<LoginCubit>().usernameChanged,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Password'),
                  Tooltip(
                    message: 'Password',
                    child: TextField(
                      onChanged: context.read<LoginCubit>().passwordChanged,
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ...backendEnvironments.entries.map(
                    (kvp) => Builder(
                      builder: (context) => RadioMenuButton(
                        value: kvp.key,
                        onChanged: (s) =>
                            context.read<BaseUrlCubit>().updateBaseUrl(kvp.key),
                        groupValue: context.watch<BaseUrlCubit>().state,
                        child: Text(kvp.value),
                      ),
                    ),
                  ),
                ],
              ),
              OutlinedButton(
                onPressed: state.isFormValid
                    ? context.read<LoginCubit>().loginButtonPressed
                    : null,
                child: const Text('Sign in'),
              )
            ],
          ),
        ),
      ),
    );
  }
}
