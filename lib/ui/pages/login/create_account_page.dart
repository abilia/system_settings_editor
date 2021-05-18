import 'package:flutter/gestures.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/config.dart';
import 'package:seagull/repository/create_account_repository.dart';
import 'package:seagull/ui/all.dart';
import 'package:seagull/utils/all.dart';

class CreateAccountPage extends StatelessWidget {
  static const termsOfUseUrl = 'https://www.abilia.com/intl/terms-of-use',
      privacyPolicyUrl =
          'https://www.abilia.com/intl/policy-for-the-processing-of-personal-data';
  final String baseUrl;

  const CreateAccountPage({Key key, @required this.baseUrl}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final translator = Translator.of(context);
    final t = translator.translate;
    final textTheme = Theme.of(context).textTheme;
    return BlocProvider(
      create: (context) => CreateAccountBloc(
        languageTag: translator.locale.toLanguageTag(),
        repository: CreateAccountRepository(
          client: GetIt.I<BaseClient>(),
          baseUrl: baseUrl,
        ),
      ),
      child: MultiBlocListener(
        listeners: [
          BlocListener<CreateAccountBloc, CreateAccountState>(
            listenWhen: (previous, current) => current is AccountCreated,
            listener: (context, state) async {
              await showViewDialog(
                context: context,
                wrapWithAuthProviders: false,
                builder: (context) => ViewDialog(
                  heading: AppBarHeading(
                    text: t.accountCreatedHeading,
                    iconData: AbiliaIcons.ok,
                  ),
                  body: Tts(child: Text(t.accountCreatedBody)),
                  backNavigationWidget: const OkButton(),
                ),
              );
              Navigator.of(context).pop(state.username);
            },
          ),
          BlocListener<CreateAccountBloc, CreateAccountState>(
            listenWhen: (previous, current) => current is CreateAccountFailed,
            listener: (context, state) async {
              if (state is CreateAccountFailed) {
                await showViewDialog(
                  context: context,
                  wrapWithAuthProviders: false,
                  builder: (_) => ErrorDialog(
                    text: state.errorMessage(t),
                    backNavigationWidget: const OkButton(),
                  ),
                );
              }
            },
          ),
        ],
        child: BlocBuilder<CreateAccountBloc, CreateAccountState>(
          builder: (context, state) => Scaffold(
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
                    initialValue: state.username,
                    errorState: state.usernameFailure,
                    inputValid: (s) => s.isNotEmpty,
                    onChanged: (newUsername) => context
                        .read<CreateAccountBloc>()
                        .add(UsernameEmailChanged(newUsername)),
                  ),
                  SizedBox(height: 16.s),
                  PasswordInput(
                    key: TestKey.createAccountPassword,
                    password: state.firstPassword,
                    onPasswordChange: (password) => context
                        .read<CreateAccountBloc>()
                        .add(FirstPasswordChanged(password)),
                    errorState: state.passwordFailure,
                    validator: (p) => p.isNotEmpty,
                  ),
                  SizedBox(height: 16.s),
                  PasswordInput(
                    key: TestKey.createAccountPasswordConfirm,
                    heading: t.confirmPassword,
                    password: state.secondPassword,
                    onPasswordChange: (password) => context
                        .read<CreateAccountBloc>()
                        .add(SecondPasswordChanged(password)),
                    errorState: state.conformPasswordFailure,
                    validator: (p) => p.isNotEmpty,
                  ),
                  SizedBox(height: 48.s),
                  AcceptTermsSwitch(
                    key: TestKey.acceptTermsOfUse,
                    linkText: t.termsOfUse,
                    value: state.termsOfUse,
                    url: termsOfUseUrl,
                    errorState: state.termsOfUseFailure,
                    onChanged: (v) =>
                        context.read<CreateAccountBloc>().add(TermsOfUse(v)),
                  ),
                  SizedBox(height: 4.s),
                  AcceptTermsSwitch(
                    key: TestKey.acceptPrivacyPolicy,
                    linkText: t.privacyPolicy,
                    value: state.privacyPolicy,
                    url: privacyPolicyUrl,
                    errorState: state.privacyPolicyFailure,
                    onChanged: (v) =>
                        context.read<CreateAccountBloc>().add(PrivacyPolicy(v)),
                  ),
                ],
              ),
            ),
            bottomNavigationBar: const BottomNavigation(
              forwardNavigationWidget: CreateAccountButton(),
              backNavigationWidget: BackToLoginButton(),
            ),
          ),
        ),
      ),
    );
  }
}

class AcceptTermsSwitch extends StatelessWidget {
  final String linkText, url;
  final bool value;
  final ValueChanged<bool> onChanged;
  final bool errorState;

  const AcceptTermsSwitch({
    Key key,
    @required this.linkText,
    @required this.url,
    @required this.value,
    @required this.onChanged,
    @required this.errorState,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final t = Translator.of(context).translate;
    return SwitchField(
      ttsData: '${t.acceptTerms}$linkText',
      value: value,
      onChanged: onChanged,
      decoration: errorState ? whiteErrorBoxDecoration : null,
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
    return BlocBuilder<CreateAccountBloc, CreateAccountState>(
      builder: (context, state) {
        if (state is CreateAccountLoadning) {
          return SizedBox(
            width: 64.s,
            height: 64.s,
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation(AbiliaColors.red),
              strokeWidth: 6.s,
            ),
          );
        }
        return FadeInImage(
          fadeInDuration: const Duration(milliseconds: 50),
          fadeInCurve: Curves.linear,
          placeholder: MemoryImage(kTransparentImage),
          image: AssetImage(
            'assets/graphics/${Config.flavor.id}/myAbilia.png',
          ),
        );
      },
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
    return BlocBuilder<CreateAccountBloc, CreateAccountState>(
      builder: (context, state) {
        return GreenButton(
          icon: AbiliaIcons.ok,
          text: Translator.of(context).translate.createAccount,
          onPressed: state is! CreateAccountLoadning
              ? () => context
                  .read<CreateAccountBloc>()
                  .add(CreateAccountButtonPressed())
              : null,
        );
      },
    );
  }
}
