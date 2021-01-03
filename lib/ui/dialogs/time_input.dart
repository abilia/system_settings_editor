import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:seagull/bloc/all.dart';

import 'package:seagull/ui/all.dart';

class TimeInputDialog extends StatefulWidget {
  final TimeInput timeInput;
  final Widget deleteButton;
  final String heading;
  final bool is24HoursFormat;

  const TimeInputDialog({
    Key key,
    @required this.timeInput,
    @required this.heading,
    @required this.is24HoursFormat,
    this.deleteButton,
  }) : super(key: key);

  @override
  _TimeInputDialogState createState() =>
      _TimeInputDialogState(twelveHourClock: !is24HoursFormat);
}

String pad0(String s) => s.padLeft(2, '0');

class _TimeInputDialogState extends State<TimeInputDialog> {
  final bool twelveHourClock;
  TextEditingController startTimeController;
  TextEditingController endTimeController;
  DayPeriod startTimePeriod;
  DayPeriod endTimePeriod;

  _TimeInputDialogState({@required this.twelveHourClock});

  bool get hasStartTime => widget.timeInput?.startTime != null;
  bool get hasEndTime => widget.timeInput?.endTime != null;
  TimeOfDay get startTime => widget.timeInput?.startTime;
  TimeOfDay get endTime => widget.timeInput.endTime;
  FocusNode startTimeFocus;
  FocusNode endTimeFocus;
  ValueChanged<String> onStartTimeChanged;

  @override
  void initState() {
    startTimePeriod =
        hasStartTime ? widget.timeInput.startTime.period : DayPeriod.pm;
    endTimePeriod = hasEndTime ? widget.timeInput.endTime.period : DayPeriod.pm;
    startTimeFocus = FocusNode();
    endTimeFocus = FocusNode();
    startTimeFocus.requestFocus();
    startTimeController = TextEditingController();
    endTimeController = TextEditingController();
    onStartTimeChanged = (value) {
      if (value.length == 4) {
        endTimeFocus.requestFocus();
      }
    };
    super.initState();
  }

  bool get validStartTime => startTimeController.text.length == 4;
  bool get validEndTime => endTimeController.text.length == 4;
  bool get saveable => validStartTime;
  TimeOfDay get newStartTime => validStartTime
      ? TimeOfDay(
          hour: in24HourClock(
              int.tryParse(startTimeController.text.substring(0, 2)),
              startTimePeriod),
          minute: int.tryParse(startTimeController.text.substring(2, 4)))
      : null;
  TimeOfDay get newEndTime => validEndTime
      ? TimeOfDay(
          hour: in24HourClock(
              int.tryParse(endTimeController.text.substring(0, 2)),
              endTimePeriod),
          minute: int.tryParse(endTimeController.text.substring(2, 4)))
      : null;
  TimeInput get newTimeInput => TimeInput(newStartTime, newEndTime);

  void save() => Navigator.of(context).maybePop(newTimeInput);

  int in24HourClock(int hour, DayPeriod period) {
    if (widget.is24HoursFormat) return hour;
    final twelveOClock = hour == 12,
        pm = period == DayPeriod.pm,
        am = period == DayPeriod.am;
    if (!twelveOClock && pm) return hour + 12;
    if (twelveOClock && am) return hour - 12;
    return hour;
  }

