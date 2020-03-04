import 'package:flutter/material.dart';

import 'package:seagull/ui/colors.dart';
import 'package:seagull/ui/components/abilia_icons.dart';
import 'package:seagull/ui/components/all.dart';

class ViewDialog extends StatelessWidget {
  final Widget heading;
  final Widget child;
  final GestureTapCallback onOk;
  final fullScreen;

  const ViewDialog({
    Key key,
    @required this.child,
    @required this.heading,
    this.onOk,
    this.fullScreen = false,
  }) : super(key: key);

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
    var bottomContent = Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AbiliaColors.white[110],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12.0, 24.0, 16.0, 24.0),
        child: Material(
          child: child,
          color: Colors.transparent,
        ),
      ),
    );
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
                  RoundFloatingButton(AbiliaIcons.close_program, onTap: () {
                    Navigator.of(context).maybePop();
                  }, key: TestKey.closeDialog),
                  if (onOk != null)
                    Padding(
                      padding: const EdgeInsets.only(left: 24.0),
                      child: RoundFloatingButton(
                        AbiliaIcons.ok,
                        onTap: () {
                          onOk();
                          Navigator.of(context).maybePop();
                        },
                      ),
                    ),
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
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 20.0, 16.0, 16.0),
            child: heading,
          ),
        ),
        Container(
          width: double.infinity,
          child: Divider(
            color: AbiliaColors.transparantBlack[10],
            endIndent: 12.0,
            height: 0,
          ),
        ),
        fullScreen
            ? Expanded(
                child: bottomContent,
              )
            : bottomContent,
      ],
    );
  }
}

class RoundFloatingButton extends StatelessWidget {
  final IconData iconData;
  final GestureTapCallback onTap;
  const RoundFloatingButton(
    this.iconData, {
    @required this.onTap,
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.all(Radius.circular(28.0)),
      onTap: onTap,
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
