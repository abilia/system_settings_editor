import 'package:flutter/material.dart';
import 'package:seagull/ui/all.dart';

class NoButton extends StatelessWidget {
  final VoidCallback onPressed;

  const NoButton({
    Key key,
    this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final translate = Translator.of(context).translate;
    final text = translate.no;
    return IconAndTextButton(
      text: text,
      icon: AbiliaIcons.close_program,
      onPressed: onPressed,
      theme: greyButtonTheme,
    );
  }
}

class YesButton extends StatelessWidget {
  final VoidCallback onPressed;

  const YesButton({
    Key key,
    this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final translate = Translator.of(context).translate;
    final text = translate.yes;
    return IconAndTextButton(
      text: text,
      icon: AbiliaIcons.ok,
      onPressed: onPressed,
      theme: greenButtonTheme,
    );
  }
}
