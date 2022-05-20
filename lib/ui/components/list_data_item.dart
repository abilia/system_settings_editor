import 'package:seagull/ui/all.dart';

/// Called DataItem (list) in Figma
class ListDataItem extends StatelessWidget {
  final GestureTapCallback onTap;
  final Widget leading, trailing;
  final bool selected, alwaysShowTrailing;
  final Text text;
  final Text? secondaryText;

  final String? semanticsLabel;

  const ListDataItem({
    Key? key,
    required this.text,
    required this.onTap,
    required this.leading,
    required this.trailing,
    required this.selected,
    this.alwaysShowTrailing = false,
    this.semanticsLabel,
    this.secondaryText,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final secondaryText = this.secondaryText;
    return Tts.fromSemantics(
      SemanticsProperties(
        label: text.data?.isEmpty == true ? semanticsLabel : text.data,
        button: true,
        selected: selected,
      ),
      child: Material(
        color: Colors.transparent,
        child: Stack(
          children: [
            InkWell(
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
                          DefaultTextStyle(
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.bodyText1 ??
                                bodyText1,
                            child: text,
                          ),
                          if (secondaryText != null) ...[
                            SizedBox(
                              height: layout.pickField.verticalDistanceText,
                            ),
                            DefaultTextStyle(
                              overflow: TextOverflow.ellipsis,
                              style: (Theme.of(context).textTheme.caption ??
                                      caption)
                                  .copyWith(color: AbiliaColors.black60),
                              child: secondaryText,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              right: 0,
              height: layout.pickField.height,
              child: CollapsableWidget(
                axis: Axis.horizontal,
                collapsed: !alwaysShowTrailing && !selected,
                child: trailing,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
