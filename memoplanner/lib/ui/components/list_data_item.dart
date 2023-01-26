import 'package:memoplanner/ui/all.dart';

/// Called DataItem (list) in Figma
class ListDataItem extends StatelessWidget {
  final GestureTapCallback onTap;
  final Widget leading, trailing;
  final bool selected, alwaysShowTrailing;
  final Text text;
  final Text? secondaryText;

  final String? semanticsLabel;

  const ListDataItem({
    required this.text,
    required this.onTap,
    required this.leading,
    required this.trailing,
    required this.selected,
    this.alwaysShowTrailing = false,
    this.semanticsLabel,
    this.secondaryText,
    Key? key,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final bool hasText = text.data?.isNotEmpty ?? false;
    final secondaryText = this.secondaryText;
    final textPadding = hasText && secondaryText != null
        ? layout.listDataItem.textAndSubtitlePadding
        : EdgeInsets.zero;
    return Tts.fromSemantics(
      SemanticsProperties(
        label: hasText ? text.data : semanticsLabel,
        button: true,
        selected: selected,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: borderRadius,
          child: Ink(
            height: layout.pickField.height,
            decoration:
                selected ? greySelectedBoxDecoration : whiteBoxDecoration,
            child: Row(
              children: <Widget>[
                IconTheme(
                  data: Theme.of(context)
                      .iconTheme
                      .copyWith(size: layout.listDataItem.iconSize),
                  child: Padding(
                    padding: layout.listDataItem.imagePadding,
                    child: leading,
                  ),
                ),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (hasText)
                        DefaultTextStyle(
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodyLarge ??
                              bodyLarge,
                          child: text,
                        ),
                      if (secondaryText != null)
                        DefaultTextStyle(
                          overflow: TextOverflow.ellipsis,
                          style: (Theme.of(context).textTheme.bodySmall ??
                                  bodySmall)
                              .copyWith(
                            color: AbiliaColors.black60,
                            height: layout.listDataItem.secondaryTextHeight,
                          ),
                          child: secondaryText,
                        ),
                    ],
                  ).pad(textPadding),
                ),
                CollapsableWidget(
                  axis: Axis.horizontal,
                  collapsed: !alwaysShowTrailing && !selected,
                  child: trailing,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
