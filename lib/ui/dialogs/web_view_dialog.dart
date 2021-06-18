// @dart=2.9

import 'package:webview_flutter/webview_flutter.dart';

import 'package:seagull/ui/all.dart';

class WebViewDialog extends StatelessWidget {
  final String url;

  const WebViewDialog({Key key, this.url}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return ViewDialog(
      heading: AppBarHeading(
        text: Translator.of(context).translate.browser,
        iconData: AbiliaIcons.select_language,
      ),
      body: WebView(initialUrl: url),
      expanded: true,
      bodyPadding: EdgeInsets.zero,
      backNavigationWidget: OkButton(onPressed: Navigator.of(context).maybePop),
    );
  }
}
