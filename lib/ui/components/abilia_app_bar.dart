import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:seagull/ui/colors.dart';
import 'package:seagull/ui/components/all.dart';

class AbiliaAppBar extends StatelessWidget implements PreferredSizeWidget {
  final double height;
  final String title;
  final bool hasClose;
  const AbiliaAppBar(
      {Key key,
      @required this.title,
      this.height = 68.0,
      this.hasClose = false})
      : super(key: key);
  @override
  Size get preferredSize => Size.fromHeight(height);
  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Container(
        decoration: BoxDecoration(color: Theme.of(context).appBarTheme.color),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
            child: Stack(
              children: <Widget>[
                if (hasClose)
                  Align(
                    alignment: Alignment.centerLeft,
                    child: AbiliaCloseButton(),
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}

