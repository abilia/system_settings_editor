import 'package:flutter/material.dart';

import 'package:seagull/ui/colors.dart';
import 'package:seagull/ui/components/abilia_icons.dart';
import 'package:seagull/ui/components/all.dart';
import 'package:seagull/ui/theme.dart';
import 'package:seagull/utils/all.dart';

/// copied from [showDialog]
Future<T> showViewDialog<T>({
  @required BuildContext context,
  bool barrierDismissible = true,
  WidgetBuilder builder,
  bool useRootNavigator = true,
}) {
  assert(builder != null);
  assert(useRootNavigator != null);
  assert(debugCheckHasMaterialLocalizations(context));

  final ThemeData theme = Theme.of(context, shadowThemeOnly: true);
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
    barrierColor: AbiliaColors.transparantBlack[90],
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

  const ViewDialog({
    Key key,
    @required this.child,
    this.heading,
    this.onOk,
    this.deleteButton,
    this.backButton,
    this.expanded = false,
    this.trailing,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final hasOk = onOk != null;
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        const SizedBox(height: 24),
        Padding(
          padding: const EdgeInsets.fromLTRB(12.0, 0, 12.0, 8.0),
          child: Stack(
            children: <Widget>[
              if (deleteButton != null) deleteButton,
              Align(
                alignment: Alignment.centerRight,
                child: RoundFloatingButton(
                  AbiliaIcons.ok,
                  key: TestKey.okDialog,
                  onTap: onOk,
                ),
              ),
              AnimatedAlign(
                duration: 200.milliseconds(),
                alignment: hasOk ? Alignment(0.6, 1.0) : Alignment.centerRight,
                child: RoundFloatingButton(
                  AbiliaIcons.close_program,
                  key: TestKey.closeDialog,
                  onTap: Navigator.of(context).maybePop,
                ),
              ),
            ],
          ),
        ),
        Flexible(
          flex: expanded ? 1 : 0,
          child: Container(
            decoration: BoxDecoration(
              color: AbiliaColors.white[110],
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(12.0)),
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
                Divider(
                  color: AbiliaColors.transparantBlack[10],
                  endIndent: 12.0,
                  height: 0,
                ),
                Flexible(
                  flex: expanded ? 1 : 0,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(12.0, 24.0, 16.0, 0.0),
                    child: child,
                  ),
                ),
                if (trailing == null)
                  const SizedBox(height: 24.0)
                else
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      const SizedBox(height: 16.0),
                      Divider(
                        color: AbiliaColors.transparantBlack[10],
                        endIndent: 12.0,
                        height: 0,
                      ),
                      Flexible(
                        flex: expanded ? 1 : 0,
                        child: Padding(
                          padding:
                              const EdgeInsets.fromLTRB(12.0, 16.0, 16.0, 24.0),
                          child: Material(
                            child: trailing,
                            color: Colors.transparent,
                          ),
                        ),
                      ),
                    ],
                  )
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
  const RoundFloatingButton(
    this.iconData, {
    @required this.onTap,
    Key key,
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
      ),
    );
  }
}

class DeleteFloatingButton extends StatelessWidget {
  final GestureTapCallback onDelete;
  final String text;
  const DeleteFloatingButton({
    @required this.onDelete,
    Key key,
    @required this.text,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: borderRadius,
        onTap: onDelete,
        child: Ink(
          height: 36.0,
          padding: EdgeInsets.only(left: 8.0, right: 10.0),
          decoration: BoxDecoration(
            color: AbiliaColors.red.withAlpha(0xCC),
            borderRadius: borderRadius,
            border: Border.all(
              color: AbiliaColors.red,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(
                AbiliaIcons.delete_all_clear,
                color: AbiliaColors.white,
                size: 24,
              ),
              SizedBox(
                width: 4.0,
              ),
              Text(
                text,
                style: Theme.of(context)
                    .textTheme
                    .body2
                    .copyWith(color: AbiliaColors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
