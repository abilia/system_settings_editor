import 'package:flutter/material.dart';
import 'package:seagull/bloc/all.dart';

import 'package:seagull/ui/all.dart';

/// copied from [showDialog]
Future<T> showViewDialog<T>({
  @required BuildContext context,
  @required WidgetBuilder builder,
  Color barrierColor = AbiliaColors.transparentBlack90,
  bool useSafeArea = true,
  bool wrapWithAuthProviders = true,
}) {
  assert(builder != null);
  assert(useSafeArea != null);

  return showDialog(
    context: context,
    builder: wrapWithAuthProviders
        ? (_) => CopiedAuthProviders(
              blocContext: context,
              child: Builder(builder: builder),
            )
        : builder,
    useSafeArea: useSafeArea,
    barrierColor: barrierColor,
  );
}
