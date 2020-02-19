import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/fakes/all.dart';
import 'package:seagull/models/alarm_type.dart';
import 'package:seagull/repository/all.dart';
import 'package:seagull/ui/colors.dart';
import 'package:seagull/utils/all.dart';

class BackendSwitches extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthenticationBloc, AuthenticationState>(
        builder: (context, state) {
      if (state is AuthenticationInitialized) {
        return Center(
          child: Wrap(
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
            _alarms(state.userRepository),
          ]).toList()),
        );
      }
      return Container();
    });
  }

  BackEndButton _alarms(UserRepository repository) => BackEndButton(
        'Mock',
        userRepository: repository,
        backEndUrl: 'https://via.placeholder.com/190/09CDDA/FFFFFF&',
        client: Fakes.client(
          () => [
            FakeActivity.startsIn(2.minutes()).copyWith(
                fileId: 'somefileid',
                alarmType: ALARM_SILENT,
                duration: 1.minutes().inMilliseconds,
                title: 'ALARM_SILENT'),
            FakeActivity.startsIn(4.minutes()).copyWith(
                duration: 1.minutes().inMilliseconds,
                alarmType: ALARM_VIBRATION,
                title: 'ALARM_VIBRATION'),
            FakeActivity.startsIn(6.minutes()).copyWith(
                fileId: 'somefileid',
                duration: 1.minutes().inMilliseconds,
                alarmType: ALARM_SOUND_ONLY_ON_START,
                title: 'ALARM_SOUND_ONLY_ON_START'),
            FakeActivity.startsIn(8.minutes()).copyWith(
                duration: 1.minutes().inMilliseconds,
                alarmType: ALARM_SOUND_AND_VIBRATION,
                title: 'ALARM_SOUND_AND_VIBRATION'),
            FakeActivity.startsIn(10.minutes()).copyWith(
                duration: 1.minutes().inMilliseconds,
                reminderBefore: [1.minutes().inMilliseconds],
                infoItem: 'some info',
                alarmType: NO_ALARM,
                title: 'NO_ALARM'),
            FakeActivity.startsIn(11.minutes()).copyWith(
                duration: 0,
                reminderBefore: [10.minutes().inMilliseconds],
                alarmType: ALARM_SILENT,
                title: 'ALARM_SILENT reminder 10 min before'),
          ],
        ),
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
      onPressed: () => authBloc(context).add(AppStarted(
          userRepository.copyWith(httpClient: client, baseUrl: backEndUrl))),
      child: Text(text),
    );
  }
}
