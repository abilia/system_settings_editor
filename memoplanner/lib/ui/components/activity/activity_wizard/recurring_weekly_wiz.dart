import 'package:memoplanner/bloc/all.dart';
import 'package:memoplanner/ui/all.dart';

class RecurringWeeklyWiz extends StatelessWidget {
  const RecurringWeeklyWiz({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final translate = Lt.of(context);

    return WizardScaffold(
      title: translate.weekly,
      iconData: AbiliaIcons.week,
      body: BlocProvider(
        create: (context) =>
            RecurringWeekCubit(context.read<EditActivityCubit>()),
        child: Column(
          children: [
            SizedBox(height: layout.formPadding.groupTopDistance),
            const Weekdays().pad(layout.templates.m1.onlyHorizontal),
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
              text: Lt.of(context).deselectAll,
              icon: AbiliaIcons.cancel,
              style: actionButtonStyleDark,
              onPressed: () =>
                  context.read<RecurringWeekCubit>().selectWeekdays(),
            )
          : IconAndTextButton(
              text: Lt.of(context).selectAll,
              icon: AbiliaIcons.radioCheckboxSelected,
              style: actionButtonStyleDark,
              onPressed: () => context
                  .read<RecurringWeekCubit>()
                  .selectWeekdays(RecurringWeekState.allWeekdays),
            ),
    );
  }
}
