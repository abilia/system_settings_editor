import 'package:flutter/material.dart';
import 'package:seagull/bloc/all.dart';

import 'package:seagull/ui/all.dart';

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
