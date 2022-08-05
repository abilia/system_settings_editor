import 'package:flutter/cupertino.dart';
import 'package:seagull/i18n/app_localizations.dart';
import 'package:seagull/ui/components/abilia_icons.dart';
import 'package:seagull/ui/components/buttons/icon_action_button.dart';

class LeftNavButton extends StatelessWidget {
  const LeftNavButton({
    required this.onPressed,
    Key? key,
  }) : super(key: key);

  final Function() onPressed;
  @override
  Widget build(BuildContext context) => IconActionButton(
        onPressed: onPressed,
        child: const Icon(AbiliaIcons.returnToPreviousPage),
        ttsData: Translator.of(context).translate.back,
      );
}

class RightNavButton extends StatelessWidget {
  const RightNavButton({
    required this.onPressed,
    Key? key,
  }) : super(key: key);

  final Function() onPressed;
  @override
  Widget build(BuildContext context) => IconActionButton(
        onPressed: onPressed,
        child: const Icon(AbiliaIcons.goToNextPage),
        ttsData: Translator.of(context).translate.next,
      );
}
