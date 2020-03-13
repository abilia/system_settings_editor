import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:seagull/i18n/app_localizations.dart';
import 'package:seagull/ui/colors.dart';
import 'package:seagull/ui/components/all.dart';

final _radius = const Radius.circular(100);

class CategoryRight extends StatelessWidget {
  final double maxWidth;

  const CategoryRight({Key key, @required this.maxWidth}) : super(key: key);

  @override
  Widget build(BuildContext context) => _Category(
        maxWith: maxWidth,
        text: Translator.of(context).translate.right,
        icon: AbiliaIcons.navigation_next,
        alignment: Alignment(1, 0),
        borderRadius: BorderRadius.only(
          topLeft: _radius,
          bottomLeft: _radius,
        ),
        textDirection: TextDirection.rtl,
      );
}

class CategoryLeft extends StatelessWidget {
  final double maxWidth;

  const CategoryLeft({Key key, @required this.maxWidth}) : super(key: key);
  @override
  Widget build(BuildContext context) => _Category(
        maxWith: maxWidth,
        icon: AbiliaIcons.navigation_previous,
        text: Translator.of(context).translate.left,
        alignment: Alignment(-1, 0),
        borderRadius: BorderRadius.only(
          topRight: _radius,
          bottomRight: _radius,
        ),
      );
}

class _Category extends StatelessWidget {
  final AlignmentGeometry alignment;
  final AlignmentGeometry top = const Alignment(0, -1);
  final BorderRadius borderRadius;
  final String text;
  final TextDirection textDirection;
  final double maxWith;
  final IconData icon;

  const _Category({
    Key key,
    @required this.alignment,
    @required this.borderRadius,
    @required this.text,
    @required this.maxWith,
    @required this.icon,
    this.textDirection = TextDirection.ltr,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment.add(top),
      child: Container(
        margin: const EdgeInsets.only(top: 4.0),
        padding: const EdgeInsets.all(4.0),
        constraints: BoxConstraints(
          maxHeight: 44.0,
          maxWidth: maxWith,
        ),
        decoration: BoxDecoration(
          borderRadius: borderRadius,
          color: AbiliaColors.black[80],
        ),
        child: Stack(
          children: [
            Align(
              alignment: alignment,
              child: Row(
                textDirection: textDirection,
                children: [
                  Icon(
                    icon,
                    color: AbiliaColors.black[60],
                  ),
                  Text(
                    text,
                    style: Theme.of(context)
                        .textTheme
                        .subhead
                        .copyWith(color: AbiliaColors.white),
                    overflow: TextOverflow.fade,
                    softWrap: false,
                  ),
                ].map((c) => Flexible(child: c)).toList(),
              ),
            ),
            Align(
              alignment: -alignment,
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AbiliaColors.transparantBlack[15],
                  ),
                  color: AbiliaColors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
