import 'package:flutter/material.dart';

import 'package:seagull/ui/colors.dart';
import 'package:seagull/ui/components/abilia_icons.dart';
import 'package:seagull/ui/components/all.dart';
import 'package:seagull/ui/theme.dart';
import 'package:seagull/utils/all.dart';

/// copied from [showDialog]
Future<T> showViewDialog<T>({
  @required BuildContext context,
  @required WidgetBuilder builder,
  bool barrierDismissible = true,
  bool useRootNavigator = true,
}) {
  assert(builder != null);
  assert(useRootNavigator != null);
  assert(debugCheckHasMaterialLocalizations(context));

  final theme = Theme.of(context, shadowThemeOnly: true);
  return showGeneralDialog(
    context: context,
    pageBuilder: (BuildContext buildContext, Animation<double> animation,
        Animation<double> secondaryAnimation) {
      final Widget pageChild = Builder(builder: builder);
      return SafeArea(
        bottom: false,
        child: Builder(builder: (BuildContext context) {
          return theme != null
              ? Theme(data: theme, child: pageChild)
              : pageChild;
        }),
      );
    },
    barrierDismissible: barrierDismissible,
    barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
    barrierColor: AbiliaColors.transparentBlack90,
    transitionDuration: const Duration(milliseconds: 150),
    transitionBuilder: _buildMaterialDialogTransitions,
    useRootNavigator: useRootNavigator,
  );
}

Widget _buildMaterialDialogTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child) {
  return FadeTransition(
    opacity: CurvedAnimation(
      parent: animation,
      curve: Curves.easeOut,
    ),
    child: child,
  );
}

class ViewDialog extends StatelessWidget {
  final Widget heading;
  final Widget child;
  final Widget trailing;
  final GestureTapCallback onOk;
  final Widget deleteButton;
  final Widget backButton;
  final bool expanded;
  final IconData closeIcon;
  final double _verticalPadding;
  static const double verticalPadding = 24.0;

  const ViewDialog({
    Key key,
    @required this.child,
    this.heading,
    this.onOk,
    this.deleteButton,
    this.backButton,
    this.expanded = false,
    this.trailing,
    this.closeIcon = AbiliaIcons.close_program,
    double verticalPadding = verticalPadding,
  })  : _verticalPadding = verticalPadding,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    final hasOk = onOk != null;
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        const SizedBox(height: 8),
        Container(
          // This container is only to prevent closing of the dialog when clicking just outside the buttons.
          decoration: BoxDecoration(
            color: Colors.transparent,
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12.0, 0, 12.0, 8.0),
            child: Stack(
              children: <Widget>[
                if (deleteButton != null) deleteButton,
                Align(
                  alignment: Alignment.centerRight,
                  child: RoundFloatingButton(
                    AbiliaIcons.ok,
                    key: TestKey.okDialog,
                    color: AbiliaColors.green,
                    onTap: onOk,
                  ),
                ),
                AnimatedAlign(
                  duration: 200.milliseconds(),
                  alignment:
                      hasOk ? Alignment(0.6, 1.0) : Alignment.centerRight,
                  child: RoundFloatingButton(
                    closeIcon,
                    key: TestKey.closeDialog,
                    onTap: Navigator.of(context).maybePop,
                  ),
                ),
              ],
            ),
          ),
        ),
        Flexible(
          flex: expanded ? 1 : 0,
          child: Container(
            decoration: const BoxDecoration(
              color: AbiliaColors.white110,
              borderRadius: BorderRadius.vertical(top: radius),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    if (backButton != null)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(12.0, 0, 0, 0),
                        child: backButton,
                      ),
                    if (heading != null)
                      Padding(
                        padding:
                            const EdgeInsets.fromLTRB(12.0, 20.0, 16.0, 16.0),
                        child: heading,
                      ),
                  ],
                ),
                const Divider(
                  color: AbiliaColors.transparentBlack10,
                  endIndent: 12.0,
                  height: 0,
                ),
                Flexible(
                  flex: expanded ? 1 : 0,
                  child: Padding(
                    padding:
                        EdgeInsets.fromLTRB(12.0, _verticalPadding, 16.0, 0.0),
                    child: Material(
                      color: Colors.transparent,
                      child: child,
                    ),
                  ),
                ),
                if (trailing != null)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      const SizedBox(height: 16.0),
                      const Divider(
                        color: AbiliaColors.transparentBlack10,
                        endIndent: 12.0,
                        height: 0,
                      ),
                      Flexible(
                        flex: expanded ? 1 : 0,
                        child: Padding(
                          padding:
                              const EdgeInsets.fromLTRB(12.0, 16.0, 16.0, 0.0),
                          child: Material(
                            child: trailing,
                            color: Colors.transparent,
                          ),
                        ),
                      ),
                    ],
                  ),
                SizedBox(height: _verticalPadding),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class RoundFloatingButton extends StatelessWidget {
  final IconData iconData;
  final GestureTapCallback onTap;
  final MaterialColor color;
  const RoundFloatingButton(
    this.iconData, {
    @required this.onTap,
    Key key,
    this.color = AbiliaColors.white,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        key: ObjectKey(key),
        borderRadius: BorderRadius.all(Radius.circular(28.0)),
        onTap: onTap,
        child: Ink(
          width: 40.0,
          height: 40.0,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: Border.all(
              color: color[120],
            ),
          ),
          child: Icon(
            iconData,
            color: AbiliaColors.black,
            size: 24,
          ),
        ),
      ),
    );
  }
}
