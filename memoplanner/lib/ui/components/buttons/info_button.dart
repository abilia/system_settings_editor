import 'package:memoplanner/ui/all.dart';

class InfoButton extends StatelessWidget {
  final VoidCallback? onTap;

  const InfoButton({
    super.key,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox.fromSize(
      size: layout.button.secondaryActionButtonSize,
      child: SecondaryActionButtonDark(
        onPressed: onTap,
        child: const Icon(AbiliaIcons.handiInfo),
      ),
    );
  }
}
