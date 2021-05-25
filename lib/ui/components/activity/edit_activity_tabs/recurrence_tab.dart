import 'package:flutter/widgets.dart';

import 'package:seagull/bloc/all.dart';
import 'package:seagull/ui/all.dart';

class RecurrenceTab extends StatefulWidget {
  const RecurrenceTab({Key key}) : super(key: key);

  @override
  _RecurrenceTabState createState() => _RecurrenceTabState();
}

class _RecurrenceTabState extends State<RecurrenceTab> with EditActivityTab {
  ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  Widget build(BuildContext context) {
    return VerticalScrollArrows(
      controller: _scrollController,
      child: BlocBuilder<EditActivityBloc, EditActivityState>(
        builder: (context, state) {
          final recurringDataError =
              state.saveErrors.contains(SaveError.NO_RECURRING_DAYS);
          final activity = state.activity;
          final recurs = activity.recurs;
          return ListView(
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
                        TimeIntervallPicker(
                          state.timeInterval,
                          startTimeError: state.saveErrors
                              .contains(SaveError.NO_START_TIME),
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
                Column(
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
                            bottom: EditActivityTab.ordinaryPadding.bottom -
                                EditActivityTab.errorBorderPadding.bottom,
                          ),
                          child: errorBordered(
                            MonthDays(activity),
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
                ),
            ],
          );
        },
      ),
    );
  }
}

class Weekly extends StatelessWidget with EditActivityTab {
  final bool errorState;
  Weekly({
    Key key,
    @required this.errorState,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => RecurringWeekBloc(context.read<EditActivityBloc>()),
      child: BlocBuilder<RecurringWeekBloc, RecurringWeekState>(
        builder: (context, state) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: EdgeInsets.only(
                    left: EditActivityTab.ordinaryPadding.left -
                        EditActivityTab.errorBorderPadding.left),
                child: errorBordered(
                  WeekDays(state.weekdays),
                  errorState: errorState,
                ),
              ),
              Padding(
                padding: EditActivityTab.errorBorderPaddingRight,
                child: Separated(
                  child: Padding(
                    padding: EditActivityTab.ordinaryPadding.subtract(
                      EdgeInsets.only(
                          top: EditActivityTab.errorBorderPadding.top),
                    ),
                    child: SwitchField(
                      leading: Icon(
                        AbiliaIcons.this_week,
                        size: smallIconSize,
                      ),
                      value: state.everyOtherWeek,
                      onChanged: (v) => context
                          .read<RecurringWeekBloc>()
                          .add(ChangeEveryOtherWeek(v)),
                      child: Text(
                        Translator.of(context).translate.everyOtherWeek,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
