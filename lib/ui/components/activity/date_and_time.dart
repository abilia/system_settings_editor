import 'package:flutter/material.dart';
import 'package:seagull/i18n/app_localizations.dart';
import 'package:seagull/ui/components/all.dart';
import 'package:seagull/ui/theme.dart';
import 'package:seagull/utils/all.dart';
import 'package:intl/intl.dart';

class DateAndTimeWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final translator = Translator.of(context).translate;

    return SizedBox(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SubHeading(translator.date),
          DatePicker(),
          SizedBox(height: 12),
          TimeIntervallPicker(),
          SizedBox(height: 12),
          SwitchField(
            leading: Icon(AbiliaIcons.restore),
            label: Text(translator.fullDay),
            startValue: false,
            onTap: () {},
          ),
          SizedBox(height: 12),
          SwitchField(
            leading: Icon(AbiliaIcons.handi_reminder),
            label: Text(translator.reminder),
            startValue: false,
            onTap: () {},
          )
        ],
      ),
    );
  }
}

class DatePicker extends StatefulWidget {
  @override
  _DatePickerState createState() => _DatePickerState(DateTime.now());
}

class _DatePickerState extends State<DatePicker> {
  DateTime pickedDate;
  final DateTime now;

  _DatePickerState(this.now) : pickedDate = now;
  @override
  Widget build(BuildContext context) {
    final timeFormat = DateFormat.yMMMMd(Locale.cachedLocale.languageCode);
    final translator = Translator.of(context).translate;

    return PickField(
      onTap: () async {
        final newDate = await selectedDate(context);
        if (newDate != null && !pickedDate.isAtSameDay(newDate)) {
          setState(() {
            pickedDate = newDate;
          });
        }
      },
      leading: Icon(AbiliaIcons.calendar),
      label: Text(
          (pickedDate.isAtSameDay(now) ? '(${translator.today}) ' : '') +
              '${timeFormat.format(pickedDate)}'),
    );
  }

  Future<DateTime> selectedDate(BuildContext context) => showDatePicker(
        context: context,
        initialDate: pickedDate,
        firstDate: DateTime(2018),
        lastDate: DateTime(2030),
        builder: (BuildContext context, Widget child) {
          return Theme(
            data: ThemeData.dark(),
            child: child,
          );
        },
      );
}

class TimeIntervallPicker extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final time = DateTime.now();
    final translator = Translator.of(context).translate;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: <Widget>[
        Expanded(
          flex: 148,
          child: TimePicker(translator.startTime, time),
        ),
        Expanded(
          flex: 51,
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
          child: TimePicker(translator.endTime, null),
        ),
      ],
    );
  }
}

class TimePicker extends StatefulWidget {
  final String text;
  final DateTime time;

  const TimePicker(this.text, this.time, {Key key}) : super(key: key);
  @override
  _TimePickerState createState() => _TimePickerState(time?.nextHalfHour());
}

class _TimePickerState extends State<TimePicker> {
  DateTime pickedTime;
  final double heigth = 56;
  final timeFormat = DateFormat('jm', Locale.cachedLocale.languageCode);

  _TimePickerState(this.pickedTime);
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        SubHeading(widget.text),
        if (pickedTime != null)
          PickField(
            onTap: () {},
            heigth: heigth,
            leading: Icon(AbiliaIcons.clock),
            label: Text(timeFormat.format(pickedTime)),
          )
        else
          InkWell(
            onTap: () {},
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
