import 'package:seagull/bloc/all.dart';
import 'package:seagull/ui/all.dart';

class TimeWiz extends StatelessWidget {
  const TimeWiz({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EditActivityBloc, EditActivityState>(
      builder: (context, state) => Scaffold(
        appBar: AbiliaAppBar(
          iconData: AbiliaIcons.clock,
          title: Translator.of(context).translate.setTime,
        ),
        body: Padding(
          padding: ordinaryPadding,
          child: BlocBuilder<ActivityWizardCubit, ActivityWizardState>(
            builder: (context, wizState) => TimeIntervallPicker(
              state.timeInterval,
              startTimeError:
                  wizState.saveErrors.contains(SaveError.NO_START_TIME),
            ),
          ),
        ),
        bottomNavigationBar: WizardBottomNavigation(),
      ),
    );
  }
}
