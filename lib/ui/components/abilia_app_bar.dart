import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:seagull/ui/colors.dart';
import 'package:seagull/ui/components/all.dart';
import 'package:seagull/ui/theme.dart';

class AbiliaAppBar extends StatelessWidget implements PreferredSizeWidget {
  final double height;
  final String title;
  final Widget trailing;
  const AbiliaAppBar({
    Key key,
    @required this.title,
    this.height = 68.0,
    this.trailing,
  }) : super(key: key);
  @override
  Size get preferredSize => Size.fromHeight(height);
  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Theme(
        data: lightButtonTheme,
        child: Container(
          decoration: BoxDecoration(color: Theme.of(context).appBarTheme.color),
          child: SafeArea(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
              child: Stack(
                children: <Widget>[
                  Align(
                    alignment: Alignment.centerLeft,
                    child: ActionButton(
                      key: TestKey.appBarCloseButton,
                      child: Icon(
                        AbiliaIcons.close_program,
                        size: 32,
                      ),
                      onPressed: () => Navigator.of(context).maybePop(),
                    ),
                  ),
                  Center(
                    child: Text(
                      title,
                      style: Theme.of(context)
                          .textTheme
                          .title
                          .copyWith(color: AbiliaColors.white),
                    ),
                  ),
                  if (trailing != null)
                    Align(
                      alignment: Alignment.centerRight,
                      child: trailing,
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
