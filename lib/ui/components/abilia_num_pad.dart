import 'package:seagull/ui/all.dart';

class AbiliaNumPad extends StatelessWidget {
  final VoidCallback delete;
  final VoidCallback onClear;
  final void Function(String n) onNumPress;

  const AbiliaNumPad({
    Key? key,
    required this.delete,
    required this.onClear,
    required this.onNumPress,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 3 * layout.timeInput.keyboardButtonWidth +
          2 * layout.timeInput.keyboardButtonPadding,
      child: Wrap(
        spacing: layout.timeInput.keyboardButtonPadding,
        runSpacing: layout.timeInput.keyboardButtonPadding,
        children: [
          ...Iterable.generate(9).map(
            (n) => KeyboardNumberButton(
              key: TestKey.keyPadNumber(n + 1),
              number: '${n + 1}',
              onNumPress: onNumPress,
            ),
          ),
          KeyboardActionButton(
            iconData: AbiliaIcons.cancel,
            onPressed: onClear,
          ),
          KeyboardNumberButton(
            key: TestKey.keyPadNumber(0),
            number: '0',
            onNumPress: onNumPress,
          ),
          KeyboardActionButton(
            iconData: AbiliaIcons.delete,
            onPressed: delete,
          ),
        ],
      ),
    );
  }
}

class KeyboardNumberButton extends StatelessWidget {
  final String number;
  final void Function(String) onNumPress;

  const KeyboardNumberButton({
    Key? key,
    required this.number,
    required this.onNumPress,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Tts.data(
      data: number,
      child: TextButton(
        onPressed: () => onNumPress(number),
        style: keyboardNumberButtonStyle,
        child: Text(number),
      ),
    );
  }
}

class KeyboardActionButton extends StatelessWidget {
  const KeyboardActionButton({
    Key? key,
    this.onPressed,
    required this.iconData,
  }) : super(key: key);

  final VoidCallback? onPressed;
  final IconData iconData;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      style: keyboardActionButtonStyle,
      child: Icon(iconData),
    );
  }
}
