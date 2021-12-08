import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:seagull/ui/all.dart';

String _pad0(String s) => s.padLeft(2, '0');

typedef BottomNavigationBuilder = Widget Function(
    BuildContext context, Duration? newDuration);
typedef _OnValidTimeInput = void Function(Duration duration);

const _textSelection = TextSelection(baseOffset: 0, extentOffset: 2);
const _emptyPattern = '00';

class EditTimerByTypingPage extends StatelessWidget {
  const EditTimerByTypingPage({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AbiliaAppBar(
        title: Translator.of(context).translate.setTime,
        iconData: AbiliaIcons.clock,
      ),
      body: TimeInputContent(
        bottomNavigationBuilder: (context, duration) => BottomNavigation(
          backNavigationWidget: const CancelButton(),
          forwardNavigationWidget: duration != null && duration.inMinutes > 0
              ? SaveButton(
                  onPressed: () => Navigator.of(context).pop(duration),
                )
              : DarkGreyButton(
                  text: Translator.of(context).translate.save,
                  icon: AbiliaIcons.ok),
        ),
      ),
    );
  }
}

class TimeInputContent extends StatefulWidget {
  final BottomNavigationBuilder bottomNavigationBuilder;
  final _OnValidTimeInput? onValidTimeInput;

  const TimeInputContent({
    Key? key,
    required this.bottomNavigationBuilder,
    this.onValidTimeInput,
  }) : super(key: key);

  @override
  _TimeInputContentState createState() => _TimeInputContentState();
}

class _TimeInputContentState extends State<TimeInputContent>
    with WidgetsBindingObserver {
  late TextEditingController hourEditingController;
  late TextEditingController minuteEditingController;
  late FocusNode hourFocus;
  late FocusNode minuteFocus;
  late String validatedNewStartTime;
  String hourText = _emptyPattern;
  String minuteText = _emptyPattern;
  bool _hourFocus = true;
  bool _paused = false;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      if (_hourFocus) {
        hourFocus.requestFocus();
      } else {
        minuteFocus.requestFocus();
      }
      _paused = true;
    } else if (state == AppLifecycleState.paused) {
      hourFocus.unfocus();
      minuteFocus.unfocus();
    }
  }

  @override
  void initState() {
    super.initState();
    if (Platform.isAndroid) WidgetsBinding.instance?.addObserver(this);
    hourFocus = FocusNode()
      ..addListener(() {
        if (hourFocus.hasFocus) {
          if (_paused) {
            _paused = false;
          } else {
            _hourFocus = true;
            hourEditingController.selection = _textSelection;
          }
        }
      });

    minuteFocus = FocusNode()
      ..requestFocus()
      ..addListener(() {
        if (minuteFocus.hasFocus) {
          if (_paused) {
            _paused = false;
          } else {
            _hourFocus = false;
            minuteEditingController.selection = _textSelection;
          }
        }
      });
    hourEditingController = TextEditingController(text: _emptyPattern);
    minuteEditingController = TextEditingController(text: _emptyPattern);
  }

  @override
  void dispose() {
    if (Platform.isAndroid) WidgetsBinding.instance?.removeObserver(this);
    hourEditingController.dispose();
    minuteEditingController.dispose();
    super.dispose();
  }

  Duration get newDuration => Duration(
      hours: int.tryParse(hourEditingController.text) ?? 0,
      minutes: int.tryParse(minuteEditingController.text) ?? 0);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final translate = Translator.of(context).translate;
    return Column(
      children: [
        Theme(
          data: theme.copyWith(
              textSelectionTheme: theme.textSelectionTheme.copyWith(
                selectionColor: Colors.transparent,
              ),
              textTheme: theme.textTheme
                  .copyWith(subtitle1: abiliaTextTheme.headline4)),
          child: Padding(
            padding: EdgeInsets.only(left: 42.s, top: 64.s, right: 42.s),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _TimeTextField(
                    key: TestKey.hours,
                    header: translate.hoursCap,
                    editController: hourEditingController,
                    focusNode: hourFocus,
                    onChanged: (value) => _onTimeChanged(value),
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      _EmptyInputFormatter(),
                      _LeadingZeroInputFormatter(),
                      LengthLimitingTextInputFormatter(2),
                      _HourInputFormatter()
                    ]),
                Padding(
                  padding: EdgeInsets.all(16.s),
                  child: Text(
                    ':',
                    style: Theme.of(context)
                        .textTheme
                        .headline5
                        ?.copyWith(color: AbiliaColors.black100),
                  ),
                ),
                _TimeTextField(
                    key: TestKey.minutes,
                    header: translate.minutesCap,
                    editController: minuteEditingController,
                    focusNode: minuteFocus,
                    onChanged: (value) => _onTimeChanged(value),
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      _EmptyInputFormatter(),
                      _LeadingZeroInputFormatter(),
                      LengthLimitingTextInputFormatter(2),
                      _MinuteInputFormatter()
                    ]),
              ],
            ),
          ),
        ),
        const Spacer(),
        widget.bottomNavigationBuilder(
          context,
          newDuration,
        ),
      ],
    );
  }

  _onTimeChanged(String value) {
    setState(() {});
  }
}

class _TimeTextField extends StatelessWidget {
  final TextEditingController editController;
  final ValueChanged<String> onChanged;
  final List<TextInputFormatter> inputFormatters;
  final String header;
  final FocusNode focusNode;

  const _TimeTextField(
      {Key? key,
      required this.header,
      required this.editController,
      required this.onChanged,
      required this.inputFormatters,
      required this.focusNode})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SubHeading(header),
          TextField(
            key: key,
            onTap: () => focusNode.requestFocus(),
            focusNode: focusNode,
            enableInteractiveSelection: false,
            keyboardType: TextInputType.number,
            showCursor: false,
            controller: editController,
            onChanged: (value) => onChanged.call(value),
            textInputAction: TextInputAction.done,
            inputFormatters: inputFormatters,
            textAlign: TextAlign.center,
            textAlignVertical: TextAlignVertical.center,
            decoration: InputDecoration(
              border: InputBorder.none,
              focusedBorder: OutlineInputBorder(
                borderRadius: borderRadius,
                borderSide: BorderSide(
                  color: Colors.black,
                  width: 2.s,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LeadingZeroInputFormatter extends TextInputFormatter {
  _LeadingZeroInputFormatter();

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    final intVal = int.tryParse(newValue.text);
    if (newValue.text.length == 1 && intVal != null) {
      if (oldValue.text != _emptyPattern && oldValue.text.startsWith('0')) {
        return TextEditingValue(
          text: oldValue.text.substring(1) + newValue.text,
          selection: _textSelection,
        );
      }
      return TextEditingValue(
        text: _pad0(newValue.text),
        selection: _textSelection,
      );
    }
    return newValue;
  }
}

class _EmptyInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isEmpty) {
      return const TextEditingValue(
        text: _emptyPattern,
        selection: _textSelection,
      );
    }
    return newValue;
  }
}

class _MinuteInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    final input = newValue.text;
    final intVal = int.tryParse(input);
    if (intVal == null || intVal > 59) {
      return oldValue;
    }
    return newValue;
  }
}

class _HourInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    final input = newValue.text;
    final intVal = int.tryParse(input);
    if (intVal == null || intVal > 23) {
      return oldValue;
    }
    return newValue;
  }
}
