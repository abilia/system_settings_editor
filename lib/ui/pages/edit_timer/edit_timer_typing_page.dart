import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/bloc/edit_timer/edit_timer_cubit.dart';
import 'package:seagull/ui/all.dart';

String _pad0(String s) => s.padLeft(2, '0');

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
      body: _TimerInputContent(),
    );
  }
}

class _TimerInputContent extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _TimerInputState();
  }
}

class _TimerInputState extends State<_TimerInputContent> {
  bool _minuteFocus = true;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final translate = Translator.of(context).translate;
    return BlocProvider<EditTimerCubit>(
      create: (context) => EditTimerCubit(0, 0),
      child: BlocSelector<EditTimerCubit, EditTimerState, Duration>(
        selector: (state) => state.duration,
        builder: (context, duration) {
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
                          text: _pad0(duration.inHours.toString()),
                          focus: !_minuteFocus,
                          onChanged: (hours) {
                            context
                                .read<EditTimerCubit>()
                                .updateDuration(hours: int.tryParse(hours));
                            _minuteFocus = false;
                          },
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
                          text: (duration.inMinutes % Duration.minutesPerHour)
                              .toString(),
                          focus: _minuteFocus,
                          onChanged: (minutes) {
                            context
                                .read<EditTimerCubit>()
                                .updateDuration(minutes: int.tryParse(minutes));
                            _minuteFocus = true;
                          },
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
              BottomNavigation(
                backNavigationWidget: const CancelButton(),
                forwardNavigationWidget: duration.inMinutes > 0
                    ? SaveButton(
                        onPressed: () => Navigator.of(context).pop(duration),
                      )
                    : DarkGreyButton(
                        text: Translator.of(context).translate.save,
                        icon: AbiliaIcons.ok),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _TimeTextField extends StatelessWidget {
  final ValueChanged<String> onChanged;
  final List<TextInputFormatter> inputFormatters;
  final String header;
  final FocusNode focusNode = FocusNode();
  final String text;
  final bool focus;

  _TimeTextField(
      {Key? key,
      required this.text,
      required this.focus,
      required this.header,
      required this.onChanged,
      required this.inputFormatters})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (focus) {
      focusNode.requestFocus();
    }
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
            controller: TextEditingController(text: _pad0(text))
              ..selection = _textSelection,
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
