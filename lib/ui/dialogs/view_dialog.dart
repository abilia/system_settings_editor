import 'package:flutter/material.dart';
import 'package:seagull/bloc/all.dart';

import 'package:seagull/ui/all.dart';
import 'package:seagull/utils/all.dart';

/// copied from [showDialog]
Future<T> showViewDialog<T>({
  @required BuildContext context,
  @required WidgetBuilder builder,
  bool barrierDismissible = true,
  Color barrierColor = AbiliaColors.transparentBlack90,
  bool useSafeArea = true,
  bool useRootNavigator = true,
  bool wrapWithAuthProviders = true,
  RouteSettings routeSettings,
  RouteTransitionsBuilder transitionBuilder = buildMaterialDialogTransitions,
}) {
  assert(builder != null);
  assert(barrierDismissible != null);
  assert(useSafeArea != null);
  assert(useRootNavigator != null);
  assert(debugCheckHasMaterialLocalizations(context));

  final theme = Theme.of(context, shadowThemeOnly: true);
  return showGeneralDialog(
    context: context,
    pageBuilder: (
      BuildContext buildContext,
      Animation<double> animation,
      Animation<double> secondaryAnimation,
    ) {
      final Widget pageChild = Builder(builder: builder);
      Widget dialog = Builder(builder: (BuildContext context) {
        return theme != null ? Theme(data: theme, child: pageChild) : pageChild;
      });
      if (useSafeArea) {
        dialog = SafeArea(child: dialog);
      }
      if (wrapWithAuthProviders) {
        dialog = CopiedAuthProviders(blocContext: context, child: dialog);
      }
      return dialog;
    },
    barrierDismissible: barrierDismissible,
    barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
    barrierColor: barrierColor,
    transitionDuration: const Duration(milliseconds: 150),
    transitionBuilder: transitionBuilder,
    useRootNavigator: useRootNavigator,
    routeSettings: routeSettings,
  );
}

Future showErrorViewDialog(String text, {@required BuildContext context}) {
  return showViewDialog(
    context: context,
    builder: (context) => Column(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        Expanded(
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTapDown: Navigator.of(context).pop,
          ),
        ),
        GestureDetector(
          key: TestKey.errorViewDialog,
          onTap: Navigator.of(context).pop,
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: ErrorMessage(
              text: Text(text),
            ),
          ),
        ),
      ],
    ),
    barrierColor: const Color(0x01000000),
    transitionBuilder: buildSlideDialogTransitions,
  );
}

Widget buildMaterialDialogTransitions(
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

Widget buildSlideDialogTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child) {
  return SlideTransition(
    position: Tween<Offset>(begin: const Offset(0.0, 0.5), end: Offset.zero)
        .animate(CurvedAnimation(
      parent: animation,
      curve: Curves.easeOutQuad,
    )),
    child: FadeTransition(
      opacity: CurvedAnimation(
        parent: animation,
        curve: Curves.easeOut,
      ),
      child: child,
    ),
  );
}

class ViewDialog extends StatelessWidget {
  final Text heading;
  final Widget child;
  final Color backgroundColor;
  final GestureTapCallback onOk;
  final GestureTapCallback onCancle;

  static const divider = Divider(
    color: AbiliaColors.white120,
    endIndent: leftPadding,
    height: 0,
  );
  static const double verticalPadding = 24.0,
      leftPadding = 12.0,
      rightPadding = 16.0,
      seperatorPadding = 16.0;
  final Widget deleteButton;
  final Widget backButton;
  final Widget preview;
  final bool expanded;
  final double _verticalPadding, _leftPadding, _rightPadding;

  const ViewDialog({
    Key key,
    @required this.child,
    this.heading,
    this.onOk,
    this.onCancle,
    this.deleteButton,
    this.backButton,
    this.expanded = true,
    this.backgroundColor = AbiliaColors.white110,
    double verticalPadding = verticalPadding,
    double leftPadding = leftPadding,
    double rightPadding = rightPadding,
    this.preview,
  })  : _verticalPadding = verticalPadding,
        _leftPadding = leftPadding,
        _rightPadding = rightPadding,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: MediaQuery.of(context).viewInsets,
      child: Material(
        type: MaterialType.transparency,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            const SizedBox(height: 8),
            _TopFloatingButtons(
              deleteButton: deleteButton,
              onOk: onOk,
              onCancle: onCancle,
            ),
            if (preview != null) preview,
            Flexible(
              flex: expanded ? 1 : 0,
              child: Container(
                decoration: BoxDecoration(
                  color: backgroundColor,
                  borderRadius: BorderRadius.vertical(top: radius),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    if (backButton != null || heading != null)
                      Row(
                        children: <Widget>[
                          if (backButton != null)
                            Padding(
                              padding: EdgeInsets.only(left: leftPadding),
                              child: backButton,
                            ),
                          if (heading != null)
                            Padding(
                              padding: EdgeInsets.fromLTRB(
                                leftPadding,
                                20.0,
                                rightPadding,
                                seperatorPadding,
                              ),
                              child: Tts(child: heading),
                            ),
                        ],
                      ),
                    if (backButton != null || heading != null) divider,
                    Flexible(
                      flex: expanded ? 1 : 0,
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(
                          _leftPadding,
                          _verticalPadding,
                          _rightPadding,
                          _verticalPadding,
                        ),
                        child: child,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TopFloatingButtons extends StatelessWidget {
  const _TopFloatingButtons({
    Key key,
    @required this.deleteButton,
    @required this.onOk,
    this.onCancle,
  }) : super(key: key);

  final Widget deleteButton;
  final GestureTapCallback onOk;
  final GestureTapCallback onCancle;

  @override
  Widget build(BuildContext context) {
    final hasOk = onOk != null;

    return Container(
      // This container is only to prevent closing of the dialog when clicking just outside the buttons.
      decoration: BoxDecoration(
        color: Colors.transparent,
      ),
      padding: const EdgeInsets.fromLTRB(0.0, 0, 12.0, 8.0),
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
            alignment: hasOk ? Alignment(0.6, 1.0) : Alignment.centerRight,
            child: RoundFloatingButton(
              AbiliaIcons.close_program,
              key: TestKey.closeDialog,
              onTap: onCancle ?? Navigator.of(context).maybePop,
            ),
          ),
        ],
      ),
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
      type: MaterialType.button,
      color: color,
      borderRadius: BorderRadius.all(Radius.circular(28.0)),
      child: InkWell(
        key: ObjectKey(key),
        borderRadius: BorderRadius.all(Radius.circular(28.0)),
        onTap: onTap,
        child: Ink(
          width: 40.0,
          height: 40.0,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: color[140],
            ),
          ),
          child: Icon(
            iconData,
            color: AbiliaColors.black,
            size: smallIconSize,
          ),
        ),
      ),
    );
  }
}
