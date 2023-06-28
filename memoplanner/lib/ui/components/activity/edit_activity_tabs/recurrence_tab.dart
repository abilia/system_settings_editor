import 'package:memoplanner/bloc/all.dart';
import 'package:memoplanner/models/all.dart';
import 'package:memoplanner/ui/all.dart';
import 'package:memoplanner/utils/all.dart';

class RecurrenceTab extends StatelessWidget with EditActivityTab {
  const RecurrenceTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final translate = Lt.of(context);
    final editActivityCubit = context.watch<EditActivityCubit>();
    final scrollController = ScrollController();
    final activity = editActivityCubit.state.activity;
    final recurs = activity.recurs;

    return ScrollArrows.vertical(
      controller: scrollController,
      child: ListView(
        controller: scrollController,
        padding: layout.templates.m1.onlyVertical,
        children: <Widget>[
          for (int i = 0; i < RecurrentType.values.length; i++)
            RadioField<RecurrentType>(
              groupValue: activity.recurs.recurrence,
              onChanged: (v) {
                if (v != null) {
                  editActivityCubit.changeRecurrentType(v);
                }
              },
              value: RecurrentType.values[i],
              leading: Icon(RecurrentType.values[i].iconData()),
              text: Text(RecurrentType.values[i].text(translate)),
            ).pad(
              i != RecurrentType.values.length - 1
                  ? m1ItemPadding.flipped
                  : m1ItemPadding.onlyHorizontal,
            ),
          if (recurs.weekly || recurs.monthly)
            BlocBuilder<WizardCubit, WizardState>(
              builder: (context, wizState) {
                final recurringDataError =
                    wizState.saveErrors.contains(SaveError.noRecurringDays);
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Divider().pad(
                      EdgeInsets.symmetric(
                        vertical: layout.formPadding.groupBottomDistance,
                      ),
                    ),
                    if (recurs.weekly)
                      Weekly(errorState: recurringDataError).pad(
                        layout.templates.m1.onlyHorizontal,
                      )
                    else if (recurs.monthly)
                      errorBordered(
                        const MonthDays(),
                        errorState: recurringDataError,
                      ).pad(m1ItemPadding.onlyHorizontal),
                    const Divider().pad(
                      EdgeInsets.only(
                        top: layout.formPadding.groupBottomDistance,
                      ),
                    ),
                    EndDateWidget(
                      errorState: wizState.saveErrors
                          .contains(SaveError.noRecurringEndDate),
                    ).pad(
                      layout.templates.m1.withoutBottom,
                    ),
                  ],
                );
              },
            ),
        ],
      ),
    );
  }
}

class Weekly extends StatelessWidget with EditActivityTab {
  final bool errorState;

  Weekly({
    required this.errorState,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          RecurringWeekCubit(context.read<EditActivityCubit>()),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          errorBordered(
            const Weekdays(),
            errorState: errorState,
          ),
          const EveryOtherWeekSwitch().pad(
            EdgeInsets.only(
              top: layout.formPadding.groupBottomDistance,
            ),
          ),
        ],
      ),
    );
  }
}

class EveryOtherWeekSwitch extends StatelessWidget {
  const EveryOtherWeekSwitch({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RecurringWeekCubit, RecurringWeekState>(
      buildWhen: (previous, current) =>
          previous.everyOtherWeek != current.everyOtherWeek,
      builder: (context, state) => SwitchField(
        leading: Icon(
          AbiliaIcons.thisWeek,
          size: layout.icon.small,
        ),
        value: state.everyOtherWeek,
        onChanged: (v) =>
            context.read<RecurringWeekCubit>().changeEveryOtherWeek(v),
        child: Text(
          Lt.of(context).everyOtherWeek,
        ),
      ),
    );
  }
}
