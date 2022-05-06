import 'package:seagull/bloc/all.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/ui/all.dart';

class TimeWiz extends StatelessWidget {
  const TimeWiz({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocListener<WizardCubit, WizardState>(
      listenWhen: (_, current) => current.currentStep != WizardStep.time,
      listener: (context, state) =>
          FocusScope.of(context).requestFocus(FocusNode()),
      child: WizardScaffold(
        iconData: AbiliaIcons.clock,
        title: Translator.of(context).translate.setTime,
        appBarTrailing: Padding(
          padding: layout.timeInput.headerClockPadding,
          child: AbiliaClock(
            style: Theme.of(context)
                .textTheme
                .caption
                ?.copyWith(color: AbiliaColors.white),
          ),
        ),
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
          BlocSelector<EditActivityCubit, EditActivityState, TimeInterval>(
        selector: (state) => state.timeInterval,
        builder: (context, timeInterval) => TimeInputContent(
          timeInput: TimeInput(
            timeInterval.startTime,
            timeInterval.sameTime || !showEndTime ? null : timeInterval.endTime,
          ),
          is24HoursFormat: MediaQuery.of(context).alwaysUse24HourFormat,
          onSave: (context, _) {
            context.read<WizardCubit>().next();
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
