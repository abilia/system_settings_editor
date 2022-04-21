import 'package:seagull/ui/all.dart';

class SelectableField extends StatelessWidget {
  final Text text;
  final double? heigth, width;
  final bool selected;
  final GestureTapCallback onTap;

  const SelectableField({
    Key? key,
    required this.selected,
    required this.onTap,
    required this.text,
    this.heigth,
    this.width,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final decoration = selectableBoxDecoration(selected);
    return Tts.fromSemantics(
      SemanticsProperties(
        label: text.data,
        selected: selected,
        toggled: selected,
        inMutuallyExclusiveGroup: true,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: borderRadius,
          child: Stack(
            clipBehavior: Clip.none,
            children: <Widget>[
              Ink(
                height: heigth ?? layout.selectableField.height,
                width: width,
                decoration: decoration,
                padding: EdgeInsets.only(
                  left: layout.selectableField.textLeftPadding,
                  right: layout.selectableField.textRightPadding,
                ),
                child: Align(
                  widthFactor: 1,
                  child: text,
                ),
              ),
              Positioned(
                top: layout.selectableField.position,
                right: layout.selectableField.position,
                child: Container(
                  padding: layout.selectableField.padding,
                  decoration: BoxDecoration(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    shape: BoxShape.circle,
                  ),
                  child: SizedBox(
                    width: layout.selectableField.size,
                    height: layout.selectableField.size,
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
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
                              AbiliaIcons.radiocheckboxSelected,
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
