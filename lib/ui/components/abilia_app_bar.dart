import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:seagull/ui/all.dart';

class NewAbiliaAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final IconData iconData;
  final PreferredSizeWidget bottom;

  @override
  final Size preferredSize;

  NewAbiliaAppBar({
    Key key,
    @required this.title,
    @required this.iconData,
    this.bottom,
  })  : preferredSize =
            Size.fromHeight(68.0 + (bottom?.preferredSize?.height ?? 0.0)),
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
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: bottom,
          ),
        ],
      );
    } else {
      content = Center(child: content);
    }

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Theme(
        data: lightButtonTheme,
        child: Container(
          decoration: BoxDecoration(color: Theme.of(context).appBarTheme.color),
          child: SafeArea(
            child: content,
          ),
        ),
      ),
    );
  }
}

class AbiliaAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final IconData icon;
  final IconData closeIcon;
  final bool closeButton;

  const AbiliaAppBar({
    Key key,
    @required this.title,
    this.closeIcon = AbiliaIcons.close_program,
    this.closeButton = true,
    this.icon,
  }) : super(key: key);

  @override
  Size get preferredSize => Size.fromHeight(68.0);
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
                            onPressed: () => _pop(context),
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
                    ],
                  ),
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
