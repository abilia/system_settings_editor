import 'package:flutter/material.dart';

import 'package:seagull/ui/colors.dart';
import 'package:seagull/ui/components/abilia_icons.dart';
import 'package:seagull/ui/components/all.dart';

class ViewDialog extends StatelessWidget {
  final Widget heading;
  final Widget child;
  final GestureTapCallback onOk;

  const ViewDialog({Key key, @required this.child, this.heading, this.onOk})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomLeft,
      child: Material(
        color: Colors.transparent,
        child: dialogContent(context),
      ),
    );
  }

  Widget dialogContent(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.fromLTRB(12.0, 24.0, 12.0, 8.0),
          child: Stack(
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  if (onOk != null) RoundFloatingButton(AbiliaIcons.ok),
                  RoundFloatingButton(AbiliaIcons.close_program,
                      key: TestKey.closeDialog),
                ],
              ),
            ],
          ),
        ),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: AbiliaColors.white[110],
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(12.0)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              if (heading != null)
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 20.0, 16.0, 16.0),
                  child: heading,
                ),
              Divider(
                color: AbiliaColors.transparantBlack[10],
                endIndent: 12.0,
                height: 0,
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(12.0, 24.0, 16.0, 24.0),
                child: Material(
                  child: child,
                  color: Colors.transparent,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class RoundFloatingButton extends StatelessWidget {
  final IconData iconData;
  const RoundFloatingButton(
    this.iconData, {
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.all(Radius.circular(28.0)),
      onTap: Navigator.of(context).maybePop,
      child: Ink(
        width: 40.0,
        height: 40.0,
        decoration: BoxDecoration(
          color: AbiliaColors.white,
          shape: BoxShape.circle,
          border: Border.all(
            color: AbiliaColors.transparantBlack[15],
          ),
        ),
        child: Icon(
          iconData,
          color: AbiliaColors.black,
          size: 24,
        ),
      ),
    );
  }
}
