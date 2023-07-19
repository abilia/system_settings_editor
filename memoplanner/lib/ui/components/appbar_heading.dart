import 'package:memoplanner/ui/all.dart';

class AppBarHeading extends StatelessWidget {
  final breadcrumbsMaxDepth = 3;
  const AppBarHeading({
    required this.text,
    this.label = '',
    this.breadcrumbs = const [],
    this.iconData,
    Key? key,
  }) : super(key: key);

  final String text;
  final String label;
  final List<String> breadcrumbs;
  final IconData? iconData;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final breadString = [
      if (breadcrumbs.length > breadcrumbsMaxDepth) ...[
        '...',
        ...breadcrumbs.getRange(
          breadcrumbs.length - breadcrumbsMaxDepth,
          breadcrumbs.length,
        )
      ] else
        ...breadcrumbs,
    ].join(r' / ');
    return Tts.data(
      data: '$label $text $breadString'.trim(),
      child: IconTheme(
        data: theme.iconTheme.copyWith(color: AbiliaColors.white),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (iconData != null)
              Padding(
                padding: layout.appBar.iconPadding,
                child: Icon(iconData),
              ),
            Flexible(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (label.isNotEmpty)
                    Padding(
                      padding: layout.appBar.titleSpacing.onlyBottom,
                      child: Text(
                        label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.labelLarge,
                      ),
                    ),
                  Text(
                    text,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleLarge
                        ?.copyWith(color: AbiliaColors.white),
                  ),
                  if (breadString.isNotEmpty)
                    Padding(
                      padding: layout.appBar.titleSpacing.onlyTop,
                      child: Text(
                        breadString,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.labelLarge,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
