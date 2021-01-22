import 'package:flutter/material.dart';
import 'package:seagull/ui/all.dart';

import 'all.dart';

class PreviousButton extends StatelessWidget {
  const PreviousButton({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GreyButton(
      text: Translator.of(context).translate.back,
      icon: AbiliaIcons.navigation_previous,
      onPressed: Navigator.of(context).maybePop,
    );
  }
}
