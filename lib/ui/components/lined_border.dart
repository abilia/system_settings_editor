import 'package:dotted_border/dotted_border.dart';

import 'package:seagull/ui/all.dart';

class LinedBorder extends StatelessWidget {
  final Widget child;
  final GestureTapCallback? onTap;
  final EdgeInsets padding;
  final bool errorState;
  const LinedBorder({
    Key? key,
    required this.child,
    required this.padding,
    this.onTap,
    this.errorState = false,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: borderRadius,
      onTap: onTap,
      child: ClipRRect(
        borderRadius: borderRadius,
        child: errorState
            ? Container(
                decoration: errorBoxDecoration,
                padding: padding,
                child: child,
              )
            : DottedBorder(
                dashPattern: [
                  layout.linedBorder.dashSize,
                  layout.linedBorder.dashSize
                ],
                strokeWidth: layout.borders.thin,
                borderType: BorderType.RRect,
                color: AbiliaColors.white140,
                radius: radius,
                padding: padding,
                child: child,
              ),
      ),
    );
  }
}