  TextStyle get textStyle => baseTextStyle.copyWith(
        fontFamily: 'Roboto',
        fontWeight: regular,
        fontSize: 34.0,
      );

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final translate = Translator.of(context).translate;
    return BlocBuilder<MemoplannerSettingBloc, MemoplannerSettingsState>(
      builder: (context, memoSettingsState) => ViewDialog(
        heading: Text(widget.heading, style: theme.textTheme.headline6),
        onOk: save,
        deleteButton: widget.deleteButton,
        child: Theme(
          data: theme.copyWith(
              textSelectionColor: AbiliaColors.white,
              textTheme: theme.textTheme.copyWith(subtitle1: textStyle)),
          child: Padding(
            padding: const EdgeInsets.only(top: 56.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Text(
                        translate.startTime,
                        style: abiliaTextTheme.bodyText2,
                      ),
                    ),
                    _TimeInputStack(
                      inputKey: TestKey.startTimeInput,
                      timeInput: widget.timeInput.rawStartTime(twelveHourClock),
                      editingController: startTimeController,
                      editFocus: startTimeFocus,
                      twelveHourClock: twelveHourClock,
                      onTimeChanged: onStartTimeChanged,
                    ),
                    if (!widget.is24HoursFormat)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: AmPmSelector(
                          amRadioFieldKey: TestKey.startTimeAmRadioField,
                          pmRadioFieldKey: TestKey.startTimePmRadioField,
                          groupValue: startTimePeriod,
                          onChanged: (period) => setState(() {
                            startTimePeriod = period;
                          }),
                        ),
                      ),
                  ],
                ),
                if (memoSettingsState.activityEndTimeEditable)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: 28,
                      ),
                      SizedBox(
                        height: 64,
                        child: Center(
                            child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Text(
                            '—',
                            style: abiliaTextTheme.headline5,
                          ),
                        )),
                      )
                    ],
                  ),
                if (memoSettingsState.activityEndTimeEditable)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Text(
                          translate.endTime,
                          style: abiliaTextTheme.bodyText2,
                        ),
                      ),
                      _TimeInputStack(
                        inputKey: TestKey.endTimeInput,
                        timeInput: widget.timeInput.rawEndTime(twelveHourClock),
                        editingController: endTimeController,
                        editFocus: endTimeFocus,
                        twelveHourClock: twelveHourClock,
                      ),
                      if (!widget.is24HoursFormat)
                        Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: AmPmSelector(
                              amRadioFieldKey: TestKey.endTimeAmRadioField,
                              pmRadioFieldKey: TestKey.endTimePmRadioField,
                              groupValue: endTimePeriod,
                              onChanged: (period) => setState(() {
                                endTimePeriod = period;
                              }),
                            )),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    startTimeController.dispose();
    endTimeController.dispose();
    super.dispose();
  }
}

class _TimeInputStack extends StatefulWidget {
  final String timeInput;
  final TextEditingController editingController;
  final FocusNode editFocus;
  final ValueChanged<String> onTimeChanged;
  final bool twelveHourClock;
  final Key inputKey;

  _TimeInputStack({
    this.inputKey,
    @required this.timeInput,
    @required this.editingController,
    @required this.editFocus,
    @required this.twelveHourClock,
    this.onTimeChanged,
  });
  @override
  _TimeInputStackState createState() => _TimeInputStackState(timeInput);
}

class _TimeInputStackState extends State<_TimeInputStack> {
  _TimeInputStackState(this.timeInput);

  static final emptyPattern = '--:--';
  final displayFocus = FocusNode(
    canRequestFocus: false,
  );

  bool hasFocus = false;
  String timeInput;
  TextEditingController displayController;

  TextEditingController get editController => widget.editingController;
  FocusNode get editFocus => widget.editFocus;

