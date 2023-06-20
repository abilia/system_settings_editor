import 'package:memoplanner/ui/all.dart';

class AppBarHeading extends StatelessWidget {
  const AppBarHeading({
    required this.text,
    this.label = '',
    this.iconData,
    this.isImageSelector = false,
    this.isTemplateSelector = false,
    Key? key,
  }) : super(key: key);

  final String text;
  final String label;
  final IconData? iconData;
  final bool isImageSelector;
  final bool isTemplateSelector;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Tts.data(
      data: label.isEmpty ? text : '$label $text',
      child: IconTheme(
        data: theme.iconTheme.copyWith(color: AbiliaColors.white),
        child: DefaultTextStyle(
          style: (theme.textTheme.titleLarge ?? titleLarge)
              .copyWith(color: AbiliaColors.white),
          child: Row(
            children: [
              const Spacer(flex: 15),
              Expanded(
                flex: 345,
                child: Row(
                  mainAxisAlignment: isImageSelector
                      ? MainAxisAlignment.start
                      : MainAxisAlignment.center,
                  children: [
                    if (iconData != null) ...[
                      Icon(iconData),
                      SizedBox(
                          width: layout.formPadding.horizontalItemDistance),
                    ],
                    if (label.isNotEmpty)
                      Flexible(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: getTextFields(label, text,
                              isTemplateSelector || isImageSelector, theme),
                        ),
                      )
                    else
                      Text(text),
                  ],
                ),
              ),
              const Spacer(flex: 30),
            ],
          ),
        ),
      ),
    );
  }

  List<Text> getTextFields(
      String label, String text, bool reverse, ThemeData theme) {
    final labelText = Text(label, style: theme.textTheme.labelLarge);
    final textText = Text(
      text,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
    return reverse ? [textText, labelText] : [labelText, textText];
  }
}
