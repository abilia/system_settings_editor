import 'package:flutter/gestures.dart';
import 'package:memoplanner/ui/all.dart';

class AcceptTermsSwitch extends StatelessWidget {
  static const abiliaUrl = 'https://www.abilia.com/';

  final String linkText, url;
  final bool value;
  final ValueChanged<bool> onChanged;
  final bool errorState;

  const AcceptTermsSwitch({
    required this.linkText,
    required this.url,
    required this.value,
    required this.onChanged,
    this.errorState = false,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final t = Translator.of(context).translate;
    return SwitchField(
      ttsData: '${t.acceptTerms} $linkText',
      value: value,
      onChanged: onChanged,
      decoration: errorState ? whiteErrorBoxDecoration : null,
      child: RichText(
        text: TextSpan(
          style: DefaultTextStyle.of(context).style,
          children: [
            TextSpan(text: '${t.acceptTerms} '),
            TextSpan(
              text: linkText,
              style: DefaultTextStyle.of(context).style.copyWith(
                    color: AbiliaColors.blue,
                    decoration: TextDecoration.underline,
                  ),
              recognizer: TapGestureRecognizer()
                ..onTap = () async => showViewDialog(
                      context: context,
                      builder: (_) => WebViewDialog(url: '$abiliaUrl$url'),
                      wrapWithAuthProviders: false,
                      routeSettings: (WebViewDialog).routeSetting(properties: {
                        'url': '$abiliaUrl$url',
                      }),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
