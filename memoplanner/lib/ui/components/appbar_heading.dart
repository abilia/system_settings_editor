import 'package:memoplanner/ui/all.dart';

class AppBarHeading extends StatelessWidget {
  const AppBarHeading({
    required this.text,
    this.label = '',
    this.iconData,
    Key? key,
  }) : super(key: key);

  final String text;
  final String label;
  final IconData? iconData;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Tts.data(
      data: label.isEmpty ? text : '$label $text',
      child: IconTheme(
        data: theme.iconTheme.copyWith(color: AbiliaColors.white),
        child: DefaultTextStyle(
          style: (theme.textTheme.headline6 ?? headline6)
              .copyWith(color: AbiliaColors.white),
          child: Row(
            children: [
              const Spacer(flex: 15),
              Expanded(
                flex: 345,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
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
                          children: [
                            Text(label, style: theme.textTheme.button),
                            Text(
                              text,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
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
}
