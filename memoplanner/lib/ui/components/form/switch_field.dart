import 'package:memoplanner/ui/all.dart';

class SwitchField extends StatelessWidget {
  final ValueChanged<bool>? onChanged;
  final Widget? leading;
  final Widget child;
  final String? ttsData;
  final double? heigth, width;
  final bool value;
  final Decoration? decoration;
  final EdgeInsets? padding;
  static final defaultHeight = layout.switchField.height;

  const SwitchField({
    required this.child,
    this.onChanged,
    this.leading,
    this.heigth,
    this.width,
    this.value = false,
    this.decoration,
    this.padding,
    this.ttsData,
    Key? key,
  })  : assert(child is Text || ttsData != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    final leading = this.leading;
    final onChanged = this.onChanged;
    final switchToggle = Switch(
      value: value,
      onChanged: onChanged,
      key: ObjectKey(key),
    );
    return Tts.fromSemantics(
      SemanticsProperties(
        label: child is Text ? (child as Text).data : ttsData,
        toggled: value,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap:
              onChanged != null ? () => onChanged(!switchToggle.value) : null,
          borderRadius: borderRadius,
          child: Container(
            height: heigth ?? defaultHeight,
            width: width,
            decoration: onChanged == null
                ? boxDecoration
                : decoration ?? whiteBoxDecoration,
            padding: padding ?? layout.switchField.padding,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Expanded(
                  child: Row(
                    children: <Widget>[
                      if (leading != null) ...[
                        IconTheme(
                          data: Theme.of(context)
                              .iconTheme
                              .copyWith(size: layout.icon.small),
                          child: leading,
                        ),
                        SizedBox(
                          width: layout.formPadding.largeHorizontalItemDistance,
                        ),
                      ],
                      Expanded(
                        child: DefaultTextStyle(
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodyText1 ??
                              bodyText1,
                          child: child,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: layout.switchField.toggleSize,
                  child: FittedBox(
                    child: switchToggle,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
