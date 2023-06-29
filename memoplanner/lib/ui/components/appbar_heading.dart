import 'package:memoplanner/ui/all.dart';

class AppBarHeading extends StatelessWidget {
  const AppBarHeading({
    required this.text,
    this.label = '',
    this.breadcrumbs = '',
    this.iconData,
    this.hasTrailing = false,
    Key? key,
  }) : super(key: key);

  final String text;
  final String label;
  final String breadcrumbs;
  final IconData? iconData;
  final bool hasTrailing;

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
                  mainAxisAlignment: hasTrailing
                      ? MainAxisAlignment.start
                      : MainAxisAlignment.center,
                  children: [
                    if (iconData != null) ...[
                      Icon(iconData),
                      SizedBox(
                          width: layout.formPadding.horizontalItemDistance),
                    ],
                    if (label.isNotEmpty || breadcrumbs.isNotEmpty)
                      Flexible(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (label.isNotEmpty)
                              Text(label, style: theme.textTheme.labelLarge),
                            Text(
                              text,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (breadcrumbs.isNotEmpty)
                              Text(breadcrumbs,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: theme.textTheme.labelLarge),
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
