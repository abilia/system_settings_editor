import 'package:memoplanner/ui/all.dart';

class GoToTodayButton extends StatelessWidget {
  final VoidCallback? onPressed;

  const GoToTodayButton({
    this.onPressed,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final translate = Translator.of(context).translate;
    return Config.isMPGO
        ? IconActionButton(
            onPressed: onPressed,
            style: actionButtonStyleRedLarge,
            child: const Icon(AbiliaIcons.reset),
          )
        : TextAndIconActionButton(
            translate.today,
            AbiliaIcons.reset,
            onPressed: onPressed,
            style: actionButtonStyleRedLarge,
            size: layout.actionButton.withTextIconSizeSmall,
          );
  }
}
