import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:seagull/bloc.dart';
import 'package:seagull/fakes/fake_client.dart';
import 'package:seagull/models/alarm_type.dart';
import 'package:seagull/repository/end_point.dart';
import 'package:seagull/repository/user_repository.dart';
import 'package:seagull/ui/colors.dart';
import 'package:seagull/utils.dart';

import '../../fakes/fake_activities.dart';

class BackendSwitches extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthenticationBloc, AuthenticationState>(
        builder: (context, state) {
      if (state is AuthenticationInitialized) {
        return Row(
            children: backEndEnviorments.entries
                .map(
          (kvp) => BackEndButton(
            kvp.key,
            userRepository: state.userRepository,
            client: Client(),
            backEndUrl: kvp.value,
          ),
        )
                .followedBy([
          BackEndButton(
            'Mock',
            userRepository: state.userRepository,
            backEndUrl: 'https://via.placeholder.com/190/CA0733/FFFFFF&',
            client: Fakes.client(),
          ),
          _alarms(state.userRepository),
        ]).toList());
      }
      return Container();
    });
  }

  BackEndButton _alarms(UserRepository repository) => BackEndButton(
        'Alarm',
        userRepository: repository,
        backEndUrl: 'https://via.placeholder.com/190/09CDDA/FFFFFF&',
        client: Fakes.client([
          FakeActivity.startsAfter(1.minutes()).copyWith(
              fileId: 'somefileid',
              alarmType: ALARM_SILENT,
              duration: 1.minutes().inMilliseconds,
              title: 'in 1, end in 2, SILENT'),
          FakeActivity.startsAfter(3.minutes()).copyWith(
              duration: 1.minutes().inMilliseconds,
              alarmType: ALARM_VIBRATION_ONLY_ON_START,
              title: 'in 3, VIBRATE'),
          FakeActivity.startsAfter(4.minutes()).copyWith(
              fileId: 'somefileid',
              duration: 1.minutes().inMilliseconds,
              alarmType: ALARM_SOUND_ONLY_ON_START,
              title: 'in 4, SOUND'),
          FakeActivity.startsAfter(5.minutes()).copyWith(
              duration: 1.minutes().inMilliseconds,
              alarmType: ALARM_SOUND_AND_VIBRATION,
              title: 'in 5, end in 6, SOUND & VIBRATION'),
        ]),
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
    return Expanded(
      child: FlatButton(
        padding: EdgeInsets.zero,
        textColor: userRepository.baseUrl == backEndUrl
            ? AbiliaColors.green
            : AbiliaColors.blue,
        onPressed: () => authBloc(context).add(AppStarted(
            userRepository.copyWith(httpClient: client, baseUrl: backEndUrl))),
        child: Text(text),
      ),
    );
  }
}
