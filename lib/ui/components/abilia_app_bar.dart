import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:seagull/ui/all.dart';

class NewAbiliaAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final IconData iconData;

  const NewAbiliaAppBar({
    Key key,
    @required this.title,
    @required this.iconData,
  }) : super(key: key);

  @override
  Size get preferredSize => const Size.fromHeight(68.0);

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Theme(
        data: lightButtonTheme,
        child: Container(
          decoration: BoxDecoration(color: Theme.of(context).appBarTheme.color),
          child: SafeArea(
            child: Center(
              child: AppBarHeading(
                text: title,
                iconData: iconData,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class AbiliaAppBar extends StatelessWidget implements PreferredSizeWidget {
  final double height;
  final String title;
  final IconData icon;
  final Widget trailing;
  final Function onClosedPressed;
  final IconData closeIcon;
  final PreferredSizeWidget bottom;
  final bool closeButton;

  const AbiliaAppBar({
    Key key,
    @required this.title,
    this.height = 68.0,
    this.trailing,
    this.onClosedPressed,
    this.closeIcon = AbiliaIcons.close_program,
    this.bottom,
    this.closeButton = true,
    this.icon,
  }) : super(key: key);

  @override
  Size get preferredSize =>
      Size.fromHeight(height + (bottom?.preferredSize?.height ?? 0.0));
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
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Stack(
                    alignment: Alignment.center,
                    children: <Widget>[
                      if (closeButton)
                        Align(
                          alignment: Alignment.centerLeft,
                          child: ActionButton(
                            key: TestKey.appBarCloseButton,
                            child: Icon(closeIcon),
                            onPressed: onClosedPressed ?? () => _pop(context),
                          ),
                        ),
                      if (title != null)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (icon != null) ...[
                              IconTheme(
                                  data: Theme.of(context)
                                      .iconTheme
                                      .copyWith(color: AbiliaColors.white),
                                  child: Icon(icon)),
                              const SizedBox(width: 8),
                            ],
                            Tts(
                              child: Text(
                                title,
                                style: Theme.of(context)
                                    .textTheme
                                    .headline6
                                    .copyWith(color: AbiliaColors.white),
                              ),
                            ),
                          ],
                        ),
                      if (trailing != null)
                        Align(
                          alignment: Alignment.centerRight,
                          child: trailing,
                        ),
                    ],
                  ),
                  if (bottom != null) bottom,
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future _pop(BuildContext context) async {
    if (!await Navigator.of(context).maybePop()) {
      await SystemNavigator.pop();
    }
  }
}
