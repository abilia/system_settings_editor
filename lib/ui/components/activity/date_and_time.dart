import 'package:flutter/material.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/i18n/app_localizations.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/ui/colors.dart';
import 'package:seagull/ui/components/all.dart';
import 'package:seagull/ui/components/form/all.dart';
import 'package:seagull/ui/theme.dart';
import 'package:seagull/utils/all.dart';
import 'package:intl/intl.dart';

class DateAndTimeWidget extends StatelessWidget {
  final EditActivityState editActivityState;

  const DateAndTimeWidget(this.editActivityState, {Key key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final translator = Translator.of(context).translate;
    final activity = editActivityState.activity;

    return BlocBuilder<MemoplannerSettingBloc, MemoplannerSettingsState>(
        builder: (context, memoSettingsState) {
      final errors = BlocProvider.of<EditActivityBloc>(context).canSave;
      return SizedBox(
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SubHeading(translator.date),
            DatePicker(
              activity.startTime,
              onChange: (newDate) =>
                  BlocProvider.of<EditActivityBloc>(context).add(
                ChangeDate(newDate),
              ),
              disabled: !memoSettingsState.activityDateEditable,
            ),
            const SizedBox(height: 24.0),
            CollapsableWidget(
              collapsed: activity.fullDay,
              padding: const EdgeInsets.only(bottom: 12.0),
              child: TimeIntervallPicker(
                editActivityState.timeInterval,
                startTimeError: editActivityState.failedSave &&
                    (errors.contains(SaveError.NO_START_TIME) ||
                        errors.contains(SaveError.START_TIME_BEFORE_NOW)),
              ),
            ),
            SwitchField(
              key: TestKey.fullDaySwitch,
              leading: Icon(
                AbiliaIcons.restore,
                size: smallIconSize,
              ),
              text: Text(translator.fullDay),
              value: activity.fullDay,
              onChanged: (v) => BlocProvider.of<EditActivityBloc>(context)
                  .add(ReplaceActivity(activity.copyWith(fullDay: v))),
            ),
          ],
        ),
      );
    });
  }
}

class ReminderSwitch extends StatelessWidget {
  const ReminderSwitch({
    Key key,
    @required this.activity,
  }) : super(key: key);

  final Activity activity;

  @override
  Widget build(BuildContext context) {
    return SwitchField(
      leading: Icon(
        AbiliaIcons.handi_reminder,
        size: smallIconSize,
      ),
      text: Text(Translator.of(context).translate.reminders),
      value: activity.reminders.isNotEmpty,
      onChanged: (switchOn) {
        final reminders = switchOn ? [15.minutes().inMilliseconds] : <int>[];
        BlocProvider.of<EditActivityBloc>(context)
            .add(ReplaceActivity(activity.copyWith(reminderBefore: reminders)));
      },
    );
  }
}

class DatePicker extends StatelessWidget {
  final DateTime date;
  final bool disabled;
  final Function(DateTime) onChange;
  const DatePicker(
    this.date, {
    @required this.onChange,
    this.disabled = false,
  });

  @override
  Widget build(BuildContext context) {
    final timeFormat =
        DateFormat.yMMMMd(Localizations.localeOf(context).toLanguageTag());
    final translator = Translator.of(context).translate;
    final dayColor = weekDayColor[date.weekday];
    final color = dayColor == AbiliaColors.white ? dayColor[120] : dayColor;

    return BlocBuilder<ClockBloc, DateTime>(
      builder: (context, time) => PickField(
        disabled: disabled,
        key: TestKey.datePicker,
        onTap: () async {
          final newDate = await showDatePicker(
              context: context,
              initialDate: date,
              firstDate: DateTime(date.year - 20),
              lastDate: DateTime(date.year + 20),
              builder: (context, child) => Theme(
                  data: abiliaTheme.copyWith(
                    colorScheme: abiliaTheme.colorScheme.copyWith(
                      primary: color,
                      surface: color,
                    ),
                  ),
                  child: child));
          if (newDate != null) {
            onChange(newDate);
          }
        },
        leading: Icon(
          AbiliaIcons.calendar,
          size: smallIconSize,
        ),
        text: Text(
          (time.isAtSameDay(date) ? '(${translator.today}) ' : '') +
              '${timeFormat.format(date)}',
        ),
      ),
    );
  }
}

