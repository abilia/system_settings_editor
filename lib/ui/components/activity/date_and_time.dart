// @dart=2.9

import 'package:intl/intl.dart';
import 'package:flutter/material.dart';

import 'package:seagull/bloc/all.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/ui/all.dart';
import 'package:seagull/utils/all.dart';

class DateAndTimeWidget extends StatelessWidget {
  final EditActivityState editActivityState;

  const DateAndTimeWidget(this.editActivityState, {Key key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final translator = Translator.of(context).translate;
    final activity = editActivityState.activity;

    return BlocBuilder<MemoplannerSettingBloc, MemoplannerSettingsState>(
        builder: (context, memoSettingsState) {
      return SizedBox(
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SubHeading(translator.date),
            DatePicker(
              editActivityState.timeInterval.startDate,
              onChange: memoSettingsState.activityDateEditable
                  ? (newDate) => BlocProvider.of<EditActivityBloc>(context).add(
                        ChangeDate(newDate),
                      )
                  : null,
            ),
            SizedBox(height: 24.0.s),
            CollapsableWidget(
              collapsed: activity.fullDay,
              padding: EdgeInsets.only(bottom: 12.0.s),
              child: TimeIntervallPicker(editActivityState.timeInterval,
                  startTimeError: editActivityState.saveErrors.any({
                    SaveError.NO_START_TIME,
                    SaveError.START_TIME_BEFORE_NOW
                  }.contains)),
            ),
            SwitchField(
              key: TestKey.fullDaySwitch,
              leading: Icon(
                AbiliaIcons.restore,
                size: smallIconSize,
              ),
              value: activity.fullDay,
              onChanged: (v) => BlocProvider.of<EditActivityBloc>(context)
                  .add(ReplaceActivity(activity.copyWith(fullDay: v))),
              child: Text(translator.fullDay),
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
      value: activity.reminders.isNotEmpty,
      onChanged: (switchOn) {
        final reminders = switchOn ? [15.minutes().inMilliseconds] : <int>[];
        BlocProvider.of<EditActivityBloc>(context)
            .add(ReplaceActivity(activity.copyWith(reminderBefore: reminders)));
      },
      child: Text(Translator.of(context).translate.reminders),
    );
  }
}

class DatePicker extends StatelessWidget {
  final DateTime date;
  final Function(DateTime) onChange;
  final DateTime notBefore;
  const DatePicker(
    this.date, {
    @required this.onChange,
    this.notBefore,
  });

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context);
    final timeFormat = DateFormat.yMMMMd(locale.toLanguageTag());
    return BlocBuilder<ClockBloc, DateTime>(
      buildWhen: (previous, current) => previous.day != current.day,
      builder: (context, time) => PickField(
        onTap: onChange == null
            ? null
            : () async {
                final newDate = await Navigator.of(context).push<DateTime>(
                  MaterialPageRoute(
                    builder: (_) => MultiBlocProvider(
                      providers: [
                        BlocProvider(
                          create: (context) => MonthCalendarBloc(
                            clockBloc: context.read<ClockBloc>(),
                            initialDay: date,
                          ),
                        ),
                        BlocProvider(
                          create: (context) => DayPickerBloc(
                            clockBloc: context.read<ClockBloc>(),
                            initialDay: date,
                          ),
                        ),
                        BlocProvider.value(
                          value: context.read<MemoplannerSettingBloc>(),
                        ),
                      ],
                      child: DatePickerPage(
                        date: date,
                        notBefore: notBefore,
                      ),
                    ),
                  ),
                );
                if (newDate != null) {
                  onChange(newDate);
                }
              },
        leading: Icon(AbiliaIcons.calendar),
        text: Text(
          (time.isAtSameDay(date)
                  ? '(${Translator.of(context).translate.today}) '
                  : '') +
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
              translator.time,
              TimeInput(
                timeInterval.startTime,
                timeInterval.sameTime ? null : timeInterval.endTime,
              ),
              errorState: startTimeError,
              onTap: () async {
                final newTimeInterval =
                    await Navigator.of(context).push<TimeInput>(
                  MaterialPageRoute(
                    builder: (_) => CopiedAuthProviders(
                      blocContext: context,
                      child: TimeInputPage(
                        timeInput: TimeInput(
                            timeInterval.startTime,
                            timeInterval.sameTime ||
                                    !memoSettingsState.activityEndTimeEditable
                                ? null
                                : timeInterval.endTime),
                        is24HoursFormat:
                            MediaQuery.of(context).alwaysUse24HourFormat,
                      ),
                    ),
                    settings: RouteSettings(name: 'TimeInputPage'),
                  ),
                );

                if (newTimeInterval != null) {
                  BlocProvider.of<EditActivityBloc>(context)
                      .add(ChangeTimeInterval(
                    startTime: newTimeInterval.startTime,
                    endTime: newTimeInterval.endTime,
                  ));
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
  final TimeInput timeInput;
  final GestureTapCallback onTap;
  final bool errorState;
  const TimePicker(
    this.text,
    this.timeInput, {
    Key key,
    @required this.onTap,
    this.errorState = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final timeFormat = hourAndMinuteFormat(context);
    final time = timeInput.startTime == null
        ? ''
        : timeFormat(DateTime(0, 0, 0, timeInput.startTime.hour,
                timeInput.startTime.minute)) +
            (timeInput.endTime == null
                ? ''
                : ' - ' +
                    timeFormat(DateTime(0, 0, 0, timeInput.endTime.hour,
                        timeInput.endTime.minute)));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        SubHeading(text),
        PickField(
          semanticsLabel: text,
          onTap: onTap,
          heigth: 56.s,
          errorState: errorState,
          leading: Icon(AbiliaIcons.clock),
          text: Text(time),
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
      spacing: 14.0.s,
      runSpacing: 8.0.s,
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
                r.toDurationString(translator),
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
