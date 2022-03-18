import 'dart:async';
import 'dart:io' show Platform;

import 'package:flutter/services.dart';

import 'package:seagull/bloc/all.dart';
import 'package:seagull/ui/all.dart';

class TimeInputPage extends StatelessWidget {
  final TimeInput timeInput;

  const TimeInputPage({
    Key? key,
    required this.timeInput,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AbiliaAppBar(
        title: Translator.of(context).translate.setTime,
        iconData: AbiliaIcons.clock,
      ),
      body: TimeInputContent(
        timeInput: timeInput,
        is24HoursFormat: MediaQuery.of(context).alwaysUse24HourFormat,
        onSave: (context, newTimInput) => onSave(context, newTimInput),
        bottomNavigationBuilder: (context, newTimeInput) => BottomNavigation(
          backNavigationWidget: const CancelButton(),
          forwardNavigationWidget: OkButton(
            onPressed: () => onSave(context, newTimeInput),
          ),
        ),
      ),
    );
  }

  Future<bool> onSave(
    BuildContext context,
    TimeInput? newTimInput,
  ) async {
    if (newTimInput != null) {
      Navigator.of(context).maybePop(newTimInput);
      return true;
    } else {
      await showViewDialog(
        context: context,
        builder: (context) => ErrorDialog(
          text: Translator.of(context).translate.missingStartTime,
        ),
      );
      return false;
    }
  }
}

class TimeInputContent extends StatefulWidget {
  final TimeInput timeInput;

  final BottomNavigationBuilder bottomNavigationBuilder;
  final SaveTimeInput onSave;
  final OnValidTimeInput? onValidTimeInput;

  final bool is24HoursFormat;

  const TimeInputContent({
    Key? key,
    required this.timeInput,
    required this.is24HoursFormat,
    required this.bottomNavigationBuilder,
    required this.onSave,
    this.onValidTimeInput,
  }) : super(key: key);

  @override
  _TimeInputContentState createState() => _TimeInputContentState();
}

String pad0(String s) => s.padLeft(2, '0');

typedef BottomNavigationBuilder = Widget Function(
    BuildContext context, TimeInput? newTimeInput);

typedef SaveTimeInput = FutureOr<bool> Function(
    BuildContext context, TimeInput? newTimeInput);

typedef OnValidTimeInput = void Function(TimeInput newTimeInput);

