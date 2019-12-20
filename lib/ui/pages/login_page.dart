import 'package:flutter/material.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/repository/all.dart';
import 'package:seagull/ui/components/all.dart';

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
          create: (context) => LoginBloc(
            authenticationBloc: BlocProvider.of<AuthenticationBloc>(context),
            pushService: push,
          ),
        ),
        BlocProvider<LoginFormBloc>(create: (context) => LoginFormBloc()),
      ],
      child: Scaffold(
        body: SafeArea(
          child: LoginForm(),
        ),
      ),
    );
  }
}
