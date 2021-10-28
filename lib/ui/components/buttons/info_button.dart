import 'package:seagull/ui/all.dart';

class InfoButton extends StatelessWidget {
  final VoidCallback? onTap;

  const InfoButton({
    Key? key,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SecondaryActionButtonDark(
      onPressed: onTap,
      child: const Icon(AbiliaIcons.handiInfo),
    );
  }
}
