import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/fakes/all.dart';
import 'package:seagull/repository/all.dart';
import 'package:seagull/ui/colors.dart';

class BackendSwitches extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthenticationBloc, AuthenticationState>(
        builder: (context, state) {
      if (state is AuthenticationInitialized) {
        return Center(
          child: Wrap(
            children: [
              ...backEndEnviorments.entries.map(
                (kvp) => BackEndButton(
                  kvp.key,
                  userRepository: state.userRepository,
                  client: Client(),
                  backEndUrl: kvp.value,
                ),
              ),
              _alarms(state.userRepository, DateTime.now()),
            ],
          ),
        );
      }
      return Container();
    });
  }

  BackEndButton _alarms(UserRepository repository, DateTime when) =>
      BackEndButton(
        'Mock',
        userRepository: repository,
        backEndUrl: 'https://via.placeholder.com/190/09CDDA/FFFFFF&',
        client: Fakes.client(activityResponse: () => []),
      );
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
    return FlatButton(
      padding: EdgeInsets.zero,
      textColor: userRepository.baseUrl == backEndUrl
          ? AbiliaColors.green
          : AbiliaColors.blue,
      onPressed: () => authBloc(context).add(
        AppStarted(
          userRepository.copyWith(
            client: client,
            baseUrl: backEndUrl,
          ),
        ),
      ),
      child: Text(text),
    );
  }
}
