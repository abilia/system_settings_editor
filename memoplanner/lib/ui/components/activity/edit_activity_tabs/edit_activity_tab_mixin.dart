import 'package:seagull/ui/all.dart';

mixin EditActivityTab {
  Widget errorBordered(Widget child, {required bool errorState}) {
    final decoration = errorState ? errorBoxDecoration : const BoxDecoration();
    return Container(
      decoration: decoration,
      child: ClipRRect(
        borderRadius: borderRadius,
        child: Padding(
          padding: errorState
              ? layout.templates.s3
                  .subtract(decoration.border?.dimensions ?? EdgeInsets.zero)
              : EdgeInsets.zero,
          child: child,
        ),
      ),
    );
  }
}
