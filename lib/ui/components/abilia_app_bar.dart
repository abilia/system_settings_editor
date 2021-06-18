// @dart=2.9

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:seagull/ui/all.dart';

class AbiliaAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final IconData iconData;
  final Widget trailing;
  final PreferredSizeWidget bottom;

  @override
  final Size preferredSize;

  AbiliaAppBar({
    Key key,
    @required this.title,
    @required this.iconData,
    this.bottom,
    this.trailing,
  })  : preferredSize =
            Size.fromHeight(68.0.s + (bottom?.preferredSize?.height ?? 0.0)),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    Widget content = AppBarHeading(
      text: title,
      iconData: iconData,
    );
    if (bottom != null) {
      content = Column(
        children: [
          Expanded(child: content),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 8.0.s),
            child: bottom,
          ),
        ],
      );
    } else {
      content = Center(child: content);
    }
    if (trailing != null) {
      content = Stack(
        children: [
          content,
          Align(
            alignment: Alignment.centerRight,
            child: trailing,
          )
        ],
      );
    }

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Container(
        decoration: BoxDecoration(color: Theme.of(context).appBarTheme.color),
        child: SafeArea(
          child: content,
        ),
      ),
    );
  }
}
