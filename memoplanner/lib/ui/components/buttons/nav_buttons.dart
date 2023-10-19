import 'package:memoplanner/ui/all.dart';

class LeftNavButton extends StatelessWidget {
  const LeftNavButton({
    required this.onPressed,
    super.key,
  });

  final Function() onPressed;
  @override
  Widget build(BuildContext context) => IconActionButton(
        onPressed: onPressed,
        ttsData: Lt.of(context).previous,
        child: const Icon(AbiliaIcons.returnToPreviousPage),
      );
}

class RightNavButton extends StatelessWidget {
  const RightNavButton({
    required this.onPressed,
    super.key,
  });

  final Function() onPressed;
  @override
  Widget build(BuildContext context) => IconActionButton(
        onPressed: onPressed,
        ttsData: Lt.of(context).next,
        child: const Icon(AbiliaIcons.goToNextPage),
      );
}