class _TimeInputContentState extends State<TimeInputContent>
    with WidgetsBindingObserver {
  late TextEditingController startTimeController;
  late TextEditingController endTimeController;
  late DayPeriod startTimePeriod;
  late DayPeriod endTimePeriod;
  late FocusNode startTimeFocus;
  late FocusNode endTimeFocus;
  late String validatedNewStartTime;
  late String validatedNewEndTime;

  bool _startTimeFocus = true, _paused = false;
  bool get twelveHourClock => !widget.is24HoursFormat;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      if (_startTimeFocus) {
        startTimeFocus.requestFocus();
      } else {
        endTimeFocus.requestFocus();
      }
      _paused = true;
    } else if (state == AppLifecycleState.paused) {
      startTimeFocus.unfocus();
      endTimeFocus.unfocus();
    }
  }

  @override
  void initState() {
    super.initState();
    if (Platform.isAndroid) WidgetsBinding.instance?.addObserver(this);

    startTimePeriod = widget.timeInput.startTime?.period ?? DayPeriod.pm;
    endTimePeriod = widget.timeInput.endTime?.period ?? DayPeriod.pm;

    startTimeFocus = FocusNode()
      ..requestFocus()
      ..addListener(() {
        if (startTimeFocus.hasFocus) {
          if (_paused) {
            _paused = false;
          } else {
            _startTimeFocus = true;
            startTimeController.selection = TextSelection(
                baseOffset: 0, extentOffset: startTimeController.text.length);
            final validEndTime =
                valid(endTimeController) || endTimeController.text.isEmpty;
            final validatedEndTime =
                validEndTime ? endTimeController.text : validatedNewEndTime;
            endTimeController.text = validatedEndTime;
            setState(() => validatedNewEndTime = validatedEndTime);
          }
        }
      });
    endTimeFocus = FocusNode()
      ..addListener(() {
        if (endTimeFocus.hasFocus) {
          if (_paused) {
            _paused = false;
          } else {
            _startTimeFocus = false;
            endTimeController.selection = TextSelection(
                baseOffset: 0, extentOffset: endTimeController.text.length);
            final validStartTime =
                valid(startTimeController) || startTimeController.text.isEmpty;
            final validatedStartTime = validStartTime
                ? startTimeController.text
                : validatedNewStartTime;
            startTimeController.text = validatedStartTime;
            setState(() => validatedNewStartTime = validatedStartTime);
          }
        }
      });

    validatedNewStartTime = widget.timeInput.rawStartTime(twelveHourClock);
    validatedNewEndTime = widget.timeInput.rawEndTime(twelveHourClock);

    startTimeController = TextEditingController(text: validatedNewStartTime);
    endTimeController = TextEditingController(text: validatedNewEndTime);
  }

  @override
  void dispose() {
    if (Platform.isAndroid) WidgetsBinding.instance?.removeObserver(this);
    startTimeController.dispose();
    endTimeController.dispose();
    super.dispose();
  }

  static bool valid(TextEditingController controller) =>
      controller.text.length == 4;

  TimeOfDay? newTime(TextEditingController controller, DayPeriod period) {
    if (valid(controller)) {
      final hour = int.tryParse(controller.text.substring(0, 2));
      final minute = int.tryParse(controller.text.substring(2, 4));
      if (hour != null && minute != null) {
        return TimeOfDay(hour: in24HourClock(hour, period), minute: minute);
      }
    }
    return null;
  }

  TimeInput get newTimeInput => TimeInput(
        newTime(startTimeController, startTimePeriod),
        newTime(endTimeController, endTimePeriod),
      );

  FutureOr<bool> save() =>
      widget.onSave(context, valid(startTimeController) ? newTimeInput : null);

  int in24HourClock(int hour, DayPeriod period) {
    if (!twelveHourClock) return hour;
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
      builder: (context, memoSettingsState) => Column(
        children: [
          Theme(
            data: theme.copyWith(
                textSelectionTheme: theme.textSelectionTheme.copyWith(
                  selectionColor: AbiliaColors.white,
                ),
                textTheme: theme.textTheme
                    .copyWith(subtitle1: abiliaTextTheme.headline4)),
            child: Padding(
              padding: EdgeInsets.only(top: 64.0.s),
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
                      if (valid(startTimeController)) {
                        endTimeFocus.requestFocus();
                        if (widget.onValidTimeInput != null) {
                          widget.onValidTimeInput?.call(newTimeInput);
                        } else {
                          setState(() {});
                        }
                      }
                    },
                    period: startTimePeriod,
                    onDone: save,
                    onPeriodChanged: (period) =>
                        setState(() => startTimePeriod = period),
                    twelveHourClock: twelveHourClock,
                    focusNode: startTimeFocus,
                    controller: startTimeController,
                  ),
                  if (memoSettingsState.activityEndTimeEditable) ...[
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 28.s),
                        SizedBox(
                          height: 64.s,
                          child: Center(
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16.0.s),
                              child: Text(
                                '—',
                                style: abiliaTextTheme.headline5,
                              ),
                            ),
                          ),
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
                      onPeriodChanged: (period) =>
                          setState(() => endTimePeriod = period),
                      onTimeChanged: (value) {
                        if (valid(startTimeController)) {
                          final onValidTimeInput = widget.onValidTimeInput;
                          if (onValidTimeInput != null) {
                            onValidTimeInput(newTimeInput);
                          } else {
                            setState(() {});
                          }
                        }
                      },
                      twelveHourClock: twelveHourClock,
                      focusNode: endTimeFocus,
                      controller: endTimeController,
                    ),
                  ]
                ],
              ),
            ),
          ),
          const Spacer(),
          widget.bottomNavigationBuilder(
            context,
            valid(startTimeController) ? newTimeInput : null,
          ),
        ],
      ),
    );
  }
}

class _TimeInput extends StatelessWidget {
  const _TimeInput({
    Key? key,
    required this.heading,
    required this.controller,
    required this.focusNode,
    required this.twelveHourClock,
    required this.period,
    required this.onPeriodChanged,
    required this.amRadioFieldKey,
    required this.pmRadioFieldKey,
    required this.inputKey,
    required this.onDone,
    this.onTimeChanged,
  }) : super(key: key);

  final TextEditingController controller;
  final FocusNode focusNode;
  final bool twelveHourClock;
  final DayPeriod period;
  final ValueChanged<DayPeriod> onPeriodChanged;
  final ValueChanged<String>? onTimeChanged;
  final String heading;
  final Key amRadioFieldKey, pmRadioFieldKey, inputKey;
  final FutureOr<bool> Function() onDone;

