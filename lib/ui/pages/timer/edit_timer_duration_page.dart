import 'package:flutter/services.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/ui/all.dart';
import 'package:seagull/utils/strings.dart';

String _pad0(String s) => s.padLeft(2, '0');

const _textSelection = TextSelection(baseOffset: 0, extentOffset: 2);
const _emptyPattern = '00';

class EditTimerDurationPage extends StatelessWidget {
  final Duration initialDuration;

  const EditTimerDurationPage({
    Key? key,
    this.initialDuration = Duration.zero,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AbiliaAppBar(
        title: Translator.of(context).translate.setTime,
        iconData: AbiliaIcons.clock,
      ),
      body: _TimerInputContent(initialDuration: initialDuration),
    );
  }
}

class _TimerInputContent extends StatelessWidget {
  final FocusNode minuteFocus = FocusNode()..requestFocus();
  final Duration initialDuration;

  _TimerInputContent({Key? key, required this.initialDuration})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final translate = Translator.of(context).translate;
    return BlocProvider<_EditTimerCubit>(
      create: (context) => _EditTimerCubit(initialDuration.inHours,
          initialDuration.inMinutes % Duration.minutesPerHour),
      child: BlocBuilder<_EditTimerCubit, _EditTimerState>(
        builder: (context, state) {
          return BlocListener<_EditTimerCubit, _EditTimerState>(
            listener: (context, state) {
              if (state.hours > 2) {
                minuteFocus.requestFocus();
              }
            },
            child: Column(
              children: [
                Theme(
                  data: theme.copyWith(
                      textSelectionTheme: theme.textSelectionTheme.copyWith(
                        selectionColor: Colors.transparent,
                      ),
                      textTheme: theme.textTheme
                          .copyWith(subtitle1: abiliaTextTheme.headline4)),
                  child: Padding(
                    padding: layout.templates.l4,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        SizedBox(
                          width: layout.editTimer.inputTimeWidth,
                          child: _TimeTextField(
                              key: TestKey.hours,
                              header: translate.hours.capitalize(),
                              text: _pad0(state.hours.toString()),
                              onChanged: (hours) {
                                context
                                    .read<_EditTimerCubit>()
                                    .updateDuration(hours: int.tryParse(hours));
                              },
                              granularityFormatter: _HourInputFormatter()),
                        ),
                        Padding(
                          padding: EdgeInsets.all(
                              layout.formPadding.groupHorizontalDistance),
                          child: DefaultTextStyle(
                            style: (theme.textTheme.headline5 ?? headline5),
                            child: const Text(':'),
                          ),
                        ),
                        SizedBox(
                          width: layout.editTimer.inputTimeWidth,
                          child: _TimeTextField(
                            key: TestKey.minutes,
                            header: translate.minutes.capitalize(),
                            text: (state.minutes % Duration.minutesPerHour)
                                .toString(),
                            focusNode: minuteFocus,
                            onChanged: (minutes) {
                              context.read<_EditTimerCubit>().updateDuration(
                                  minutes: int.tryParse(minutes));
                            },
                            granularityFormatter: _MinuteInputFormatter(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const Spacer(),
                BottomNavigation(
                  backNavigationWidget: const CancelButton(),
                  forwardNavigationWidget: SaveButton(
                    onPressed: () => onSave(
                      context,
                      state.duration,
                    ),
                  ),
                ),
              ],
            ),
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
  final TextInputFormatter granularityFormatter;
  final String header;
  final FocusNode? focusNode;
  final String text;

  const _TimeTextField(
      {Key? key,
      required this.text,
      required this.header,
      required this.onChanged,
      this.focusNode,
      required this.granularityFormatter})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SubHeading(header),
        TextField(
          key: key,
          onTap: () => focusNode?.requestFocus(),
          focusNode: focusNode,
          enableInteractiveSelection: false,
          keyboardType: TextInputType.number,
          showCursor: false,
          controller: TextEditingController(text: _pad0(text))
            ..selection = _textSelection,
          onChanged: (value) => onChanged.call(value),
          textInputAction: TextInputAction.done,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            _EmptyInputFormatter(),
            _LeadingZeroInputFormatter(),
            LengthLimitingTextInputFormatter(2),
            granularityFormatter,
          ],
          textAlign: TextAlign.center,
          textAlignVertical: TextAlignVertical.center,
          decoration: InputDecoration(
            border: InputBorder.none,
            focusedBorder: OutlineInputBorder(
              borderRadius: borderRadius,
              borderSide: BorderSide(
                color: Colors.black,
                width: layout.borders.medium,
              ),
            ),
          ),
        ),
      ],
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
      : super(_EditTimerState(hours, minutes));

  void updateDuration({int? hours, int? minutes}) {
    emit(state.copyWith(hours, minutes));
  }
}

class _EditTimerState {
  final int hours;
  final int minutes;

  get duration => Duration(hours: hours, minutes: minutes);

  _EditTimerState(this.hours, this.minutes);

  _EditTimerState copyWith(int? hours, int? minutes) {
    return _EditTimerState(hours ?? this.hours, minutes ?? this.minutes);
  }
}
