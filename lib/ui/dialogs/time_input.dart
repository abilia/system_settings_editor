import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
  DayPeriod period;

  _TimeInputDialogState({@required this.twelveHourClock});

  bool get hasStartTime => widget.timeInput?.startTime != null;
  bool get hasEndTime => widget.timeInput?.endTime != null;
  TimeOfDay get startTime => widget.timeInput?.startTime;
  TimeOfDay get endTime => widget.timeInput.endTime;
  final String emptyPattern = '--:--';
  FocusNode startTimeFocus;
  FocusNode endTimeFocus;
  ValueChanged<String> onStartTimeChanged;

  @override
  void initState() {
    period = hasStartTime ? widget.timeInput.startTime.period : DayPeriod.pm;
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
          hour: int.tryParse(startTimeController.text.substring(0, 2)),
          minute: int.tryParse(startTimeController.text.substring(2, 4)))
      : null;
  TimeOfDay get newEndTime => validEndTime
      ? TimeOfDay(
          hour: int.tryParse(startTimeController.text.substring(0, 2)),
          minute: int.tryParse(startTimeController.text.substring(2, 4)))
      : null;
  TimeInput get timeInput => TimeInput(newStartTime, newEndTime);

  void save() => Navigator.of(context).maybePop(timeInput);

  int in24HourClock(int hour) {
    if (widget.is24HoursFormat) return hour;
    final twelveOClock = hour == 12,
        pm = period == DayPeriod.pm,
        am = period == DayPeriod.am;
    if (!twelveOClock && pm) return hour + 12;
    if (twelveOClock && am) return hour - 12;
    return hour;
  }

  TextStyle get textStyle => baseTextStyle.copyWith(
        fontWeight: regular,
        fontSize: 34.0,
      );

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ViewDialog(
      heading: Text(widget.heading, style: theme.textTheme.headline6),
      onOk: save,
      deleteButton: widget.deleteButton,
      child: Theme(
        data: theme.copyWith(
            textSelectionColor: AbiliaColors.white,
            textTheme: theme.textTheme.copyWith(subtitle1: textStyle)),
        child: Padding(
          padding: twelveHourClock
              ? const EdgeInsets.only(top: 45.0, left: 16.0)
              : const EdgeInsets.only(top: 66.0, left: 4.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _TimeInputStack(
                timeInput: '',
                editingController: startTimeController,
                editFocus: startTimeFocus,
                onTimeChanged: onStartTimeChanged,
              ),
              _TimeInputStack(
                timeInput: '',
                editingController: endTimeController,
                editFocus: endTimeFocus,
              ),
            ],
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

  _TimeInputStack({
    @required this.timeInput,
    @required this.editingController,
    @required this.editFocus,
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
  String formattedTimeInput;
  TextEditingController displayController;

  TextEditingController get editController => widget.editingController;
  FocusNode get editFocus => widget.editFocus;

  @override
  void initState() {
    super.initState();
    displayController = TextEditingController();
    editFocus.addListener(() {
      if (hasFocus != editFocus.hasFocus) {
        if (!editFocus.hasFocus && editController.text.length == 4) {
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
      width: 130,
      height: 64,
      child: Stack(
        children: [
          TextField(
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
              LengthLimitingTextInputFormatter(4),
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

class HourInputFormatter extends TextInputFormatter {
  final int maxValue;

  HourInputFormatter({@required this.maxValue});
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) return newValue;
    final parsed = int.tryParse(newValue.text);
    if (parsed == null || parsed > maxValue) return oldValue;
    return newValue;
  }
}

class MinuteInputFormatter extends TextInputFormatter {
  final int highestPossibleTenDigit = 5;
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) return newValue;
    final parsed = int.tryParse(newValue.text);
    if (parsed == null) return oldValue;
    if (parsed > highestPossibleTenDigit) {
      return newValue.copyWith(
          text: pad0(newValue.text),
          selection:
              newValue.selection.copyWith(baseOffset: 2, extentOffset: 2));
    }
    return newValue;
  }
}

class NoZeroInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) =>
      int.tryParse(newValue.text) == 0 ? oldValue : newValue;
}

class TimeInput {
  final TimeOfDay startTime;
  final TimeOfDay endTime;

  TimeInput(this.startTime, this.endTime);
}
