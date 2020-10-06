import 'package:flutter/widgets.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/i18n/all.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/ui/colors.dart';
import 'package:seagull/ui/components/all.dart';
import 'package:seagull/ui/theme.dart';

const _rightPadding = EdgeInsets.only(right: 12.0),
    _ordinaryPadding = EdgeInsets.fromLTRB(12.0, 24.0, 4.0, 16.0),
    _errorBoarderPadding = EdgeInsets.all(4.0),
    _errorBoarderPaddingRight = EdgeInsets.only(right: 5.0),
    _bottomPadding = EdgeInsets.only(bottom: 56.0);
mixin EditActivityTab {
  Widget errorBordered(Widget child, {@required bool errorState}) {
    final decoration = errorState ? errorBoxDecoration : const BoxDecoration();
    return Container(
      decoration: decoration,
      child: ClipRRect(
        borderRadius: borderRadius,
        child: Padding(
          padding: _errorBoarderPadding
              .subtract(decoration.border?.dimensions ?? EdgeInsets.zero),
          child: child,
        ),
      ),
    );
  }

  Widget separatedAndPadded(Widget child) => separated(padded(child));

  Widget separated(Widget child) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AbiliaColors.white120),
        ),
      ),
      child: child,
    );
  }

  Widget padded(Widget child) =>
      Padding(padding: _ordinaryPadding, child: child);
}

class MainTab extends StatelessWidget with EditActivityTab {
  const MainTab({
    Key key,
    @required this.editActivityState,
    @required this.day,
  }) : super(key: key);

  final EditActivityState editActivityState;
  final DateTime day;

  @override
  Widget build(BuildContext context) {
    final activity = editActivityState.activity;
    return BlocBuilder<MemoplannerSettingBloc, MemoplannerSettingsState>(
      builder: (context, memoSettingsState) => ListView(
        padding: _rightPadding.add(_bottomPadding),
        children: <Widget>[
          separatedAndPadded(ActivityNameAndPictureWidget(editActivityState)),
          separatedAndPadded(DateAndTimeWidget(editActivityState)),
          CollapsableWidget(
            child: separatedAndPadded(CategoryWidget(activity)),
            collapsed:
                activity.fullDay || !memoSettingsState.activityTypeEditable,
          ),
          separatedAndPadded(CheckableAndDeleteAfterWidget(activity)),
          padded(AvailibleForWidget(activity)),
        ],
      ),
    );
  }
}

class AlarmAndReminderTab extends StatelessWidget with EditActivityTab {
  const AlarmAndReminderTab({
    Key key,
    @required this.activity,
  }) : super(key: key);

  final Activity activity;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: _rightPadding,
      child: Column(
        children: <Widget>[
          separatedAndPadded(
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                SubHeading(Translator.of(context).translate.reminders),
                ReminderSwitch(activity: activity),
                CollapsableWidget(
                  padding: const EdgeInsets.only(top: 8.0),
                  collapsed:
                      activity.fullDay || activity.reminderBefore.isEmpty,
                  child: Reminders(activity: activity),
                ),
              ],
            ),
          ),
          padded(
            AlarmWidget(activity),
          ),
        ],
      ),
    );
  }
}

class RecurrenceTab extends StatelessWidget with EditActivityTab {
  const RecurrenceTab({
    Key key,
    @required this.state,
  }) : super(key: key);

  final EditActivityState state;

  @override
  Widget build(BuildContext context) {
    final recurringDataError =
        state.saveErrors.contains(SaveError.NO_RECURING_DAYS);
    final activity = state.activity;
    final recurs = activity.recurs;
    return ListView(
      padding:
          _rightPadding.add(_bottomPadding).subtract(_errorBoarderPaddingRight),
      children: <Widget>[
        Padding(
          padding: _errorBoarderPaddingRight,
          child: Column(
            children: [
              CollapsableWidget(
                collapsed: activity.fullDay,
                child: separatedAndPadded(
                  TimeIntervallPicker(
                    state.timeInterval,
                    startTimeError:
                        state.saveErrors.contains(SaveError.NO_START_TIME),
                  ),
                ),
              ),
              Padding(
                padding: _ordinaryPadding
                    .subtract(EdgeInsets.only(bottom: _ordinaryPadding.bottom))
                    .add(EdgeInsets.only(bottom: _errorBoarderPadding.bottom)),
                child: RecurrenceWidget(activity),
              ),
            ],
          ),
        ),
        if (recurs.weekly || recurs.monthly)
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (recurs.weekly)
                ..._weekly(activity, recurringDataError, context)
              else if (recurs.monthly)
                separated(
                  Padding(
                    padding: EdgeInsets.only(
                      left: _ordinaryPadding.left - _errorBoarderPadding.left,
                      bottom:
                          _ordinaryPadding.bottom - _errorBoarderPadding.bottom,
                    ),
                    child: errorBordered(
                      MonthDays(activity),
                      errorState: recurringDataError,
                    ),
                  ),
                ),
              Padding(
                padding: _errorBoarderPaddingRight,
                child: padded(
                  EndDateWidget(state),
                ),
              ),
            ],
          ),
      ],
    );
  }

  List<Widget> _weekly(
    Activity activity,
    bool noRecuringDataError,
    BuildContext context,
  ) {
    return [
      Padding(
        padding: EdgeInsets.only(
            left: _ordinaryPadding.left - _errorBoarderPadding.left),
        child: errorBordered(
          WeekDays(activity),
          errorState: noRecuringDataError,
        ),
      ),
      Padding(
        padding: _errorBoarderPaddingRight,
        child: separated(
          Padding(
            padding: _ordinaryPadding
                .subtract(EdgeInsets.only(top: _errorBoarderPadding.top)),
            child: SwitchField(
              key: TestKey.noEndDate,
              leading: Icon(
                AbiliaIcons.thisWeek,
                size: smallIconSize,
              ),
              text: Text(
                Translator.of(context).translate.everyOtherWeek,
              ),
              value: false,
            ),
          ),
        ),
      ),
    ];
  }
}
