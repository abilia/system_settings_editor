import 'package:seagull/bloc/all.dart';
import 'package:seagull/ui/all.dart';

class RecurringWeeklyWiz extends StatelessWidget {
  const RecurringWeeklyWiz({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final translate = Translator.of(context).translate;

    return Scaffold(
      appBar: AbiliaAppBar(
        title: translate.weekly,
        iconData: AbiliaIcons.week,
      ),
      body: BlocProvider(
        create: (context) =>
            RecurringWeekBloc(context.read<EditActivityBloc>()),
        child: Column(
          children: [
            SizedBox(height: 24.s),
            Padding(
              padding: EdgeInsets.zero,
              child: WeekDays(),
            ),
            SizedBox(height: 24.s),
            const SelectAllWeekdaysButton(),
            SizedBox(height: 24.s),
            const Divider(),
            SizedBox(height: 24.s),
            Padding(
              padding: EdgeInsets.only(
                left: 12.s,
                right: 16.s,
              ),
              child: EveryOtherWeekSwitch(),
            ),
            SizedBox(height: 8.s),
            Padding(
              padding: EdgeInsets.only(
                left: 12.s,
                right: 16.s,
              ),
              child: const EndDateWizWidget(),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const WizardBottomNavigation(),
    );
  }
}

class SelectAllWeekdaysButton extends StatelessWidget {
  const SelectAllWeekdaysButton({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RecurringWeekBloc, RecurringWeekState>(
      buildWhen: (previous, current) => previous.weekdays != current.weekdays,
      builder: (context, state) => state.containsAllWeekdays
          ? IconAndTextButton(
              text: Translator.of(context).translate.deselectAll,
              icon: AbiliaIcons.cancel,
              style: actionButtonStyleDark,
              onPressed: () =>
                  context.read<RecurringWeekBloc>().add(SelectWeekdays()),
            )
          : IconAndTextButton(
              text: Translator.of(context).translate.selectAll,
              icon: AbiliaIcons.radiocheckbox_selected,
              style: actionButtonStyleDark,
              onPressed: () => context
                  .read<RecurringWeekBloc>()
                  .add(SelectWeekdays(RecurringWeekState.allWeekdays)),
            ),
    );
  }
}
