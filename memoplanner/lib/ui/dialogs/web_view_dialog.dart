import 'package:memoplanner/ui/all.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebViewDialog extends StatelessWidget {
  final String url;

  const WebViewDialog({
    required this.url,
    Key? key,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return ViewDialog(
      heading: AppBarHeading(
        text: Lt.of(context).browser,
        iconData: AbiliaIcons.selectLanguage,
      ),
      body: WebViewWidget(
        // ignore: discarded_futures
        controller: WebViewController()..loadRequest(Uri.parse(url)),
      ),
      expanded: true,
      bodyPadding: EdgeInsets.zero,
      backNavigationWidget: OkButton(onPressed: Navigator.of(context).maybePop),
    );
  }
}
