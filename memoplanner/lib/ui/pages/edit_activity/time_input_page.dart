import 'dart:async';
import 'package:memoplanner/bloc/all.dart';
import 'package:memoplanner/ui/all.dart';

class TimeInputPage extends StatelessWidget {
  final TimeInput timeInput;
  final timeInputKey = GlobalKey<_TimeInputContentState>();

  TimeInputPage({
    required this.timeInput,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AbiliaAppBar(
        title: Translator.of(context).translate.setTime,
        iconData: AbiliaIcons.clock,
        height: layout.appBar.mediumHeight,
        trailing: Padding(
          padding: layout.alarmPage.clockPadding,
          child: AbiliaClock(
            style: Theme.of(context)
                .textTheme
                .caption
                ?.copyWith(color: AbiliaColors.white),
          ),
        ),
      ),
      body: TimeInputContent(
        key: timeInputKey,
        timeInput: timeInput,
        is24HoursFormat: MediaQuery.of(context).alwaysUse24HourFormat,
        bottomNavigationBuilder: (
          context,
          newTimeInput,
          savedStartTimeInput,
        ) =>
            BottomNavigation(
          backNavigationWidget: const CancelButton(),
          forwardNavigationWidget: OkButton(
            onPressed: () => onSave(
              context,
              newTimeInput,
              savedStartTimeInput,
            ),
          ),
        ),
      ),
    );
  }

  Future<bool> onSave(
    BuildContext context,
    TimeInput? newTimInput,
    String savedStartTimeInput,
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
      timeInputKey.currentState?.updateStartTimeInput(savedStartTimeInput);
      return false;
    }
  }
}

class TimeInputContent extends StatefulWidget {
  final TimeInput timeInput;

  final BottomNavigationBuilder? bottomNavigationBuilder;
  final OnValidTimeInput? onValidTimeInput;

  final bool is24HoursFormat;

  const TimeInputContent({
    required this.timeInput,
    required this.is24HoursFormat,
    this.bottomNavigationBuilder,
    this.onValidTimeInput,
    Key? key,
  }) : super(key: key);

  @override
  State createState() => _TimeInputContentState();
}

String pad0(String s) => s.padLeft(2, '0');

typedef BottomNavigationBuilder = Widget Function(
    BuildContext context, TimeInput? newTimeInput, String savedStartTimeInput);

typedef OnValidTimeInput = void Function(TimeInput newTimeInput);

class _TimeInputContentState extends State<TimeInputContent> {
  late TextEditingController startTimeController;
  late TextEditingController endTimeController;
  late DayPeriod startTimePeriod;
  late DayPeriod endTimePeriod;
  late FocusNode startTimeFocus;
  late FocusNode endTimeFocus;

  bool get twelveHourClock => !widget.is24HoursFormat;

  @override
  void initState() {
    super.initState();

    startTimePeriod = widget.timeInput.startTime?.period ?? DayPeriod.pm;
    endTimePeriod = widget.timeInput.endTime?.period ?? DayPeriod.pm;

    startTimeFocus = FocusNode()
      ..requestFocus()
      ..addListener(() {
        if (!startTimeFocus.hasFocus) {
          _focusChangedValidation();
        }
      });

    endTimeFocus = FocusNode()
      ..addListener(() {
        if (!endTimeFocus.hasFocus) {
          _focusChangedValidation();
        }
      });

    final startTime = widget.timeInput.rawStartTime(twelveHourClock);
    final endTime = widget.timeInput.rawEndTime(twelveHourClock);

    startTimeController = TextEditingController(text: startTime)
      ..addListener(() {
        if (valid(startTimeController) || startTimeController.text.isEmpty) {
          _onNewValidTime();
        }
      });

    endTimeController = TextEditingController(text: endTime)
      ..addListener(() {
        if (valid(endTimeController) || endTimeController.text.isEmpty) {
          _onNewValidTime();
        }
      });
  }

