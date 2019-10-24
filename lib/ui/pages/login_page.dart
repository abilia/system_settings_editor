import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:seagull/bloc/authentication/bloc.dart';
import 'package:seagull/repository/user_repository.dart';
import 'package:seagull/bloc/login/bloc.dart';
import 'package:seagull/bloc/login/form/bloc.dart';
import 'package:seagull/ui/components/login_form.dart';

class LoginPage extends StatelessWidget {
  final UserRepository userRepository;

  const LoginPage({Key key, @required this.userRepository})
      : assert(userRepository != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<LoginBloc>(
          builder: (context) => LoginBloc(
            authenticationBloc: BlocProvider.of<AuthenticationBloc>(context),
            userRepository: userRepository,
          ),
        ),
        BlocProvider<LoginFormBloc>(builder: (context) => LoginFormBloc()),
      ],
      child: Scaffold(
        body: SafeArea(
          child: LoginForm(),
        ),
      ),
    );
  }
}
