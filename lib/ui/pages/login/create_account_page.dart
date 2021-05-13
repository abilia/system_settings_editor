import 'package:flutter/gestures.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/config.dart';
import 'package:seagull/ui/all.dart';

class CreateAccountPage extends StatelessWidget {
  static const termsOfUseUrl = 'https://www.abilia.com/intl/terms-of-use',
      privacyPolicyUrl =
          'https://www.abilia.com/intl/policy-for-the-processing-of-personal-data';
  @override
  Widget build(BuildContext context) {
    final t = Translator.of(context).translate;
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.only(left: 8.s, top: 24.0, right: 8.s),
        child: Column(
          children: [
            SizedBox(height: 48.s),
            const MyAbiliaLogo(),
            SizedBox(height: 32.s),
            Tts(
              child: Text(
                t.createAaccountHeading,
                style: textTheme.headline6,
              ),
            ),
            SizedBox(height: 8.s),
            Tts(
              child: Text(
                t.createAaccountSubheading,
                style: textTheme.bodyText2,
              ),
            ),
            SizedBox(height: 32.s),
            UsernameInput(
              initialValue: '',
              errorState: false,
              onChanged: (newUsername) => context.read<LoginBloc>().add(
                    UsernameChanged(newUsername),
                  ),
            ),
            SizedBox(height: 16.s),
            PasswordInput(
              password: '',
              onPasswordChange: (p) {},
              errorState: false,
              validator: (p) => LoginBloc.passwordValid(p),
            ),
            SizedBox(height: 16.s),
            PasswordInput(
              heading: t.confirmPassword,
              password: '',
              onPasswordChange: (p) {},
              errorState: false,
              validator: (p) => LoginBloc.passwordValid(p),
            ),
            SizedBox(height: 48.s),
            AcceptTermsSwitch(
              linkText: t.termsOfUse,
              value: false,
              url: termsOfUseUrl,
              onChanged: (v) {},
            ),
            SizedBox(height: 4.s),
            AcceptTermsSwitch(
              linkText: t.privacyPolicy,
              value: false,
              url: privacyPolicyUrl,
              onChanged: (v) {},
            ),
          ],
        ),
      ),
      bottomNavigationBar: const BottomNavigation(
        forwardNavigationWidget: CreateAccountButton(),
        backNavigationWidget: BackToLoginButton(),
      ),
    );
  }
}

class AcceptTermsSwitch extends StatelessWidget {
  final String linkText, url;
  final bool value;
  final ValueChanged<bool> onChanged;

  const AcceptTermsSwitch({
    Key key,
    this.linkText,
    this.url,
    this.value,
    this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final t = Translator.of(context).translate;
    return SwitchField(
      ttsData: '${t.acceptTerms}$linkText',
      value: value,
      onChanged: onChanged,
      child: RichText(
        text: TextSpan(
          style: DefaultTextStyle.of(context).style,
          children: [
            TextSpan(text: t.acceptTerms),
            TextSpan(
              text: linkText,
              style: DefaultTextStyle.of(context).style.copyWith(
                    color: AbiliaColors.blue,
                    decoration: TextDecoration.underline,
                  ),
              recognizer: TapGestureRecognizer()
                ..onTap = () => showViewDialog(
                      context: context,
                      builder: (_) => WebViewDialog(url: url),
                      wrapWithAuthProviders: false,
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class MyAbiliaLogo extends StatelessWidget {
  const MyAbiliaLogo({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FadeInImage(
      fadeInDuration: const Duration(milliseconds: 50),
      fadeInCurve: Curves.linear,
      placeholder: MemoryImage(kTransparentImage),
      image: AssetImage(
        'assets/graphics/${Config.flavor.id}/myAbilia.png',
      ),
    );
  }
}

class BackToLoginButton extends StatelessWidget {
  const BackToLoginButton({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GreyButton(
      icon: AbiliaIcons.navigation_previous,
      text: Translator.of(context).translate.toLogin,
      onPressed: Navigator.of(context).maybePop,
    );
  }
}

class CreateAccountButton extends StatelessWidget {
  const CreateAccountButton({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GreenButton(
      icon: AbiliaIcons.ok,
      text: Translator.of(context).translate.createAccount,
      onPressed: Navigator.of(context).maybePop,
    );
  }
}
