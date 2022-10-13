import 'package:seagull/bloc/all.dart';
import 'package:seagull/ui/all.dart';

class RecurringWeeklyWiz extends StatelessWidget {
  const RecurringWeeklyWiz({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final translate = Translator.of(context).translate;

    return WizardScaffold(
      title: translate.weekly,
      iconData: AbiliaIcons.week,
      body: BlocProvider(
        create: (context) =>
            RecurringWeekCubit(context.read<EditActivityCubit>()),
        child: Column(
          children: [
            SizedBox(height: layout.formPadding.groupTopDistance),
            const WeekDays().pad(layout.templates.m1.onlyHorizontal),
            SizedBox(height: layout.formPadding.groupTopDistance),
            const SelectAllWeekdaysButton(),
            SizedBox(height: layout.formPadding.groupTopDistance),
            const Divider(),
            const EveryOtherWeekSwitch().pad(layout.templates.m1.withoutBottom),
            const EndDateWizWidget().pad(m1ItemPadding),
          ],
        ),
      ),
    );
  }
}

class SelectAllWeekdaysButton extends StatelessWidget {
  const SelectAllWeekdaysButton({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RecurringWeekCubit, RecurringWeekState>(
      buildWhen: (previous, current) => previous.weekdays != current.weekdays,
      builder: (context, state) => state.containsAllWeekdays
          ? IconAndTextButton(
              text: Translator.of(context).translate.deselectAll,
              icon: AbiliaIcons.cancel,
              style: actionButtonStyleDark,
              onPressed: () =>
                  context.read<RecurringWeekCubit>().selectWeekdays(),
            )
          : IconAndTextButton(
              text: Translator.of(context).translate.selectAll,
              icon: AbiliaIcons.radioCheckboxSelected,
              style: actionButtonStyleDark,
              onPressed: () => context
                  .read<RecurringWeekCubit>()
                  .selectWeekdays(RecurringWeekState.allWeekdays),
            ),
    );
  }
}
