import 'package:memoplanner/ui/all.dart';
import 'package:memoplanner/utils/all.dart';

String _pad0(String s) => s.padLeft(2, '0');
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
        title: Translator.of(context).translate.selectDuration,
        iconData: AbiliaIcons.clock,
      ),
      body: _TimerInputContent(initialDuration: initialDuration),
    );
  }
}

class _TimerInputContent extends StatefulWidget {
  final Duration initialDuration;

  const _TimerInputContent({
    required this.initialDuration,
    Key? key,
  }) : super(key: key);

  @override
  State<_TimerInputContent> createState() => _TimerInputContentState();
}

class _TimerInputContentState extends State<_TimerInputContent> {
  final FocusNode minuteFocus = FocusNode()..requestFocus();
  late final TextEditingController hourController;
  late final TextEditingController minuteController;

  @override
  void initState() {
    super.initState();
    final duration = widget.initialDuration;
    final minutes = duration.inMinutes % Duration.minutesPerHour;
    final hours = duration.inHours;
    minuteController = TextEditingController(text: _pad0(minutes.toString()));
    hourController = TextEditingController(text: _pad0(hours.toString()));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final translate = Translator.of(context).translate;
    return Column(
      children: [
        const Spacer(),
        Theme(
          data: theme.copyWith(
              textSelectionTheme: theme.textSelectionTheme.copyWith(
                selectionColor: Colors.transparent,
              ),
              textTheme: theme.textTheme
                  .copyWith(titleMedium: abiliaTextTheme.headlineMedium)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              SizedBox(
                width: layout.editTimer.inputTimeWidth,
                child: _TimeTextField(
                  key: TestKey.hours,
                  controller: hourController,
                  header: translate.hours.capitalize(),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(layout.editTimer.inputTimePadding),
                child: DefaultTextStyle(
                  style: theme.textTheme.headlineSmall ?? headlineSmall,
                  child: const Text(':'),
                ),
              ),
              SizedBox(
                width: layout.editTimer.inputTimeWidth,
                child: _TimeTextField(
                  key: TestKey.minutes,
                  header: translate.minutes.capitalize(),
                  focusNode: minuteFocus,
                  controller: minuteController,
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: layout.timeInput.inputKeyboardDistance,
        ),
        AbiliaNumPad(delete: () {
          final controller = _activeController();
          controller.text = _pad0(controller.text.substring(0, 1));
        }, onClear: () {
          minuteController.text = _emptyPattern;
          hourController.text = _emptyPattern;
        }, onNumPress: (v) {
          final controller = _activeController();
          final maxVal = _maxValueForActiveController();
          final next = _nextVal(controller.text, v, maxVal);
          controller.text = next;
          if (!minuteFocus.hasFocus &&
              (int.tryParse(controller.text) ?? 0) > 2) {
            minuteFocus.requestFocus();
          }
        }),
        const Spacer(),
        BottomNavigation(
          backNavigationWidget: const CancelButton(),
          forwardNavigationWidget: OkButton(
            onPressed: () => onSave(
              context,
              Duration(
                  hours: int.tryParse(hourController.text) ?? 0,
                  minutes: int.tryParse(minuteController.text) ?? 0),
            ),
          ),
        ),
      ],
    );
  }

  TextEditingController _activeController() {
    return minuteFocus.hasFocus ? minuteController : hourController;
  }

  int _maxValueForActiveController() {
    return minuteFocus.hasFocus ? 59 : 23;
  }

  String _nextVal(String current, String added, int max) {
    final intVal = int.tryParse(current) ?? 0;
    final newVal = intVal.toString() + added;
    final newInt = int.tryParse(newVal) ?? 0;
    return newInt > max ? _pad0(added) : _pad0(newInt.toString());
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
  final String header;
  final FocusNode? focusNode;
  final TextEditingController controller;

  const _TimeTextField({
    required this.header,
    required this.controller,
    this.focusNode,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Tts.fromSemantics(
      SemanticsProperties(label: header),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SubHeading(header),
          TextField(
            onTap: () => focusNode?.requestFocus(),
            readOnly: true,
            focusNode: focusNode,
            enableInteractiveSelection: false,
            keyboardType: TextInputType.number,
            showCursor: false,
            controller: controller,
            textInputAction: TextInputAction.done,
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
      ),
    );
  }
}
