import 'package:flutter/material.dart';
import 'package:seagull/ui/all.dart';

class CancelButton extends StatelessWidget {
  final VoidCallback onPressed;

  const CancelButton({
    Key key,
    this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final translate = Translator.of(context).translate;
    final text = translate.cancel;
    return IconAndTextButton(
      key: TestKey.cancelButton,
      text: text,
      icon: AbiliaIcons.close_program,
      onPressed: onPressed,
      theme: greyButtonTheme,
    );
  }
}

class OkButton extends StatelessWidget {
  final VoidCallback onPressed;

  const OkButton({
    Key key,
    this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final translate = Translator.of(context).translate;
    final text = translate.ok;
    return IconAndTextButton(
      key: TestKey.okDialog,
      text: text,
      icon: AbiliaIcons.ok,
      onPressed: onPressed,
      theme: greenButtonTheme,
    );
  }
}
