import 'package:auto_size_text/auto_size_text.dart';
import 'package:memoplanner/ui/all.dart';

class TextAndIconActionButton extends StatelessWidget {
  const TextAndIconActionButton(
    this.text,
    this.iconData, {
    Key? key,
    this.onPressed,
    this.style,
    this.size,
  }) : super(key: key);

  final ButtonStyle? style;
  final VoidCallback? onPressed;
  final String text;
  final IconData iconData;
  final double? size;

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
            Icon(iconData, size: size ?? layout.actionButton.withTextIconSize),
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
    this.selected = false,
    this.ttsData,
  }) : super(key: key);

  final String text;
  final IconData iconData;
  final VoidCallback? onPressed;
  final bool selected;
  final String? ttsData;

  @override
  Widget build(BuildContext context) => Tts.data(
        data: ttsData ?? text,
        child: layout.go
            ? IconActionButton(
                onPressed: onPressed,
                style: selected
                    ? actionButtonStyleLightSelected
                    : actionButtonStyleLight,
                child: Icon(iconData),
              )
            : TextAndIconActionButton(
                text,
                iconData,
                onPressed: onPressed,
                style: selected
                    ? textActionButtonStyleLightSelected
                    : textActionButtonStyleLight,
              ),
      );
}

class TextAndOrIconActionButtonBlack extends StatelessWidget {
  const TextAndOrIconActionButtonBlack(
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
            ? IconActionButton(
                onPressed: onPressed,
                style: actionButtonStyleBlack,
                child: Icon(iconData),
              )
            : TextAndIconActionButton(
                text,
                iconData,
                onPressed: onPressed,
                style: textActionButtonStyleBlack,
              ),
      );
}
