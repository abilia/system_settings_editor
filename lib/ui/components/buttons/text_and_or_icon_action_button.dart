import 'package:auto_size_text/auto_size_text.dart';

import 'package:seagull/ui/all.dart';

class _TextAndIconActionButton extends StatelessWidget {
  const _TextAndIconActionButton(
    this.text,
    this.iconData, {
    Key? key,
    this.onPressed,
    this.style,
  }) : super(key: key);

  final ButtonStyle? style;
  final VoidCallback? onPressed;
  final String text;
  final IconData iconData;

  @override
  Widget build(BuildContext context) => TextButton(
        onPressed: onPressed,
        style: style,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AutoSizeText(
              text,
              minFontSize: 12,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: layout.actionButton.spacing),
            Icon(iconData, size: layout.iconSize.small),
          ],
        ),
      );
}

class TextAndOrIconActionButtonLight extends StatelessWidget {
  const TextAndOrIconActionButtonLight(
    this.text,
    this.iconData, {
    Key? key,
    this.onPressed,
  }) : super(key: key);

  final String text;
  final IconData iconData;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) => Tts.data(
        data: text,
        child: layout.go
            ? IconActionButtonLight(
                onPressed: onPressed,
                child: Icon(iconData),
              )
            : _TextAndIconActionButton(
                text,
                iconData,
                onPressed: onPressed,
                style: textActionButtonStyleLight,
              ),
      );
}