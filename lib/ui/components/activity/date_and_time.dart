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
  final Activity activity;
  final DateTime day;
  final TimeInterval timeInterval;

  const DateAndTimeWidget(this.activity, this.timeInterval,
      {@required this.day, Key key})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    final translator = Translator.of(context).translate;

    return SizedBox(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SubHeading(translator.date),
          DatePicker(
            activity.startTime,
          ),
          const SizedBox(height: 24.0),
          CollapsableWidget(
            collapsed: activity.fullDay,
            padding: const EdgeInsets.only(bottom: 12.0),
            child: TimeIntervallPicker(timeInterval),
          ),
          SwitchField(
            key: TestKey.fullDaySwitch,
            leading: Icon(AbiliaIcons.restore),
            label: Text(translator.fullDay),
            value: activity.fullDay,
            onChanged: (v) => BlocProvider.of<EditActivityBloc>(context)
                .add(ReplaceActivity(activity.copyWith(fullDay: v))),
          ),
        ],
      ),
    );
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
      leading: Icon(AbiliaIcons.handi_reminder),
      label: Text(Translator.of(context).translate.reminders),
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
  const DatePicker(this.date);

  @override
  Widget build(BuildContext context) {
    final timeFormat =
        DateFormat.yMMMMd(Localizations.localeOf(context).toLanguageTag());
    final translator = Translator.of(context).translate;
    final dayColor = weekDayColor[date.weekday];
    final color = dayColor == AbiliaColors.white ? dayColor[120] : dayColor;

    return PickField(
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
          BlocProvider.of<EditActivityBloc>(context).add(ChangeDate(newDate));
        }
      },
      leading: Icon(AbiliaIcons.calendar),
      label: BlocBuilder<ClockBloc, DateTime>(
        builder: (context, time) => Text(
          (time.isAtSameDay(date) ? '(${translator.today}) ' : '') +
              '${timeFormat.format(date)}',
        ),
      ),
    );
  }
}

class TimeIntervallPicker extends StatelessWidget {
  final TimeInterval timeInterval;
  const TimeIntervallPicker(this.timeInterval, {Key key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final translator = Translator.of(context).translate;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: <Widget>[
        Expanded(
          flex: 148,
          child: TimePicker(
            translator.startTime,
            timeInterval.startTime,
            key: TestKey.startTimePicker,
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
    );
  }
}

class TimePicker extends StatelessWidget {
  final String text;
  final TimeOfDay time;
  final GestureTapCallback onTap;
  final double heigth = 56;
  const TimePicker(this.text, this.time, {Key key, @required this.onTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        SubHeading(text),
        PickField(
          onTap: onTap,
          heigth: heigth,
          leading: Icon(AbiliaIcons.clock),
          label: Text(time != null ? time.format(context) : ''),
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
              label: Text(
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
