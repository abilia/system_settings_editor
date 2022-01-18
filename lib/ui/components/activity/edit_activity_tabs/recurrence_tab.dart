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
            padding: EditActivityTab.rightPadding
                .add(EditActivityTab.bottomPadding)
                .subtract(EditActivityTab.errorBorderPaddingRight),
            children: <Widget>[
              Padding(
                padding: EditActivityTab.errorBorderPaddingRight,
                child: Column(
                  children: [
                    CollapsableWidget(
                      collapsed: activity.fullDay,
                      child: separatedAndPadded(
                        BlocBuilder<ActivityWizardCubit, ActivityWizardState>(
                          buildWhen: (prev, current) =>
                              current.saveErrors.isNotEmpty,
                          builder: (context, wizState) => TimeIntervallPicker(
                            state.timeInterval,
                            startTimeError: wizState.saveErrors
                                .contains(SaveError.noStartTime),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: EditActivityTab.ordinaryPadding
                          .subtract(EdgeInsets.only(
                              bottom: EditActivityTab.ordinaryPadding.bottom))
                          .add(EdgeInsets.only(
                              bottom:
                                  EditActivityTab.errorBorderPadding.bottom)),
                      child: RecurrenceWidget(state),
                    ),
                  ],
                ),
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
                            Separated(
                              child: Padding(
                                padding: EdgeInsets.only(
                                  left: EditActivityTab.ordinaryPadding.left -
                                      EditActivityTab.errorBorderPadding.left,
                                  bottom: EditActivityTab
                                          .ordinaryPadding.bottom -
                                      EditActivityTab.errorBorderPadding.bottom,
                                ),
                                child: errorBordered(
                                  const MonthDays(),
                                  errorState: recurringDataError,
                                ),
                              ),
                            ),
                          Padding(
                            padding: EditActivityTab.errorBorderPaddingRight,
                            child: padded(
                              const EndDateWidget(),
                            ),
                          ),
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
          Padding(
            padding: EdgeInsets.only(
                left: EditActivityTab.ordinaryPadding.left -
                    EditActivityTab.errorBorderPadding.left),
            child: errorBordered(
              const WeekDays(),
              errorState: errorState,
            ),
          ),
          Padding(
            padding: EditActivityTab.errorBorderPaddingRight,
            child: Separated(
              child: Padding(
                padding: EditActivityTab.ordinaryPadding.subtract(
                  EdgeInsets.only(top: EditActivityTab.errorBorderPadding.top),
                ),
                child: const EveryOtherWeekSwitch(),
              ),
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
          size: layout.iconSize.small,
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
