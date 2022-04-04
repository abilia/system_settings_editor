import 'package:seagull/bloc/all.dart';
import 'package:seagull/ui/all.dart';

class TimeWiz extends StatelessWidget {
  const TimeWiz({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocListener<ActivityWizardCubit, ActivityWizardState>(
      listenWhen: (_, current) => current.currentStep != WizardStep.time,
      listener: (context, state) =>
          FocusScope.of(context).requestFocus(FocusNode()),
      child: WizardScaffold(
        iconData: AbiliaIcons.clock,
        title: Translator.of(context).translate.setTime,
        body: const _TimeWizContent(),
        bottomNavigationBar: null,
      ),
    );
  }
}

class _TimeWizContent extends StatelessWidget {
  const _TimeWizContent({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocSelector<MemoplannerSettingBloc, MemoplannerSettingsState, bool>(
      selector: (state) => state.settings.addActivity.showEndTime,
      builder: (context, showEndTime) =>
          BlocBuilder<EditActivityCubit, EditActivityState>(
        buildWhen: (previous, current) =>
            previous.timeInterval != current.timeInterval,
        builder: (context, state) => TimeInputContent(
          timeInput: TimeInput(
              state.timeInterval.startTime,
              state.timeInterval.sameTime || !showEndTime
                  ? null
                  : state.timeInterval.endTime),
          is24HoursFormat: MediaQuery.of(context).alwaysUse24HourFormat,
          onSave: (context, _) {
            context.read<ActivityWizardCubit>().next();
            return false;
          },
          onValidTimeInput: (newTimeInput) =>
              context.read<EditActivityCubit>().changeTimeInterval(
                    startTime: newTimeInput.startTime,
                    endTime: newTimeInput.endTime,
                  ),
          bottomNavigationBuilder: (_, __) => const WizardBottomNavigation(),
        ),
      ),
    );
  }
}
