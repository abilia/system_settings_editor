import 'package:dotted_border/dotted_border.dart';
import 'package:memoplanner/ui/all.dart';

class LinedBorder extends StatelessWidget {
  final Widget child;
  final GestureTapCallback? onTap;
  final bool errorState;
  const LinedBorder({
    required this.child,
    this.onTap,
    this.errorState = false,
    Key? key,
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
                padding: const EdgeInsets.all(0),
                child: child,
              ),
      ),
    );
  }
}
