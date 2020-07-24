import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:seagull/ui/colors.dart';
import 'package:seagull/ui/components/all.dart';
import 'package:seagull/ui/theme.dart';

class AbiliaAppBar extends StatelessWidget implements PreferredSizeWidget {
  final double height;
  final String title;
  final Widget trailing;
  final Function onClosedPressed;
  final IconData closeIcon;
  final PreferredSizeWidget bottom;

  const AbiliaAppBar({
    Key key,
    @required this.title,
    this.height = 68.0,
    this.trailing,
    this.onClosedPressed,
    this.closeIcon = AbiliaIcons.close_program,
    this.bottom,
  }) : super(key: key);

  @override
  Size get preferredSize =>
      Size.fromHeight(height + (bottom?.preferredSize?.height ?? 0.0));
  @override
  Widget build(BuildContext context) {
    Widget wrappedWidget = Stack(
      children: <Widget>[
        Align(
          alignment: Alignment.centerLeft,
          child: ActionButton(
            key: TestKey.appBarCloseButton,
            child: Icon(
              closeIcon,
              size: 32,
            ),
            onPressed:
                onClosedPressed ?? () => Navigator.of(context).maybePop(),
          ),
        ),
        Center(
          child: Text(
            title,
            style: Theme.of(context)
                .textTheme
                .headline6
                .copyWith(color: AbiliaColors.white),
          ),
        ),
        if (trailing != null)
          Align(
            alignment: Alignment.centerRight,
            child: trailing,
          ),
      ],
    );

    if (bottom != null) {
      wrappedWidget = Column(
        children: <Widget>[
          wrappedWidget,
          SizedBox(
            height: 14.0,
          ),
          bottom,
        ],
      );
    }

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Theme(
        data: lightButtonTheme,
        child: Container(
          decoration: BoxDecoration(color: Theme.of(context).appBarTheme.color),
          child: SafeArea(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: wrappedWidget,
            ),
          ),
        ),
      ),
    );
  }
}