class TimeIntervallPicker extends StatelessWidget {
  final TimeInterval timeInterval;
  final bool startTimeError;
  const TimeIntervallPicker(this.timeInterval,
      {this.startTimeError = false, Key key})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    final translator = Translator.of(context).translate;
    return BlocBuilder<MemoplannerSettingBloc, MemoplannerSettingsState>(
      builder: (context, memoSettingsState) => Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: <Widget>[
          Expanded(
            flex: 148,
            child: TimePicker(
              translator.startTime,
              timeInterval.startTime,
              key: TestKey.startTimePicker,
              errorState: startTimeError,
              onTap: () async {
                final newStartTime = await showViewDialog<TimeInputResult>(
                  context: context,
                  builder: (context) =>
                      StartTimeInputDialog(time: timeInterval.startTime),
                );
                if (newStartTime != null) {
                  BlocProvider.of<EditActivityBloc>(context)
                      .add(ChangeStartTime(newStartTime.time));
                }
              },
            ),
          ),
          if (memoSettingsState.activityEndTimeEditable)
            Expanded(
              flex: 48,
              child: Transform.translate(
                offset: Offset(0, -20),
                child: Divider(
                  thickness: 2,
                  indent: 4,
                  endIndent: 4,
                ),
              ),
            ),
          if (memoSettingsState.activityEndTimeEditable)
            Expanded(
              flex: 148,
              child: TimePicker(
                translator.endTime,
                timeInterval.endTime,
                key: TestKey.endTimePicker,
                onTap: () async {
                  final newEndTime = await showViewDialog<TimeInputResult>(
                    context: context,
                    builder: (context) => EndTimeInputDialog(
                      timeInterval: timeInterval,
                    ),
                  );
                  if (newEndTime != null) {
                    BlocProvider.of<EditActivityBloc>(context)
                        .add(ChangeEndTime(newEndTime.time));
                  }
                },
              ),
            ),
        ],
      ),
    );
  }
}

class TimePicker extends StatelessWidget {
  final String text;
  final TimeOfDay time;
  final GestureTapCallback onTap;
  final double heigth = 56;
  final bool errorState;
  const TimePicker(
    this.text,
    this.time, {
    Key key,
    @required this.onTap,
    this.errorState = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final timeSet = time != null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        SubHeading(text),
        PickField(
          semanticsLabel: text,
          onTap: onTap,
          heigth: heigth,
          errorState: errorState,
          leading: Icon(
            AbiliaIcons.clock,
            size: smallIconSize,
          ),
          text: Text(timeSet ? time.format(context) : ''),
          trailing: errorState
              ? const Icon(
                  AbiliaIcons.ir_error,
                  color: AbiliaColors.red,
                )
              : PickField.trailingArrow,
        )
      ],
    );
  }
}

class Reminders extends StatelessWidget {
  final Activity activity;

  const Reminders({Key key, @required this.activity}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final translator = Translator.of(context).translate;
    return Wrap(
      spacing: 14.0,
      runSpacing: 8.0,
      children: [
        5.minutes(),
        15.minutes(),
        30.minutes(),
        1.hours(),
        2.hours(),
        1.days(),
      ]
          .map(
            (r) => SelectableField(
              text: Text(
                r.toReminderString(translator),
                style:
                    Theme.of(context).textTheme.bodyText1.copyWith(height: 1.5),
              ),
              selected: activity.reminders.contains(r),
              onTap: () => BlocProvider.of<EditActivityBloc>(context)
                  .add(AddOrRemoveReminder(r)),
            ),
          )
          .toList(),
    );
  }
}
