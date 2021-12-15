import 'package:flutter/services.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/ui/all.dart';
import 'package:seagull/utils/strings.dart';

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

class _TimerInputContent extends StatelessWidget {
  final FocusNode hourFocus = FocusNode();
  final FocusNode minuteFocus = FocusNode();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final translate = Translator.of(context).translate;
    return BlocProvider<_EditTimerCubit>(
      create: (context) => _EditTimerCubit(0, 0),
      child: BlocBuilder<_EditTimerCubit, _EditTimerState>(
        builder: (context, state) {
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
                          header: translate.hours.capitalize(),
                          text: _pad0(state.duration.inHours.toString()),
                          focusNode: state.minuteFocus
                              ? hourFocus
                              : (hourFocus..requestFocus()),
                          onChanged: (hours) {
                            context
                                .read<_EditTimerCubit>()
                                .updateDuration(hours: int.tryParse(hours));
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
                          header: translate.minutes.capitalize(),
                          text: (state.duration.inMinutes %
                                  Duration.minutesPerHour)
                              .toString(),
                          focusNode: !state.minuteFocus
                              ? minuteFocus
                              : (minuteFocus..requestFocus()),
                          onChanged: (minutes) {
                            context
                                .read<_EditTimerCubit>()
                                .updateDuration(minutes: int.tryParse(minutes));
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
                  forwardNavigationWidget: SaveButton(
                    onPressed: () => onSave(context, state.duration),
                  )),
            ],
          );
        },
      ),
    );
  }

  Future<void> onSave(BuildContext context, Duration duration) async {
    if (duration.inMinutes > 0) {
      Navigator.of(context).pop(duration);
    } else {
      await showViewDialog(
        context: context,
        builder: (context) => ErrorDialog(
          text: Translator.of(context).translate.timerInvalidDuration,
        ),
      );
    }
  }
}

class _TimeTextField extends StatelessWidget {
  final ValueChanged<String> onChanged;
  final List<TextInputFormatter> inputFormatters;
  final String header;
  final FocusNode focusNode;
  final String text;

  const _TimeTextField(
      {Key? key,
      required this.text,
      required this.header,
      required this.onChanged,
      required this.focusNode,
      required this.inputFormatters})
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
    final intVal = int.tryParse(newValue.text);
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
    final intVal = int.tryParse(newValue.text);
    if (intVal == null || intVal > 23) {
      return oldValue;
    }
    return newValue;
  }
}

class _EditTimerCubit extends Cubit<_EditTimerState> {
  _EditTimerCubit(int hours, int minutes)
      : super(_EditTimerState(minutes, hours, true));

  void updateDuration({int? hours, int? minutes}) {
    emit(state.copyWith(hours, minutes));
  }
}

class _EditTimerState {
  final int hours;
  final int minutes;
  final bool minuteFocus;
  late final Duration duration;

  _EditTimerState(this.hours, this.minutes, this.minuteFocus) {
    duration = Duration(hours: hours, minutes: minutes);
  }

  _EditTimerState copyWith(int? hours, int? minutes) {
    return _EditTimerState(hours ?? this.hours, minutes ?? this.minutes,
        minutes != null || (hours != null && hours > 9));
  }
}
