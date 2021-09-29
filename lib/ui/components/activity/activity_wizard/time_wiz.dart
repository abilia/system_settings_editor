import 'package:seagull/bloc/all.dart';
import 'package:seagull/ui/all.dart';

class TimeWiz extends StatelessWidget {
  const TimeWiz({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final startTimeFocus = FocusNode();
    final endTimeFocus = FocusNode();
    return BlocListener<ActivityWizardCubit, ActivityWizardState>(
      listenWhen: (_, current) => current.currentStep != WizardStep.time,
      listener: (context, state) {
        endTimeFocus.unfocus();
        startTimeFocus.unfocus();
      },
      child: BlocBuilder<MemoplannerSettingBloc, MemoplannerSettingsState>(
        buildWhen: (previous, current) =>
            previous.activityEndTimeEditable != current.activityEndTimeEditable,
        builder: (context, memoSettingsState) =>
            BlocBuilder<EditActivityBloc, EditActivityState>(
          buildWhen: (previous, current) =>
              previous.timeInterval != current.timeInterval,
          builder: (context, state) => Scaffold(
            appBar: AbiliaAppBar(
              iconData: AbiliaIcons.clock,
              title: Translator.of(context).translate.setTime,
            ),
            body: TimeInputContent(
              timeInput: TimeInput(
                  state.timeInterval.startTime,
                  state.timeInterval.sameTime ||
                          !memoSettingsState.activityEndTimeEditable
                      ? null
                      : state.timeInterval.endTime),
              startTimeFocusNode: startTimeFocus,
              endTimeFocusNode: endTimeFocus,
              is24HoursFormat: MediaQuery.of(context).alwaysUse24HourFormat,
              onSave: (context, _) {
                context.read<ActivityWizardCubit>().next();
                return false;
              },
              onValidTimeInput: (newTimeInput) =>
                  context.read<EditActivityBloc>().add(
                        ChangeTimeInterval(
                          startTime: newTimeInput.startTime,
                          endTime: newTimeInput.endTime,
                        ),
                      ),
              bottomNavigationBuilder: (_, __) =>
                  const WizardBottomNavigation(),
            ),
          ),
        ),
      ),
    );
  }
}
