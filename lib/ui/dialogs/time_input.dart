import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:seagull/models/all.dart';
import 'package:seagull/ui/all.dart';

class TimeInputDialog extends StatefulWidget {
  final TimeInterval timeInterval;
  final Widget deleteButton;
  final String heading;
  final bool is24HoursFormat;

  const TimeInputDialog({
    Key key,
    @required this.timeInterval,
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
  TextEditingController minuteInputController;
  TextEditingController hourInputController;
  FocusNode hourFocusNode;
  FocusNode minuteFocusNode;
  DayPeriod period;

  _TimeInputDialogState({@required this.twelveHourClock});

  bool get hasStartTime => widget.timeInterval?.startTime != null;
  bool get hasEndTime => widget.timeInterval?.endTime != null;
  TimeOfDay get startTime => widget.timeInterval?.startTime;
  TimeOfDay get endTime => widget.timeInterval.endTime;

  @override
  void initState() {
    period = hasStartTime ? widget.timeInterval.startTime.period : DayPeriod.pm;

    hourFocusNode = FocusNode()..addListener(onHourFocusChanged);
    minuteFocusNode = FocusNode()..addListener(onMinFocusChanged);
    if (widget.timeInterval != null) {
      minuteFocusNode.requestFocus();
    } else {
      hourFocusNode.requestFocus();
    }
    minuteInputController = TextEditingController(text: oldMinute)
      ..addListener(minuteInputListener);
    hourInputController = TextEditingController(text: oldHour)
      ..addListener(hourInputListener);
    super.initState();
  }

  String get oldHour => widget.timeInterval != null
      ? twelveHourClock
          ? '${startTime.hourOfPeriod == 0 ? TimeOfDay.hoursPerPeriod : startTime.hourOfPeriod}'
          : pad0('${startTime.hour}')
      : null;
  String get oldMinute =>
      widget.timeInterval != null ? pad0('${startTime.minute}') : null;

  TimeOfDay get inputTime {
    if (minute == null || hour == null) return null;
    return TimeOfDay(hour: in24HourClock(hour), minute: minute);
  }

  int get hour => int.tryParse(hourInputController.text);
  int get minute => int.tryParse(minuteInputController.text);
  bool get validHour => hour != null;
  bool get validMinute => minute != null;
  bool get saveable => validHour && validMinute;

  void save() => Navigator.of(context).maybePop(TimeInputResult(inputTime));

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
        fontSize: 56.0,
        height: 82.0 / 56.0,
      );

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ViewDialog(
      heading: Text(widget.heading, style: theme.textTheme.headline6),
      onOk: saveable ? save : null,
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
            children: <Widget>[
              _InputField(
                textFieldKey: TestKey.hourTextInput,
                controller: hourInputController,
                onEditingComplete: saveable
                    ? save
                    : validHour
                        ? minuteFocusNode.requestFocus
                        : () {},
                extraFormatter: [
                  HourInputFormatter(maxValue: twelveHourClock ? 12 : 23),
                  if (twelveHourClock) NoZeroInputFormatter(),
                ],
                focusNode: hourFocusNode,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: Text(
                  ':',
                  style: textStyle,
                  textAlign: TextAlign.end,
                ),
              ),
              _InputField(
                textFieldKey: TestKey.minTextInput,
                controller: minuteInputController,
                onEditingComplete: saveable
                    ? save
                    : validMinute
                        ? hourFocusNode.requestFocus
                        : () {},
                extraFormatter: [
                  MinuteInputFormatter(),
                ],
                focusNode: minuteFocusNode,
              ),
              if (twelveHourClock)
                Padding(
                  padding: const EdgeInsets.only(left: 12.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      RadioField(
                        width: 63.0,
                        heigth: 48.0,
                        key: TestKey.amRadioField,
                        text: Text(
                          Translator.of(context).translate.am,
                          style: theme.textTheme.bodyText1,
                          textAlign: TextAlign.center,
                        ),
                        value: DayPeriod.am,
                        groupValue: period,
                        onChanged: (p) => setState(() => period = p),
                      ),
                      SizedBox(height: 6),
                      RadioField(
                        width: 63.0,
                        heigth: 48.0,
                        key: TestKey.pmRadioField,
                        text: Text(
                          Translator.of(context).translate.pm,
                          style: theme.textTheme.bodyText1,
                        ),
                        value: DayPeriod.pm,
                        groupValue: period,
                        onChanged: (p) => setState(() => period = p),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void onHourFocusChanged() {
    if (hourFocusNode.hasFocus) {
      _selectAllText(hourInputController);
    } else {
      if (hourInputController.text.isEmpty) {
        hourInputController.text = oldHour;
      } else if (widget.is24HoursFormat) {
        hourInputController.text = pad0(hourInputController.text);
      }
    }
    setState(() {});
  }

  void onMinFocusChanged() {
    if (minuteFocusNode.hasFocus) {
      _selectAllText(minuteInputController);
    } else if (minuteInputController.text.isNotEmpty) {
      minuteInputController.text = pad0(minuteInputController.text);
    }
    setState(() {});
  }

  void _selectAllText(TextEditingController controller) =>
      controller.selection =
          TextSelection(baseOffset: 0, extentOffset: controller.text.length);

  void hourInputListener() {
    final noTextSelected = hourInputController.selection.extentOffset ==
        hourInputController.selection.baseOffset;

    if (noTextSelected) {
      final text = hourInputController.text;
      if (text.length >= 2) minuteFocusNode.requestFocus();
      final parsed = int.tryParse(text);
      final highestPossibleTenDigit = twelveHourClock ? 1 : 2;
      if (parsed != null && parsed > highestPossibleTenDigit) {
        minuteFocusNode.requestFocus();
      }
    }
    setState(() {});
  }

  var _lastMinText = '';
  void minuteInputListener() {
    final lastMinDigitDeleted = minuteInputController.text.isEmpty &&
        minuteInputController.text != _lastMinText;
    if (lastMinDigitDeleted) {
      hourFocusNode.requestFocus();
    }
    _lastMinText = minuteInputController.text;
    setState(() {});
  }

  @override
  void dispose() {
    hourFocusNode.dispose();
    minuteFocusNode.dispose();
    minuteInputController.dispose();
    hourInputController.dispose();
    super.dispose();
  }
}

class _InputField extends StatelessWidget {
  const _InputField({
    Key key,
    @required this.controller,
    @required this.focusNode,
    this.autoFocus = false,
    this.extraFormatter = const [],
    this.onEditingComplete,
    this.textFieldKey,
  }) : super(key: key);

  final Key textFieldKey;
  final TextEditingController controller;
  final VoidCallback onEditingComplete;
  final FocusNode focusNode;
  final List<TextInputFormatter> extraFormatter;
  final bool autoFocus;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 82.0,
      child: TextField(
        key: textFieldKey,
        focusNode: focusNode,
        textAlign: TextAlign.center,
        textAlignVertical: TextAlignVertical.center,
        decoration: InputDecoration(
          fillColor: focusNode.hasFocus
              ? Theme.of(context).inputDecorationTheme.fillColor
              : Colors.transparent,
          contentPadding: EdgeInsets.zero,
        ),
        enableInteractiveSelection: false,
        showCursor: false,
        controller: controller,
        autofocus: autoFocus,
        onEditingComplete: onEditingComplete,
        keyboardType: TextInputType.number,
        inputFormatters: <TextInputFormatter>[
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(2),
          ...extraFormatter,
        ],
      ),
    );
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

class TimeInputResult {
  final TimeOfDay time;

  TimeInputResult(this.time);
}