  void _onNewValidTime() {
    widget.onValidTimeInput?.call(newTimeInput);
    if (widget.onValidTimeInput == null) {
      setState(() {});
    }
  }

  String _focusChangedValidation() {
    final controller =
        startTimeFocus.hasFocus ? endTimeController : startTimeController;
    controller.selection =
        TextSelection(baseOffset: 0, extentOffset: controller.text.length);
    return controller.text = valid(controller) ? controller.text : '';
  }

  @override
  void dispose() {
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

  TextEditingController get focusedController =>
      startTimeFocus.hasFocus ? startTimeController : endTimeController;

  TimeInput get newTimeInput => TimeInput(
        newTime(startTimeController, startTimePeriod),
        newTime(endTimeController, endTimePeriod),
      );

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
    final bottomNavigationBuilder = widget.bottomNavigationBuilder;
    final showEndTime = context.select((MemoplannerSettingsBloc bloc) =>
        bloc.state.addActivity.general.showEndTime);
    return Column(
      children: [
        Theme(
          data: theme.copyWith(
              textSelectionTheme: theme.textSelectionTheme.copyWith(
                selectionColor: AbiliaColors.white,
              ),
              textTheme: theme.textTheme
                  .copyWith(subtitle1: abiliaTextTheme.headline4)),
          child: Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _TimeInput(
                      inputKey: TestKey.startTimeInput,
                      amRadioFieldKey: TestKey.startTimeAmRadioField,
                      pmRadioFieldKey: TestKey.startTimePmRadioField,
                      heading: translate.startTime,
                      period: startTimePeriod,
                      onPeriodChanged: (period) {
                        _onNewValidTime();
                        setState(() => startTimePeriod = period);
                      },
                      twelveHourClock: twelveHourClock,
                      focusNode: startTimeFocus,
                      controller: startTimeController,
                    ),
                    if (showEndTime) ...[
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Center(
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal:
                                    layout.formPadding.groupHorizontalDistance,
                              ),
                              child: Text(
                                '—',
                                style: abiliaTextTheme.headline5,
                              ),
                            ),
                          ),
                          SizedBox(
                            height: layout.timeInput.timeDashAlignValue +
                                layout.formPadding.verticalItemDistance +
                                (twelveHourClock
                                    ? layout.timeInput.amPmHeight
                                    : 0),
                          ),
                        ],
                      ),
                      _TimeInput(
                        inputKey: TestKey.endTimeInput,
                        amRadioFieldKey: TestKey.endTimeAmRadioField,
                        pmRadioFieldKey: TestKey.endTimePmRadioField,
                        heading: translate.endTime,
                        period: endTimePeriod,
                        onPeriodChanged: (period) {
                          _onNewValidTime();
                          setState(() => endTimePeriod = period);
                        },
                        twelveHourClock: twelveHourClock,
                        focusNode: endTimeFocus,
                        controller: endTimeController,
                      ),
                    ],
                  ],
                ),
                SizedBox(
                  height: layout.timeInput.inputKeyboardDistance,
                ),
                AbiliaNumPad(
                  delete: _deleteOneDigit,
                  onNumPress: _numPadKeyPress,
                  onClear: _clearPress,
                ),
              ],
            ),
          ),
        ),
        if (bottomNavigationBuilder != null)
          bottomNavigationBuilder(
            context,
            valid(startTimeController) ? newTimeInput : null,
            startTimeController.text,
          ),
      ],
    );
  }

  void updateStartTimeInput(String text) {
    startTimeController.text = text;
  }

  void _deleteOneDigit() {
    if (endTimeFocus.hasFocus && endTimeController.text.isEmpty) {
      startTimeFocus.requestFocus();
    }

    final controller = focusedController;
    if (controller.text.isEmpty) return;
    controller.text = controller.text.substring(0, controller.text.length - 1);
    setState(() {});
  }

  void _numPadKeyPress(String value) {
    final controller = focusedController;
    final currentTextControllerState = valid(controller) ? '' : controller.text;

    controller.text = _validate(
      currentTextControllerState,
      currentTextControllerState + value,
    );

    if (startTimeFocus.hasFocus && valid(startTimeController)) {
      endTimeFocus.requestFocus();
    }
    setState(() {});
  }

  void _clearPress() {
    focusedController.clear();
    setState(() {});
  }

  String _validate(String oldValue, String newValue) {
    final newText = _handleLeadingZero(newValue);
    return _isTimeInputValid(newText) ? newText : oldValue;
  }

  String _handleLeadingZero(String value) {
    final intVal = int.tryParse(value);
    if (value.length == 1 &&
        intVal != null &&
        intVal > (twelveHourClock ? 1 : 2)) {
      return pad0(value);
    } else {
      return value;
    }
  }

  bool _isTimeInputValid(String input) {
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

class _TimeInput extends StatelessWidget {
  const _TimeInput({
    required this.heading,
    required this.controller,
    required this.focusNode,
    required this.twelveHourClock,
    required this.period,
    required this.onPeriodChanged,
    required this.amRadioFieldKey,
    required this.pmRadioFieldKey,
    required this.inputKey,
    Key? key,
  }) : super(key: key);

  final TextEditingController controller;
  final FocusNode focusNode;
  final bool twelveHourClock;
  final DayPeriod period;
  final ValueChanged<DayPeriod> onPeriodChanged;

  final String heading;
  final Key amRadioFieldKey, pmRadioFieldKey, inputKey;

  @override
  Widget build(BuildContext context) {
    return Tts.longPress(
      () => ttsText(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SubHeading(heading),
          _TimeInputField(
            inputKey: inputKey,
            editingController: controller,
            focus: focusNode,
          ),
          SizedBox(height: layout.formPadding.verticalItemDistance),
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

class _TimeInputField extends StatefulWidget {
  final TextEditingController editingController;
  final FocusNode focus;

  final Key? inputKey;

  const _TimeInputField({
    required this.editingController,
    required this.focus,
    this.inputKey,
  });

  @override
  _TimeInputFieldState createState() => _TimeInputFieldState();
}

class _TimeInputFieldState extends State<_TimeInputField> {
  late TextEditingController displayController;

  @override
  void initState() {
    super.initState();
    displayController = TextEditingController(
        text: formatTimeToDisplay(widget.editingController.text));
    widget.editingController.addListener(() => displayController.text =
        formatTimeToDisplay(widget.editingController.text));
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () => widget.focus.requestFocus(),
      child: SizedBox(
        width: layout.timeInput.width,
        child: IgnorePointer(
          child: TextField(
            key: widget.inputKey,
            readOnly: true,
            focusNode: widget.focus,
            keyboardType: TextInputType.number,
            showCursor: false,
            controller: displayController,
            textAlign: TextAlign.center,
            textAlignVertical: TextAlignVertical.center,
            decoration: InputDecoration(
              focusedBorder: OutlineInputBorder(
                borderRadius: borderRadius,
                borderSide: BorderSide(
                  color: Colors.black,
                  width: layout.borders.medium,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: borderRadius,
                borderSide: BorderSide(
                  color: Colors.grey,
                  width: layout.borders.thin,
                ),
              ),
            ),
          ),
        ),
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
    required this.groupValue,
    required this.onChanged,
    this.amRadioFieldKey,
    this.pmRadioFieldKey,
    Key? key,
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
      SizedBox(width: layout.timeInput.amPmDistance),
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
          minimumSize: MaterialStateProperty.all(Size(
            layout.timeInput.amPmWidth,
            layout.timeInput.amPmHeight,
          )),
          textStyle: MaterialStateProperty.all(abiliaTextTheme.subtitle1),
        ),
        child: Text(text),
      ),
    );
  }
}
