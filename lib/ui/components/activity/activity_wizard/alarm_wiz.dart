import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:seagull/bloc/activities/edit_activity/edit_activity_cubit.dart';
import 'package:seagull/models/activity/activity.dart';
import 'package:seagull/models/alarm.dart';
import 'package:seagull/ui/all.dart';

class AlarmWiz extends StatelessWidget {
  const AlarmWiz({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return WizardScaffold(
      iconData: AbiliaIcons.attention,
      title: Translator.of(context).translate.alarm,
      body: const SelectAlarmWizPage(),
    );
  }
}

class SelectAlarmWizPage extends StatelessWidget {
  const SelectAlarmWizPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EditActivityCubit, EditActivityState>(
      buildWhen: (previous, current) => previous.activity != current.activity,
      builder: (context, state) => SelectAlarmTypeBody(
        alarm: state.activity.alarm.typeSeagull,
        onChanged: (AlarmType? type) =>
            context.read<EditActivityCubit>().replaceActivity(
                  state.activity.copyWith(
                    alarm: state.activity.alarm.copyWith(type: type),
                  ),
                ),
        trailing: [
          const SizedBox(),
          const Divider(),
          SizedBox(height: 8.s),
          AlarmOnlyAtStartSwitch(
            alarm: state.activity.alarm,
            onChanged: (bool onStart) => context
                .read<EditActivityCubit>()
                .replaceActivity(
                  state.activity.copyWith(
                    alarm: state.activity.alarm.copyWith(onlyStart: onStart),
                  ),
                ),
          ),
          SizedBox(height: 8.s),
          const Divider(),
          SizedBox(height: 24.s),
          RecordSoundWidget(
            activity: state.activity,
            soundChanged: (Activity newActivity) =>
                context.read<EditActivityCubit>().replaceActivity(newActivity),
          ),
        ],
      ),
    );
  }
}
