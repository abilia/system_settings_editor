import 'package:memoplanner/ui/all.dart';
import 'package:memoplanner/utils/all.dart';

class ErrorMessage extends StatelessWidget {
  const ErrorMessage({
    required this.text,
    this.trailing,
    Key? key,
  }) : super(key: key);

  final Text text;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final trailing = this.trailing;
    return Tts.data(
      data: text.data,
      child: Container(
        decoration: BoxDecoration(
          color: AbiliaColors.orange40,
          borderRadius: borderRadius,
        ),
        width: double.infinity,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Padding(
                padding: layout.message.textPadding,
                child: DefaultTextStyle(
                  style: Theme.of(context).textTheme.bodyMedium ?? bodyMedium,
                  child: text,
                ),
              ),
            ),
            if (trailing != null)
              Padding(
                padding: layout.message.trailingPadding,
                child: trailing,
              ),
          ],
        ),
      ),
    );
  }
}

class NoInternetErrorMessage extends StatelessWidget {
  const NoInternetErrorMessage({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ErrorMessage(
      text: Text(Lt.of(context).connectInternetToContinue),
      trailing: const IconActionButtonDark(
        onPressed: AndroidIntents.openWifiSettings,
        child: Icon(
          AbiliaIcons.noWifi,
        ),
      ),
    );
  }
}
