import 'package:memoplanner/ui/all.dart';

class SelectableField extends StatelessWidget {
  final Text text;
  final double? height, width;
  final Color? color;
  final bool selected;
  final GestureTapCallback onTap;
  final String? ttsData;

  const SelectableField({
    required this.selected,
    required this.onTap,
    required this.text,
    this.color,
    this.height,
    this.width,
    this.ttsData,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final color = this.color ?? AbiliaColors.white;
    final scaffoldBackgroundColor = Theme.of(context).scaffoldBackgroundColor;
    final selectedOuterDecoration = selected
        ? selectedBoxDecoration.copyWith(
            color: this.color != null ? scaffoldBackgroundColor : color,
          )
        : BoxDecoration(
            color: color,
            borderRadius: borderRadius,
          );

    final outerBoxPadding =
        selected ? layout.selectableField.boxPadding : EdgeInsets.zero;

    final innerDecoration = BoxDecoration(
      color: color,
      borderRadius: BorderRadius.all(
        innerRadiusFromBorderSize(outerBoxPadding.left),
      ),
      border: selected
          ? null
          : Border.fromBorderSide(
              BorderSide(
                color: AbiliaColors.transparentBlack30,
                width: layout.borders.thin,
              ),
            ),
    );

    final borderInsets = (selectedOuterDecoration.border?.dimensions ??
            innerDecoration.border?.dimensions ??
            EdgeInsets.zero)
        .resolve(TextDirection.ltr);

    final textPadding = EdgeInsets.only(
      left: layout.selectableField.textLeftPadding,
      right: layout.selectableField.textRightPadding,
    )
        .subtract(borderInsets.onlyHorizontal)
        .subtract(outerBoxPadding.onlyHorizontal);

    return Tts.fromSemantics(
      SemanticsProperties(
        label: ttsData ?? text.data,
        selected: selected,
        toggled: selected,
        inMutuallyExclusiveGroup: true,
      ),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: onTap,
          borderRadius: borderRadius,
          child: Stack(
            clipBehavior: Clip.none,
            children: <Widget>[
              Ink(
                height: height ?? layout.selectableField.height,
                width: width,
                decoration: selectedOuterDecoration,
                padding: outerBoxPadding,
                child: Ink(
                  decoration: innerDecoration,
                  padding: textPadding,
                  child: Align(
                    widthFactor: 1,
                    child: text,
                  ),
                ),
              ),
              Positioned(
                top: layout.selectableField.position,
                right: layout.selectableField.position,
                child: Container(
                  padding: layout.selectableField.padding,
                  decoration: BoxDecoration(
                    color: scaffoldBackgroundColor,
                    shape: BoxShape.circle,
                  ),
                  child: SizedBox(
                    width: layout.selectableField.size,
                    height: layout.selectableField.size,
                    child: AnimatedSwitcher(
                      duration: DayCalendar.transitionDuration,
                      transitionBuilder: (child, animation) =>
                          child is Container
                              ? child
                              : RotationTransition(
                                  turns: animation,
                                  child: ScaleTransition(
                                    scale: animation,
                                    child: child,
                                  ),
                                ),
                      child: selected
                          ? Icon(
                              AbiliaIcons.radioCheckboxSelected,
                              color: AbiliaColors.green,
                              size: layout.icon.small,
                            )
                          : Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: border,
                              ),
                            ),
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