  @override
  Widget build(BuildContext context) {
    return Tts.longPress(
      () => ttsText(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SubHeading(heading),
          _TimeInputStack(
            inputKey: inputKey,
            editingController: controller,
            editFocus: focusNode,
            twelveHourClock: twelveHourClock,
            onTimeChanged: onTimeChanged,
            onDone: onDone,
          ),
          SizedBox(height: 8.0.s),
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
    if (!_TimeInputContentState.valid(controller)) return heading;
    final clockTime = '$heading ${formatTimeToDisplay(controller.text)}';
    if (!twelveHourClock) return clockTime;
    return '$clockTime '
        '${(period == DayPeriod.am ? Translator.of(context).translate.am : Translator.of(context).translate.pm)}';
  }
}

class _TimeInputStack extends StatefulWidget {
  final TextEditingController editingController;
  final FocusNode editFocus;
  final ValueChanged<String>? onTimeChanged;
  final FutureOr<bool> Function() onDone;
  final bool twelveHourClock;
  final Key? inputKey;

  const _TimeInputStack({
    this.inputKey,
    required this.editingController,
    required this.editFocus,
    required this.twelveHourClock,
    required this.onDone,
    this.onTimeChanged,
  });
  @override
  _TimeInputStackState createState() => _TimeInputStackState();
}

class _TimeInputStackState extends State<_TimeInputStack> {
  final displayFocus = FocusNode(
    canRequestFocus: false,
  );

  late TextEditingController displayController;

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
    return SizedBox(
      width: 120.s,
      height: 64.s,
      child: Stack(
        children: [
          TextField(
            key: widget.inputKey,
            focusNode: editFocus,
            keyboardType: TextInputType.number,
            showCursor: false,
            controller: editController,
            onChanged: (value) => widget.onTimeChanged?.call(value),
            onSubmitted: (v) async {
              if (!(await widget.onDone())) {
                editFocus.requestFocus();
              }
            },
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
                    width: 2.s,
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

const emptyPattern = '--:--';

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
        selection: const TextSelection.collapsed(offset: 3),
      );
    } else if (oldValue.text.length == 1 && newValue.text.length == 4) {
      return TextEditingValue(
        text: oldValue.text + newValue.text.substring(3, 4),
        selection: const TextSelection.collapsed(offset: 2),
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
    if (newValue.text.length == 1 &&
        intVal != null &&
        intVal > (twelveHourClock ? 1 : 2)) {
      return TextEditingValue(
        text: pad0(newValue.text),
        selection: const TextSelection.collapsed(offset: 2),
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
    if (input.isEmpty) return true;
    final intVal = int.tryParse(input);
    if (intVal == null) return false;

    switch (input.length) {
      case 1:
        return twelveHourClock ? intVal <= 1 : intVal <= 2;
      case 2:
        return twelveHourClock ? intVal >= 1 && intVal <= 12 : intVal <= 23;
      case 3:
        final sub = int.tryParse(input.substring(2, 3));
        return sub != null && sub <= 5;
      case 4:
        final sub = int.tryParse(input.substring(2, 4));
        return sub != null && sub <= 59;
      default:
        return false;
    }
  }
}

class TimeInput {
  final TimeOfDay? startTime;
  final TimeOfDay? endTime;

  TimeInput(this.startTime, this.endTime);

  String rawStartTime(bool twelveHourClock) {
    return rawTimeOfDay(startTime, twelveHourClock);
  }

  String rawEndTime(bool twelveHourClock) {
    return rawTimeOfDay(endTime, twelveHourClock);
  }

  String rawTimeOfDay(TimeOfDay? tod, bool twelveHourClock) {
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
  final Key? amRadioFieldKey;
  final Key? pmRadioFieldKey;

  const AmPmSelector({
    Key? key,
    required this.groupValue,
    required this.onChanged,
    this.amRadioFieldKey,
    this.pmRadioFieldKey,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      _AmPmButton(
        buttonKey: amRadioFieldKey,
        text: Translator.of(context).translate.am,
        onPressed: () => onChanged(DayPeriod.am),
        groupValue: groupValue,
        value: DayPeriod.am,
        borderRadius: borderRadiusLeft,
      ),
      SizedBox(width: 2.s),
      _AmPmButton(
        buttonKey: pmRadioFieldKey,
        text: Translator.of(context).translate.pm,
        onPressed: () => onChanged(DayPeriod.pm),
        groupValue: groupValue,
        value: DayPeriod.pm,
        borderRadius: borderRadiusRight,
      ),
    ]);
  }
}

class _AmPmButton extends StatelessWidget {
  final DayPeriod value;
  final DayPeriod groupValue;
  final String text;
  final BorderRadius borderRadius;
  final VoidCallback onPressed;
  final Key? buttonKey;

  const _AmPmButton({
    required this.buttonKey,
    required this.onPressed,
    required this.value,
    required this.groupValue,
    required this.text,
    required this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return Tts.data(
      data: text,
      child: TextButton(
        key: buttonKey,
        onPressed: onPressed,
        style: tabButtonStyle(
          borderRadius: borderRadius,
          isSelected: value == groupValue,
        ).copyWith(
          minimumSize: MaterialStateProperty.all(Size(59.0.s, 48.0.s)),
          textStyle: MaterialStateProperty.all(abiliaTextTheme.subtitle1),
        ),
        child: Text(text),
      ),
    );
  }
}