  @override
  void initState() {
    super.initState();
    displayController = TextEditingController();
    editFocus.addListener(() {
      if (hasFocus != editFocus.hasFocus) {
        if (!editFocus.hasFocus &&
            (editController.text.length == 4 || editController.text.isEmpty)) {
          setState(() {
            timeInput = editController.text;
          });
        }
        setState(() {
          hasFocus = editFocus.hasFocus;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    editController.text = timeInput;
    editController.selection =
        TextSelection(baseOffset: 0, extentOffset: editController.text.length);
    displayController.text = formatTimeToDisplay(timeInput);
    return Container(
      width: 120,
      height: 64,
      child: Stack(
        children: [
          TextField(
            key: widget.inputKey,
            focusNode: editFocus,
            keyboardType: TextInputType.number,
            showCursor: false,
            controller: editController,
            onChanged: (value) {
              displayController.text = formatTimeToDisplay(value);
              if (widget.onTimeChanged != null) {
                widget.onTimeChanged(value);
              }
            },
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(4),
              TimeInputFormatter(widget.twelveHourClock),
            ],
          ),
          GestureDetector(
            onTap: () => editFocus.requestFocus(),
            child: TextField(
              readOnly: true,
              enabled: false,
              focusNode: displayFocus,
              keyboardType: TextInputType.number,
              showCursor: false,
              controller: displayController,
              textAlign: TextAlign.center,
              textAlignVertical: TextAlignVertical.center,
              decoration: InputDecoration(
                disabledBorder: OutlineInputBorder(
                  borderRadius: borderRadius,
                  borderSide: BorderSide(
                    color: hasFocus ? Colors.black : Colors.grey,
                    width: 2,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String formatTimeToDisplay(String input) {
    if (input.isEmpty) {
      return emptyPattern;
    } else if (input.length == 1) {
      return input + emptyPattern.substring(1);
    } else if (input.length == 2) {
      return input + emptyPattern.substring(2);
    } else if (input.length == 3) {
      return input.substring(0, 2) +
          emptyPattern.substring(2, 3) +
          input.substring(2) +
          emptyPattern.substring(4, 5);
    } else if (input.length == 4) {
      return input.substring(0, 2) +
          emptyPattern.substring(2, 3) +
          input.substring(2);
    } else {
      return emptyPattern;
    }
  }
}

class TimeInputFormatter extends TextInputFormatter {
  final bool twelveHourClock;

  TimeInputFormatter(this.twelveHourClock);

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final newText = newValue.text;
    return validTimeInput(newText) ? newValue : oldValue;
  }

  bool validTimeInput(String input) {
    if (input.isEmpty) {
      return true;
    }
    final intVal = int.tryParse(input);
    if (input.length == 1) {
      return twelveHourClock ? intVal <= 1 : intVal <= 2;
    }
    if (input.length == 2) {
      return twelveHourClock ? intVal >= 1 && intVal <= 12 : intVal <= 23;
    }
    if (input.length == 3) {
      return int.tryParse(input.substring(2, 3)) <= 5;
    }
    if (input.length == 4) {
      return int.tryParse(input.substring(2, 4)) <= 59;
    }
    return false;
  }
}

class TimeInput {
  final TimeOfDay startTime;
  final TimeOfDay endTime;

  TimeInput(this.startTime, this.endTime);

  String rawStartTime(bool twelveHourClock) {
    return rawTimeOfDay(startTime, twelveHourClock);
  }

  String rawEndTime(bool twelveHourClock) {
    return rawTimeOfDay(endTime, twelveHourClock);
  }

  String rawTimeOfDay(TimeOfDay tod, bool twelveHourClock) {
    return tod == null
        ? ''
        : ((twelveHourClock
                ? pad0(
                    '${tod.hourOfPeriod == 0 ? TimeOfDay.hoursPerPeriod : tod.hourOfPeriod}')
                : pad0('${tod.hour}')) +
            pad0('${tod.minute}'));
  }
}

class AmPmSelector extends StatelessWidget {
  final DayPeriod groupValue;
  final ValueChanged<DayPeriod> onChanged;
  final Key amRadioFieldKey;
  final Key pmRadioFieldKey;

  const AmPmSelector({
    Key key,
    @required this.groupValue,
    @required this.onChanged,
    this.amRadioFieldKey,
    this.pmRadioFieldKey,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Row(
        children: [
          RadioField(
            key: amRadioFieldKey,
            width: 59.0,
            heigth: 48.0,
            text: Text(
              Translator.of(context).translate.am,
              style: abiliaTextTheme.bodyText1,
              textAlign: TextAlign.center,
            ),
            value: DayPeriod.am,
            groupValue: groupValue,
            onChanged: onChanged,
          ),
          SizedBox(width: 2),
          RadioField(
            key: pmRadioFieldKey,
            width: 59.0,
            heigth: 48.0,
            text: Text(
              Translator.of(context).translate.pm,
              style: abiliaTextTheme.bodyText1,
              textAlign: TextAlign.center,
            ),
            value: DayPeriod.pm,
            groupValue: groupValue,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
