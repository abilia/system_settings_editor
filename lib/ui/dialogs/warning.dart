import 'package:flutter/material.dart';
import 'package:seagull/ui/all.dart';

class WarningDialog extends StatelessWidget {
  final Widget icon;
  final String heading;
  final Widget text;
  final GestureTapCallback onOk;

  const WarningDialog({
    Key key,
    this.icon,
    this.heading,
    this.text,
    this.onOk,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return ViewDialog(
      verticalPadding: 0.0,
      leftPadding: 32.0,
      rightPadding: 32.0,
      onOk: onOk,
      child: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(flex: 128),
          icon,
          const Spacer(flex: 80),
          Tts(
            child: Text(
              heading,
              style: Theme.of(context).textTheme.headline6,
            ),
          ),
          const SizedBox(height: 8.0),
          text,
          const Spacer(flex: 199),
        ],
      ),
    );
  }
}
