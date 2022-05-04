import 'package:seagull/ui/all.dart';
import 'package:seagull/utils/all.dart';

class CollapsableWidget extends StatelessWidget {
  final Widget child;
  final bool collapsed;
  final EdgeInsets padding;
  final AlignmentGeometry alignment;
  final Axis axis;

  const CollapsableWidget({
    Key? key,
    required this.child,
    required this.collapsed,
    this.padding = EdgeInsets.zero,
    this.alignment = Alignment.topLeft,
    this.axis = Axis.vertical,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final begin = collapsed ? 0.0 : 1.0;
    final verical = axis == Axis.vertical;
    return TweenAnimationBuilder(
      duration: 300.milliseconds(),
      tween: Tween<double>(begin: begin, end: begin),
      builder: (context, double value, widget) => ClipRect(
        child: Align(
          alignment: alignment,
          heightFactor: verical ? value : null,
          widthFactor: verical ? null : value,
          child: value > 0.0
              ? Padding(
                  padding: padding,
                  child: AbsorbPointer(
                    absorbing: collapsed,
                    child: widget,
                  ),
                )
              : Container(),
        ),
      ),
      child: child,
    );
  }
}
