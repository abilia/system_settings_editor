import 'package:memoplanner/ui/all.dart';

class PickField extends StatelessWidget {
  static const trailingArrow = Icon(
    AbiliaIcons.navigationNext,
    color: AbiliaColors.black60,
  );
  final GestureTapCallback? onTap;
  final Widget? leading, trailing;
  final EdgeInsets? leadingPadding, padding;
  final Text text;
  final bool errorState;
  final String? semanticsLabel;
  final Text? trailingText, secondaryText;

  const PickField({
    required this.text,
    Key? key,
    this.leading,
    this.trailing = trailingArrow,
    this.onTap,
    this.errorState = false,
    this.semanticsLabel,
    this.trailingText,
    this.secondaryText,
    this.leadingPadding,
    this.padding,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final leading = this.leading;
    final trailing = this.trailing;
    final trailingText = this.trailingText;
    final secondaryText = this.secondaryText;
    final decoration = errorState
        ? whiteErrorBoxDecoration
        : onTap == null
            ? disabledBoxDecoration
            : whiteBoxDecoration;

    return Tts.fromSemantics(
      SemanticsProperties(
        label: text.data?.isEmpty == true ? semanticsLabel : text.data,
        button: true,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: borderRadius,
          child: Ink(
            height: layout.pickField.height,
            decoration: decoration,
            padding: padding ?? layout.pickField.padding,
            child: Row(
              children: <Widget>[
                if (leading != null)
                  IconTheme(
                    data: Theme.of(context)
                        .iconTheme
                        .copyWith(size: layout.icon.small),
                    child: Padding(
                      padding:
                          leadingPadding ?? layout.pickField.leadingPadding,
                      child: leading,
                    ),
                  ),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      DefaultTextStyle(
                        overflow: TextOverflow.ellipsis,
                        style:
                            Theme.of(context).textTheme.bodyText1 ?? bodyText1,
                        child: text,
                      ),
                      if (secondaryText != null)
                        DefaultTextStyle(
                          overflow: TextOverflow.ellipsis,
                          style:
                              (Theme.of(context).textTheme.caption ?? caption)
                                  .copyWith(color: AbiliaColors.black60),
                          child: secondaryText,
                        ),
                    ],
                  ),
                ),
                if (trailingText != null)
                  Padding(
                    padding: EdgeInsets.only(
                      right: layout.formPadding.horizontalItemDistance,
                    ),
                    child: DefaultTextStyle(
                      overflow: TextOverflow.ellipsis,
                      style:
                          (Theme.of(context).textTheme.bodyText2 ?? bodyText2)
                              .copyWith(color: AbiliaColors.white140),
                      child: trailingText,
                    ),
                  ),
                if (trailing != null) trailing,
              ],
            ),
          ),
        ),
      ),
    );
  }
}
