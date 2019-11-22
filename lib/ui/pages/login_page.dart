import 'package:flutter/material.dart';
import 'package:seagull/bloc.dart';
import 'package:seagull/repositories.dart';
import 'package:seagull/repository/push.dart';
import 'package:seagull/ui/components.dart';

class LoginPage extends StatelessWidget {
  final UserRepository userRepository;
  final FirebasePushService push;

  const LoginPage({Key key, @required this.userRepository, @required this.push})
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
            pushService: push,
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
