import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/fakes/all.dart';
import 'package:seagull/models/alarm_type.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/repository/all.dart';
import 'package:seagull/ui/colors.dart';
import 'package:seagull/utils/all.dart';
import 'package:uuid/uuid.dart';

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
            _alarms(state.userRepository, DateTime.now()),
          ]).toList()),
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
        client: Fakes.client(
          () => [
            Activity.createNew(
                startTime: when.add(2.minutes()),
                fileId: Uuid().v4(),
                alarmType: ALARM_SILENT,
                checkable: true,
                duration: 1.minutes(),
                title: 'ALARM_SILENT'),
            Activity.createNew(
                startTime: when.add(4.minutes()),
                duration: 1.minutes(),
                checkable: true,
                alarmType: ALARM_VIBRATION,
                title: 'ALARM_VIBRATION'),
            Activity.createNew(
                startTime: when.add(6.minutes()),
                fileId: Uuid().v4(),
                checkable: true,
                duration: 1.minutes(),
                alarmType: ALARM_SOUND_ONLY_ON_START,
                title: 'ALARM_SOUND_ONLY_ON_START'),
            Activity.createNew(
                startTime: when.add(8.minutes()),
                duration: 1.minutes(),
                checkable: true,
                alarmType: ALARM_SOUND_AND_VIBRATION,
                title: 'ALARM_SOUND_AND_VIBRATION'),
            Activity.createNew(
                startTime: when.add(10.minutes()),
                duration: 1.minutes(),
                reminderBefore: [1.minutes().inMilliseconds],
                alarmType: NO_ALARM,
                checkable: true,
                title: 'NO_ALARM'),
            Activity.createNew(
                startTime: when.add(11.minutes()),
                reminderBefore: [10.minutes().inMilliseconds],
                checkable: true,
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
