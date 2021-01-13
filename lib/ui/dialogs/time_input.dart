import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:seagull/bloc/all.dart';

import 'package:seagull/ui/all.dart';

class TimeInputDialog extends StatefulWidget {
  final TimeInput timeInput;
  final bool is24HoursFormat;

  const TimeInputDialog({
    Key key,
    @required this.timeInput,
    @required this.is24HoursFormat,
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
  FocusNode startTimeFocus;
  FocusNode endTimeFocus;
  String validatedNewStartTime;
  String valiedatedNewEndTime;

  _TimeInputDialogState({@required this.twelveHourClock});

  @override
  void initState() {
    super.initState();

    startTimePeriod = widget.timeInput.startTime?.period ?? DayPeriod.pm;
    endTimePeriod = widget.timeInput.endTime?.period ?? DayPeriod.pm;

    startTimeFocus = FocusNode()
      ..addListener(() {
        if (startTimeFocus.hasFocus) {
          startTimeController.selection = TextSelection(
              baseOffset: 0, extentOffset: startTimeController.text.length);
          final validEndTime =
              valid(endTimeController) || endTimeController.text.isEmpty;
          final validatedEndTime =
              validEndTime ? endTimeController.text : valiedatedNewEndTime;
          endTimeController.text = validatedEndTime;
          setState(() {
            valiedatedNewEndTime = validatedEndTime;
          });
        }
      })
      ..requestFocus();
    endTimeFocus = FocusNode()
      ..addListener(() {
        if (endTimeFocus.hasFocus) {
          endTimeController.selection = TextSelection(
              baseOffset: 0, extentOffset: endTimeController.text.length);
          final validStartTime =
              valid(startTimeController) || startTimeController.text.isEmpty;
          final validatedStartTime =
              validStartTime ? startTimeController.text : validatedNewStartTime;
          startTimeController.text = validatedStartTime;
          setState(() {
            validatedNewStartTime = validatedStartTime;
          });
        }
      });

    validatedNewStartTime = widget.timeInput.rawStartTime(twelveHourClock);
    valiedatedNewEndTime = widget.timeInput.rawEndTime(twelveHourClock);

    startTimeController = TextEditingController(text: validatedNewStartTime);
    endTimeController = TextEditingController(text: valiedatedNewEndTime);
  }

  static bool valid(TextEditingController controller) =>
      controller.text.length == 4;

  TimeOfDay newTime(TextEditingController controller, DayPeriod period) =>
      valid(controller)
          ? TimeOfDay(
              hour: in24HourClock(
                  int.tryParse(controller.text.substring(0, 2)), period),
              minute: int.tryParse(controller.text.substring(2, 4)))
          : null;

  TimeInput get newTimeInput => TimeInput(
        newTime(startTimeController, startTimePeriod),
        newTime(endTimeController, endTimePeriod),
      );

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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final translate = Translator.of(context).translate;
    return BlocBuilder<MemoplannerSettingBloc, MemoplannerSettingsState>(
      builder: (context, memoSettingsState) => ViewDialog(
        heading: Text(translate.setTime, style: theme.textTheme.headline6),
        onOk: save,
        child: Theme(
          data: theme.copyWith(
              textSelectionColor: AbiliaColors.white,
              textTheme: theme.textTheme
                  .copyWith(subtitle1: abiliaTextTheme.headline4)),
          child: Padding(
            padding: const EdgeInsets.only(top: 56.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _TimeInput(
                  inputKey: TestKey.startTimeInput,
                  amRadioFieldKey: TestKey.startTimeAmRadioField,
                  pmRadioFieldKey: TestKey.startTimePmRadioField,
                  heading: translate.startTime,
                  onTimeChanged: (value) {
                    if (value.length == 4) {
                      endTimeFocus.requestFocus();
                    }
                  },
                  period: startTimePeriod,
                  onDone: save,
                  onPeriodChanged: (period) => setState(() {
                    startTimePeriod = period;
                  }),
                  twelveHourClock: twelveHourClock,
                  focusNode: startTimeFocus,
                  controller: startTimeController,
                ),
                if (memoSettingsState.activityEndTimeEditable) ...[
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
                  _TimeInput(
                    inputKey: TestKey.endTimeInput,
                    amRadioFieldKey: TestKey.endTimeAmRadioField,
                    pmRadioFieldKey: TestKey.endTimePmRadioField,
                    heading: translate.endTime,
                    period: endTimePeriod,
                    onDone: save,
                    onPeriodChanged: (period) => setState(() {
                      endTimePeriod = period;
                    }),
                    twelveHourClock: twelveHourClock,
                    focusNode: endTimeFocus,
                    controller: endTimeController,
                  ),
                ]
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

class _TimeInput extends StatelessWidget {
  const _TimeInput({
    Key key,
    @required this.heading,
    @required this.controller,
    @required this.focusNode,
    @required this.twelveHourClock,
    @required this.period,
    @required this.onPeriodChanged,
    @required this.amRadioFieldKey,
    @required this.pmRadioFieldKey,
    @required this.inputKey,
    @required this.onDone,
    this.onTimeChanged,
  }) : super(key: key);

  final TextEditingController controller;
  final FocusNode focusNode;
  final bool twelveHourClock;
  final DayPeriod period;
  final ValueChanged<DayPeriod> onPeriodChanged;
  final ValueChanged<String> onTimeChanged;
  final String heading;
  final Key amRadioFieldKey, pmRadioFieldKey, inputKey;
  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    return Tts(
      onLongPress: () => ttsText(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(heading),
          const SizedBox(height: 8.0),
          _TimeInputStack(
            inputKey: inputKey,
            editingController: controller,
            editFocus: focusNode,
            twelveHourClock: twelveHourClock,
            onTimeChanged: onTimeChanged,
            onDone: onDone,
          ),
          const SizedBox(height: 8.0),
          if (twelveHourClock)
            AmPmSelector(
              amRadioFieldKey: amRadioFieldKey,
              pmRadioFieldKey: pmRadioFieldKey,
              groupValue: period,
              onChanged: onPeriodChanged,
            ),
        ],
      ),
    );
  }

  String ttsText(BuildContext context) {
    if (!_TimeInputDialogState.valid(controller)) return heading;
    final clockTime = '$heading ${formatTimeToDisplay(controller.text)}';
    if (!twelveHourClock) return clockTime;
    return '$clockTime '
        '${(period == DayPeriod.am ? Translator.of(context).translate.am : Translator.of(context).translate.pm)}';
  }
}

class _TimeInputStack extends StatefulWidget {
  final TextEditingController editingController;
  final FocusNode editFocus;
  final ValueChanged<String> onTimeChanged;
  final VoidCallback onDone;
  final bool twelveHourClock;
  final Key inputKey;

  _TimeInputStack({
    this.inputKey,
    @required this.editingController,
    @required this.editFocus,
    @required this.twelveHourClock,
    @required this.onDone,
    this.onTimeChanged,
  });
  @override
  _TimeInputStackState createState() => _TimeInputStackState();
}

class _TimeInputStackState extends State<_TimeInputStack> {
  _TimeInputStackState();

  final displayFocus = FocusNode(
    canRequestFocus: false,
  );

  TextEditingController displayController;

  TextEditingController get editController => widget.editingController;
  FocusNode get editFocus => widget.editFocus;

  @override
  void initState() {
    super.initState();
    displayController = TextEditingController();
    displayController.text = formatTimeToDisplay(widget.editingController.text);
    editController.addListener(() {
      displayController.text = formatTimeToDisplay(editController.text);
    });
  }

  @override
  Widget build(BuildContext context) {
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
              if (widget.onTimeChanged != null) {
                widget.onTimeChanged(value);
              }
            },
            onSubmitted: (v) => widget.onDone(),
            textInputAction: TextInputAction.done,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              DeleteInputFormatter(),
              LeadingZeroInputFormatter(widget.twelveHourClock),
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
                    color: editFocus.hasFocus ? Colors.black : Colors.grey,
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
}

final emptyPattern = '--:--';

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

class DeleteInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    if (oldValue.text.length == 4 && newValue.text.isEmpty) {
      return TextEditingValue(
        text: oldValue.text.substring(0, 3),
        selection: TextSelection.collapsed(offset: 3),
      );
    } else {
      return newValue;
    }
  }
}

class LeadingZeroInputFormatter extends TextInputFormatter {
  final bool twelveHourClock;

  LeadingZeroInputFormatter(this.twelveHourClock);

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    final intVal = int.tryParse(newValue.text);
    if (newValue.text.length == 1 && intVal > (twelveHourClock ? 1 : 2)) {
      return TextEditingValue(
        text: pad0(newValue.text),
        selection: TextSelection.collapsed(offset: 2),
      );
    } else {
      return newValue;
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
          _buildPeriodRadioField(
            key: amRadioFieldKey,
            text: Translator.of(context).translate.am,
            period: DayPeriod.am,
          ),
          const SizedBox(width: 2),
          _buildPeriodRadioField(
            key: pmRadioFieldKey,
            text: Translator.of(context).translate.pm,
            period: DayPeriod.pm,
          ),
        ],
      ),
    );
  }

  RadioField<DayPeriod> _buildPeriodRadioField({
    Key key,
    String text,
    DayPeriod period,
  }) =>
      RadioField(
        key: key,
        width: 59.0,
        heigth: 48.0,
        text: Text(text),
        value: period,
        groupValue: groupValue,
        onChanged: onChanged,
      );
}
