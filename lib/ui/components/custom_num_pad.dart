import 'package:seagull/ui/all.dart';

class AbiliaNumPad extends StatelessWidget {
  final double buttonSize;
  final double buttonWidth;
  final double buttonHeight;
  final Color buttonColor;
  final Color iconColor;
  final Function delete;
  final Function onClear;
  final Function onNumPress;

  const AbiliaNumPad({
    Key? key,
    this.buttonSize = 48,
    this.buttonWidth = 80,
    this.buttonHeight = 48,
    this.buttonColor = AbiliaColors.white135,
    this.iconColor = AbiliaColors.black,
    required this.delete,
    required this.onClear,
    required this.onNumPress,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 60, right: 60),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              NumberButton(
                number: 1,
                width: buttonWidth,
                height: buttonHeight,
                color: buttonColor,
                onNumPress: onNumPress,
              ),
              NumberButton(
                number: 2,
                width: buttonWidth,
                height: buttonHeight,
                color: buttonColor,
                onNumPress: onNumPress,
              ),
              NumberButton(
                number: 3,
                width: buttonWidth,
                height: buttonHeight,
                color: buttonColor,
                onNumPress: onNumPress,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              NumberButton(
                number: 4,
                width: buttonWidth,
                height: buttonHeight,
                color: buttonColor,
                onNumPress: onNumPress,
              ),
              NumberButton(
                number: 5,
                width: buttonWidth,
                height: buttonHeight,
                color: buttonColor,
                onNumPress: onNumPress,
              ),
              NumberButton(
                number: 6,
                width: buttonWidth,
                height: buttonHeight,
                color: buttonColor,
                onNumPress: onNumPress,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              NumberButton(
                number: 7,
                width: buttonWidth,
                height: buttonHeight,
                color: buttonColor,
                onNumPress: onNumPress,
              ),
              NumberButton(
                number: 8,
                width: buttonWidth,
                height: buttonHeight,
                color: buttonColor,
                onNumPress: onNumPress,
              ),
              NumberButton(
                number: 9,
                width: buttonWidth,
                height: buttonHeight,
                color: buttonColor,
                onNumPress: onNumPress,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ActionButton(
                  buttonIcon: AbiliaIcons.cancel,
                  buttonWidth: buttonWidth,
                  buttonHeight: buttonHeight,
                  onButtonPress: onClear,
                  buttonSize: buttonSize),
              NumberButton(
                number: 0,
                width: buttonWidth,
                height: buttonHeight,
                color: buttonColor,
                onNumPress: onNumPress,
              ),
              ActionButton(
                  buttonIcon: AbiliaIcons.delete,
                  buttonWidth: buttonWidth,
                  buttonHeight: buttonHeight,
                  onButtonPress: delete,
                  buttonSize: buttonSize),
            ],
          ),
        ],
      ),
    );
  }
}

class ActionButton extends StatelessWidget {
  const ActionButton({
    Key? key,
    required this.buttonIcon,
    required this.buttonWidth,
    required this.buttonHeight,
    required this.onButtonPress,
    required this.buttonSize,
  }) : super(key: key);

  final IconData buttonIcon;
  final double buttonWidth;
  final double buttonHeight;
  final Function onButtonPress;
  final double buttonSize;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12.0),
      child: Container(
        width: buttonWidth,
        height: buttonHeight,
        color: AbiliaColors.white,
        child: IconButton(
          onPressed: () => onButtonPress(),
          icon: Icon(
            buttonIcon,
            size: 32,
            color: AbiliaColors.black,
          ),
          iconSize: buttonSize,
        ),
      ),
    );
  }
}

class NumberButton extends StatelessWidget {
  final int number;
  final double width;
  final double height;
  final Color color;
  final Function onNumPress;

  const NumberButton({
    Key? key,
    required this.number,
    required this.width,
    required this.height,
    required this.color,
    required this.onNumPress,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: TextButton(
        style: TextButton.styleFrom(
          backgroundColor: color,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
              side: const BorderSide(width: 0.4, color: AbiliaColors.black)),
        ),
        onPressed: () => onNumPress(number.toString()),
        child: Center(
          child: Text(
            number.toString(),
            style: const TextStyle(color: AbiliaColors.black, fontSize: 24),
          ),
        ),
      ),
    );
  }
}
