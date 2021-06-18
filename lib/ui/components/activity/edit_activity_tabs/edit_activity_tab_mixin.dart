// @dart=2.9

import 'package:flutter/widgets.dart';

import 'package:seagull/ui/all.dart';

mixin EditActivityTab {
  static final rightPadding = EdgeInsets.only(right: 12.0.s),
      ordinaryPadding = EdgeInsets.fromLTRB(12.0.s, 24.0.s, 4.0.s, 16.0.s),
      errorBorderPadding = EdgeInsets.all(4.0.s),
      errorBorderPaddingRight = EdgeInsets.only(right: 5.0.s),
      bottomPadding = EdgeInsets.only(bottom: 56.0.s);
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

  Widget separatedAndPadded(Widget child) => Separated(child: padded(child));

  Widget padded(Widget child) =>
      Padding(padding: ordinaryPadding, child: child);
}

class Separated extends StatelessWidget {
  final Widget child;

  const Separated({Key key, this.child}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AbiliaColors.white120, width: 1.0.s),
        ),
      ),
      child: child,
    );
  }
}
