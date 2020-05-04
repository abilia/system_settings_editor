import 'package:flutter/material.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/i18n/app_localizations.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/ui/components/activity/timeformat.dart';
import 'package:seagull/ui/components/all.dart';
import 'package:seagull/ui/theme.dart';
import 'package:seagull/utils/all.dart';
import 'package:intl/intl.dart';

class DateAndTimeWidget extends StatelessWidget {
  final Activity activity;
  final DateTime day;

  const DateAndTimeWidget(this.activity, {@required this.day, Key key})
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
          SizedBox(height: 12),
          CollapsableWidget(
            collapsed: activity.fullDay,
            padding: const EdgeInsets.only(bottom: 12.0),
            child: TimeIntervallPicker(activity),
          ),
          SwitchField(
            key: TestKey.fullDaySwitch,
            leading: Icon(AbiliaIcons.restore),
            label: Text(translator.fullDay),
            value: activity.fullDay,
            onChanged: (v) => BlocProvider.of<EditActivityBloc>(context)
                .add(ReplaceActivity(activity.copyWith(fullDay: v))),
          ),
          CollapsableWidget(
            collapsed: activity.fullDay,
            padding: const EdgeInsets.only(top: 8.0),
            child: ReminderSwitch(activity: activity),
          ),
          CollapsableWidget(
            padding: const EdgeInsets.only(top: 8.0),
            collapsed: activity.fullDay || activity.reminderBefore.isEmpty,
            child: Reminders(activity: activity),
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
      label: Text(Translator.of(context).translate.reminder),
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
    final timeFormat = DateFormat.yMMMMd(Locale.cachedLocale.languageCode);
    final translator = Translator.of(context).translate;

    return PickField(
      key: TestKey.datePicker,
      onTap: () async {
        final newDate = await showDatePicker(
            context: context,
            initialDate: date,
            firstDate: DateTime(date.year - 20),
            lastDate: DateTime(date.year + 20),
            builder: (BuildContext context, Widget child) => child);
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
  final Activity activity;
  const TimeIntervallPicker(this.activity, {Key key}) : super(key: key);
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
            activity.startTime,
            key: TestKey.startTimePicker,
            onTap: () async {
              final newStartTime = await showViewDialog<TimeOfDay>(
                context: context,
                builder: (context) =>
                    StartTimeInputDialog(time: activity.startTime),
              );
              if (newStartTime != null) {
                BlocProvider.of<EditActivityBloc>(context)
                    .add(ChangeStartTime(newStartTime));
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
            activity.hasEndTime ? activity.end : null,
            key: TestKey.endTimePicker,
            onTap: () async {
              final newEndTime = await showViewDialog<TimeOfDay>(
                context: context,
                builder: (context) => EndTimeInputDialog(
                  time: activity.end,
                  startTime: activity.startTime,
                ),
              );
              if (newEndTime != null) {
                BlocProvider.of<EditActivityBloc>(context)
                    .add(ChangeEndTime(newEndTime));
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
  final DateTime time;
  final GestureTapCallback onTap;
  final double heigth = 56;
  const TimePicker(this.text, this.time, {Key key, @required this.onTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final timeFormat = hourAndMinuteFormat(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        SubHeading(text),
        if (time != null)
          PickField(
            onTap: onTap,
            heigth: heigth,
            leading: Icon(AbiliaIcons.clock),
            label: Text(timeFormat(time)),
          )
        else
          InkWell(
            onTap: onTap,
            borderRadius: borderRadius,
            child: LinedBorder(
              padding: EdgeInsets.zero,
              child: Container(
                height: heigth,
                width: double.infinity,
                child: Icon(
                  AbiliaIcons.plus,
                ),
              ),
            ),
          ),
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
                style: Theme.of(context).textTheme.body2,
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
