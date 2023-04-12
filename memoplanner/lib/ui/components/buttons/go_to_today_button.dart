import 'package:memoplanner/ui/all.dart';

class GoToTodayButton extends StatelessWidget {
  const GoToTodayButton({
    Key? key,
    this.onPressed,
  }) : super(key: key);
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final translate = Translator.of(context).translate;
    return TextAndIconActionButton(
      key: TestKey.goToTodayButton,
      translate.today,
      AbiliaIcons.reset,
      style: actionButtonStyleRedLarge,
      onPressed: onPressed,
      size: layout.actionButton.withTextIconSizeSmall,
    );
  }
}
