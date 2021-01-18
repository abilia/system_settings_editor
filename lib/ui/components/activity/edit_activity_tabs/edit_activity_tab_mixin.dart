import 'package:flutter/widgets.dart';

import 'package:seagull/ui/all.dart';

mixin EditActivityTab {
  static const rightPadding = EdgeInsets.only(right: 12.0),
      ordinaryPadding = EdgeInsets.fromLTRB(12.0, 24.0, 4.0, 16.0),
      errorBorderPadding = EdgeInsets.all(4.0),
      errorBorderPaddingRight = EdgeInsets.only(right: 5.0),
      bottomPadding = EdgeInsets.only(bottom: 56.0);
  Widget errorBordered(Widget child, {@required bool errorState}) {
    final decoration = errorState ? errorBoxDecoration : const BoxDecoration();
    return Container(
      decoration: decoration,
      child: ClipRRect(
        borderRadius: borderRadius,
        child: Padding(
          padding: errorBorderPadding
              .subtract(decoration.border?.dimensions ?? EdgeInsets.zero),
          child: child,
        ),
      ),
    );
  }

  Widget separatedAndPadded(Widget child) => separated(padded(child));

  Widget separated(Widget child) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AbiliaColors.white120),
        ),
      ),
      child: child,
    );
  }

  Widget padded(Widget child) =>
      Padding(padding: ordinaryPadding, child: child);
}
