import 'package:seagull/ui/all.dart';

class ListDataItem extends StatelessWidget {
  final GestureTapCallback onTap;
  final Widget leading;
  final Widget? trailing;
  final Text text;
  final Text? secondaryText;

  final String? semanticsLabel;

  const ListDataItem({
    required this.text,
    required this.onTap,
    required this.leading,
    Key? key,
    this.trailing,
    this.semanticsLabel,
    this.secondaryText,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final trailing = this.trailing;
    final selected = trailing != null;
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
                          .copyWith(size: layout.icon.small),
                      child: Padding(
                        padding: layout.pickField.imagePadding,
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
                            style: (Theme.of(context).textTheme.bodyText1 ??
                                    bodyText1)
                                .copyWith(height: 1),
                            child: text,
                          ),
                          if (secondaryText != null) ...[
                            SizedBox(
                              height: layout.pickField.vericalDistanceText,
                            ),
                            DefaultTextStyle(
                              overflow: TextOverflow.ellipsis,
                              style: (Theme.of(context).textTheme.caption ??
                                      caption)
                                  .copyWith(
                                color: AbiliaColors.black60,
                                height: 1,
                              ),
                              child: secondaryText,
                            ),
                          ]
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (trailing != null)
              Positioned(
                right: 0,
                height: layout.pickField.height,
                child: trailing,
              ),
          ],
        ),
      ),
    );
  }
}
