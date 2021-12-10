import 'package:seagull/ui/all.dart';

class AppBarHeading extends StatelessWidget {
  const AppBarHeading({
    Key? key,
    required this.text,
    this.label = '',
    this.iconData,
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
        data: theme.iconTheme.copyWith(
          color: AbiliaColors.white,
        ),
        child: DefaultTextStyle(
          style: (theme.textTheme.headline5 ?? headline5).copyWith(
            color: AbiliaColors.white,
            fontSize: 22.0.s,
          ),
          child: Row(
            children: [
              const Spacer(flex: 100),
              if (iconData != null) ...[
                Icon(iconData),
                SizedBox(width: 8.s),
              ],
              if (label.isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(label, style: theme.textTheme.button),
                    Text(text),
                  ],
                )
              else
                Text(text),
              const Spacer(flex: 114),
            ],
          ),
        ),
      ),
    );
  }
}
