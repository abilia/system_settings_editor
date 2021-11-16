import 'package:seagull/bloc/providers.dart';
import 'package:seagull/ui/all.dart';
import 'package:seagull/utils/duration.dart';

class ScreenTimeoutPickField extends StatefulWidget {
  const ScreenTimeoutPickField({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return ScreenTimeoutState();
  }
}

class ScreenTimeoutState extends State<ScreenTimeoutPickField> {
  String timeout;

  @override
  Widget build(BuildContext context) {
    return PickField(
      text: timeout,
      onTap: () async {
        final timeout = await Navigator.of(context).push<int>(
          MaterialPageRoute(
            builder: (_) => CopiedAuthProviders(
              blocContext: context,
              child: const ScreenTimeOutSelector(),
            ),
          ),
        );
        if (timeout != null) {}
      },
    );
  }
}

class ScreenTimeOutSelector extends StatelessWidget {
  final value;

  const ScreenTimeOutSelector({Key? key, this.value}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final t = Translator.of(context).translate;
    return Scaffold(
      appBar: AbiliaAppBar(
        iconData: AbiliaIcons.pastPictureFromWindowsClipboard,
        title: translate.selectPicture,
      ),
      body: Column(
        children: [
          DefaultTextStyle(
            style: (Theme.of(context).textTheme.bodyText2 ?? bodyText2)
                .copyWith(color: AbiliaColors.black75),
            child: ListView(
              padding: EdgeInsets.symmetric(vertical: 20.s),
              children: [
                ...[1, 30, 0].map((d) => d.minutes()).map(
                      (d) => RadioField<int>(
                          text: Text(
                            d.inMilliseconds == 0
                                ? t.noTimeout
                                : d.toDurationString(t, shortMin: false),
                          ),
                          onChanged: (v) => value,
                          groupValue: 1,
                          value: d.inMilliseconds),
                    ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigation(
        backNavigationWidget: CancelButton(onPressed: onCancel),
        forwardNavigationWidget: selected != null
            ? OkButton(
                onPressed: () => onOk(selected),
              )
            : null,
      ),
    );
  }
}
