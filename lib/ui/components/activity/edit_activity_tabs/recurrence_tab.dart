import 'package:seagull/bloc/all.dart';
import 'package:seagull/ui/all.dart';

class RecurrenceTab extends StatelessWidget with EditActivityTab {
  const RecurrenceTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final _scrollController = ScrollController();
    return BlocBuilder<EditActivityCubit, EditActivityState>(
      builder: (context, state) {
        final activity = state.activity;
        final recurs = activity.recurs;
        return ScrollArrows.vertical(
          controller: _scrollController,
          child: ListView(
            controller: _scrollController,
            padding: EdgeInsets.only(
              bottom: layout.templates.m1.bottom,
            ),
            children: <Widget>[
              Column(
                children: [
                  CollapsableWidget(
                    collapsed: activity.fullDay,
                    child:
                        BlocBuilder<ActivityWizardCubit, ActivityWizardState>(
                      buildWhen: (prev, current) =>
                          current.saveErrors.isNotEmpty,
                      builder: (context, wizState) => Column(
                        children: [
                          TimeIntervallPicker(
                            state.timeInterval,
                            startTimeError: wizState.saveErrors
                                .contains(SaveError.noStartTime),
                          ).pad(m1WithZeroBottom),
                          const Divider().pad(dividerPadding),
                        ],
                      ),
                    ),
                  ),
                  RecurrenceWidget(state).pad(m1WithZeroBottom),
                ],
              ),
              if (recurs.weekly || recurs.monthly)
                BlocBuilder<ActivityWizardCubit, ActivityWizardState>(
                    buildWhen: (prev, current) => current.saveErrors.isNotEmpty,
                    builder: (context, wizState) {
                      final recurringDataError = wizState.saveErrors
                          .contains(SaveError.noRecurringDays);
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          if (recurs.weekly)
                            Weekly(errorState: recurringDataError)
                          else if (recurs.monthly)
                            errorBordered(
                              const MonthDays(),
                              errorState: recurringDataError,
                            ).pad(m1ItemPadding),
                          const Divider().pad(dividerPadding),
                          const EndDateWidget().pad(m1WithZeroBottom),
                        ],
                      );
                    }),
            ],
          ),
        );
      },
    );
  }
}

class Weekly extends StatelessWidget with EditActivityTab {
  final bool errorState;
  Weekly({
    Key? key,
    required this.errorState,
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
            const WeekDays(),
            errorState: errorState,
          ).pad(m1ItemPadding),
          const EveryOtherWeekSwitch().pad(m1ItemPadding),
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
          Translator.of(context).translate.everyOtherWeek,
        ),
      ),
    );
  }
}
