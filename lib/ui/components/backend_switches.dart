import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:seagull/bloc.dart';
import 'package:seagull/fakes/fake_client.dart';
import 'package:seagull/repository/end_point.dart';
import 'package:seagull/repository/user_repository.dart';
import 'package:seagull/ui/colors.dart';

class BackendSwitches extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthenticationBloc, AuthenticationState>(
        builder: (context, state) {
      if (state is AuthenticationInitialized) {
        return Row(children: 
          backEndEnviorments.entries.map((kvp) => 
            BackEndButton(
              kvp.key,
              userRepository: state.userRepository,
              client: Client(),
              backEndUrl: kvp.value,
            ),
          ).followedBy([BackEndButton(
            'Mock',
            userRepository: state.userRepository,
            backEndUrl: 'https://via.placeholder.com/190/CA0733/FFFFFF&',
            client: Fakes.client(),
          )]).toList()
        );
      }
      return Container();
    });
  }
}

class BackEndButton extends StatelessWidget {
  final UserRepository userRepository;
  final BaseClient client;

  final String backEndUrl;
  final String text;

  const BackEndButton(
    this.text, {
    @required this.userRepository,
    this.backEndUrl,
    @required this.client,
    Key key,
  }) : super(key: key);
  AuthenticationBloc authBloc(BuildContext context) =>
      BlocProvider.of<AuthenticationBloc>(context);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: FlatButton(
        padding: EdgeInsets.zero,
        textColor:
            userRepository.baseUrl == backEndUrl ? AbiliaColors.green : AbiliaColors.blue,
        onPressed: () => authBloc(context).add(AppStarted(
            userRepository.copyWith(client: client, baseUrl: backEndUrl))),
        child: Text(text),
      ),
    );
  }
}
