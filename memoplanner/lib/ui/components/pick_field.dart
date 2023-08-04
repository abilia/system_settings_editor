import 'package:memoplanner/ui/all.dart';

class PickField extends StatelessWidget {
  static Icon trailingArrow() => Icon(
        AbiliaIcons.navigationNext,
        color: AbiliaColors.black60,
        size: layout.pickField.iconSize,
      );
  final GestureTapCallback? onTap;
  final Widget? leading, trailing, extras;
  final EdgeInsets? verticalPadding, leadingPadding, padding;
  final Text text;
  final bool errorState;
  final String? semanticsLabel;
  final Text? trailingText, secondaryText;

  const PickField({
    required this.text,
    Key? key,
    this.leading,
    this.extras,
    this.trailing,
    this.onTap,
    this.errorState = false,
    this.semanticsLabel,
    this.trailingText,
    this.secondaryText,
    this.leadingPadding,
    this.verticalPadding,
    this.padding,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final leading = this.leading;
    final trailing = this.trailing ?? trailingArrow();
    final trailingText = this.trailingText;
    final secondaryText = this.secondaryText;
    final verticalPadding =
        this.verticalPadding ?? layout.pickField.verticalPadding;
    final extras = this.extras;
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
            decoration: decoration,
            child: Padding(
              padding: extras != null
                  ? layout.pickField.withExtrasPadding.onlyVertical
                  : verticalPadding,
              child: Column(
                children: [
                  Padding(
                    padding: padding ?? layout.pickField.padding,
                    child: Row(
                      children: <Widget>[
                        if (leading != null)
                          IconTheme(
                            data: Theme.of(context)
                                .iconTheme
                                .copyWith(size: layout.icon.small),
                            child: Padding(
                              padding: leadingPadding ??
                                  layout.pickField.leadingPadding,
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
                                style: Theme.of(context).textTheme.bodyLarge ??
                                    bodyLarge,
                                child: text,
                              ),
                              if (secondaryText != null)
                                DefaultTextStyle(
                                  overflow: TextOverflow.ellipsis,
                                  style: (Theme.of(context)
                                              .textTheme
                                              .bodySmall ??
                                          bodySmall)
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
                              style: (Theme.of(context).textTheme.bodyMedium ??
                                      bodyMedium)
                                  .copyWith(color: AbiliaColors.white140),
                              child: trailingText,
                            ),
                          ),
                        trailing,
                      ],
                    ),
                  ),
                  if (extras != null) ...[
                    SizedBox(height: layout.pickField.bottomPadding),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding:
                            layout.pickField.withExtrasPadding.onlyHorizontal,
                        child: extras,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
