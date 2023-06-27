import 'package:memoplanner/bloc/all.dart';
import 'package:memoplanner/models/all.dart';
import 'package:memoplanner/ui/all.dart';
import 'package:memoplanner/utils/all.dart';

class RecurrenceTab extends StatelessWidget with EditActivityTab {
  const RecurrenceTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final translate = Translator.of(context).translate;
    final editActivityCubit = context.watch<EditActivityCubit>();
    final selectedType = editActivityCubit.state.selectedType;
    final scrollController = ScrollController();
    return BlocProvider(
      create: (context) =>
          RecurringWeekCubit(context.read<EditActivityCubit>()),
      child: ScrollArrows.vertical(
        controller: scrollController,
        child: ListView(
          controller: scrollController,
          padding: layout.templates.m1.onlyVertical,
          children: <Widget>[
            ...[
              RecurrentType.none,
              RecurrentType.daily,
              RecurrentType.weekly,
              RecurrentType.monthly,
              RecurrentType.yearly,
            ].map(
              (recurrentType) => RadioField<RecurrentType>(
                groupValue: selectedType,
                onChanged: (v) {
                  if (v != null) {
                    editActivityCubit.changeRecurrentType(v);
                  }
                },
                value: recurrentType,
                leading: Icon(recurrentType.iconData()),
                text: Text(recurrentType.text(translate)),
              ).pad(
                recurrentType != RecurrentType.yearly
                    ? m1ItemPadding.flipped
                    : m1ItemPadding.onlyHorizontal,
              ),
            ),
            if (selectedType == RecurrentType.daily ||
                selectedType == RecurrentType.weekly ||
                selectedType == RecurrentType.monthly)
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
                      if (selectedType == RecurrentType.weekly) ...[
                        Weekly(errorState: recurringDataError).pad(
                          layout.templates.m1.onlyHorizontal,
                        ),
                        const Divider().pad(
                          EdgeInsets.symmetric(
                            vertical: layout.formPadding.groupTopDistance,
                          ),
                        ),
                        const EveryOtherWeekSwitch().pad(
                          layout.templates.m1.onlyHorizontal,
                        ),
                        SizedBox(
                            height: layout.formPadding.groupBottomDistance),
                      ] else if (selectedType == RecurrentType.monthly) ...[
                        errorBordered(
                          const MonthDays(),
                          errorState: recurringDataError,
                        ).pad(m1ItemPadding.onlyHorizontal),
                        const Divider().pad(
                          EdgeInsets.symmetric(
                            vertical: layout.formPadding.groupTopDistance,
                          ),
                        ),
                      ],
                      EndDateWidget(
                        errorState: wizState.saveErrors
                            .contains(SaveError.noRecurringEndDate),
                      ).pad(
                        layout.templates.m1.onlyHorizontal,
                      ),
                    ],
                  );
                },
              ),
          ],
        ),
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
    final translate = Translator.of(context).translate;
    final isAllSelected = context
        .select((RecurringWeekCubit cubit) => cubit.state.weekdays.length == 7);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        errorBordered(
          const Weekdays(),
          errorState: errorState,
        ),
        SizedBox(height: layout.formPadding.groupBottomDistance),
        Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconAndTextButton(
              style: actionButtonStyleDark,
              text: isAllSelected ? translate.deselectAll : translate.selectAll,
              icon: isAllSelected
                  ? AbiliaIcons.cancel
                  : AbiliaIcons.radioCheckboxSelected,
              onPressed: () => isAllSelected
                  ? context.read<RecurringWeekCubit>().selectWeekdays()
                  : context
                      .read<RecurringWeekCubit>()
                      .selectWeekdays(RecurringWeekState.allWeekdays),
            ),
          ],
        ),
      ],
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
          Translator.of(context).translate.everyOtherWeek,
        ),
      ),
    );
  }
}
