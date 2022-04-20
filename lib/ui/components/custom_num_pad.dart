import 'package:seagull/ui/all.dart';

class NumPad extends StatelessWidget {
  final double buttonSize;
  final double buttonWidth;
  final double buttonHeight;
  final Color buttonColor;
  final Color iconColor;
  final TextEditingController controllerStart;
  final TextEditingController controllerEnd;
  final Function delete;
  final Function onClear;

  const NumPad({
    Key? key,
    this.buttonSize = 48,
    this.buttonWidth = 80,
    this.buttonHeight = 48,
    this.buttonColor = AbiliaColors.white135,
    this.iconColor = AbiliaColors.black,
    required this.delete,
    required this.onClear,
    required this.controllerStart,
    required this.controllerEnd,
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
                controllerStart: controllerStart,
                controllerEnd: controllerEnd,
              ),
              NumberButton(
                number: 2,
                width: buttonWidth,
                height: buttonHeight,
                color: buttonColor,
                controllerStart: controllerStart,
                controllerEnd: controllerEnd,
              ),
              NumberButton(
                number: 3,
                width: buttonWidth,
                height: buttonHeight,
                color: buttonColor,
                controllerStart: controllerStart,
                controllerEnd: controllerEnd,
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
                controllerStart: controllerStart,
                controllerEnd: controllerEnd,
              ),
              NumberButton(
                number: 5,
                width: buttonWidth,
                height: buttonHeight,
                color: buttonColor,
                controllerStart: controllerStart,
                controllerEnd: controllerEnd,
              ),
              NumberButton(
                number: 6,
                width: buttonWidth,
                height: buttonHeight,
                color: buttonColor,
                controllerStart: controllerStart,
                controllerEnd: controllerEnd,
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
                controllerStart: controllerStart,
                controllerEnd: controllerEnd,
              ),
              NumberButton(
                number: 8,
                width: buttonWidth,
                height: buttonHeight,
                color: buttonColor,
                controllerStart: controllerStart,
                controllerEnd: controllerEnd,
              ),
              NumberButton(
                number: 9,
                width: buttonWidth,
                height: buttonHeight,
                color: buttonColor,
                controllerStart: controllerStart,
                controllerEnd: controllerEnd,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                onPressed: () => onClear(),
                icon: const Icon(
                  AbiliaIcons.cancel,
                  color: AbiliaColors.black,
                ),
                iconSize: buttonSize,
              ),
              NumberButton(
                number: 0,
                width: buttonWidth,
                height: buttonHeight,
                color: buttonColor,
                controllerStart: controllerStart,
                controllerEnd: controllerEnd,
              ),
              IconButton(
                onPressed: () => delete(),
                icon: const Icon(
                  AbiliaIcons.delete,
                  color: AbiliaColors.black,
                ),
                iconSize: buttonSize,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class NumberButton extends StatelessWidget {
  final int number;
  final double width;
  final double height;
  final Color color;
  final TextEditingController controllerStart;
  final TextEditingController controllerEnd;

  const NumberButton({
    Key? key,
    required this.number,
    required this.width,
    required this.height,
    required this.color,
    required this.controllerStart,
    required this.controllerEnd,
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
        onPressed: () {
          debugPrint('Text length: ${controllerStart.text.length}');
          if (controllerStart.text.length < 4) {
            controllerStart.text += number.toString();
          } else {
            if (controllerEnd.text.length < 4) {
              controllerEnd.text += number.toString();
            }
          }
        },
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
