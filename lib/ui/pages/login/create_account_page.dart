import 'package:flutter/gestures.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/repository/all.dart';
import 'package:seagull/ui/all.dart';

class CreateAccountPage extends StatelessWidget {
  final UserRepository userRepository;

  const CreateAccountPage({Key? key, required this.userRepository})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    final translator = Translator.of(context);
    final t = translator.translate;
    final textTheme = Theme.of(context).textTheme;
    return BlocProvider(
      create: (context) => CreateAccountCubit(
        languageTag: translator.locale.toLanguageTag(),
        repository: userRepository,
      ),
      child: MultiBlocListener(
        listeners: [
          BlocListener<CreateAccountCubit, CreateAccountState>(
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
                  backNavigationWidget:
                      OkButton(onPressed: Navigator.of(context).maybePop),
                ),
              );
              Navigator.of(context).pop(state.username);
            },
          ),
          BlocListener<CreateAccountCubit, CreateAccountState>(
            listenWhen: (previous, current) => current is CreateAccountFailed,
            listener: (context, state) async {
              if (state is CreateAccountFailed) {
                await showViewDialog(
                  context: context,
                  wrapWithAuthProviders: false,
                  builder: (_) => ErrorDialog(
                    text: state.errorMessage(t),
                    backNavigationWidget:
                        OkButton(onPressed: Navigator.of(context).maybePop),
                  ),
                );
              }
            },
          ),
        ],
        child: BlocBuilder<CreateAccountCubit, CreateAccountState>(
          builder: (context, state) => Scaffold(
            resizeToAvoidBottomInset: false,
            body: Padding(
              padding: layout.templates.m5,
              child: Column(
                children: [
                  const MyAbiliaLogo(),
                  SizedBox(height: layout.formPadding.largeGroupDistance),
                  Tts(
                    child: Text(
                      t.createAaccountHeading,
                      style: textTheme.headline6,
                    ),
                  ),
                  SizedBox(height: layout.formPadding.verticalItemDistance),
                  Tts(
                    child: Text(
                      t.createAaccountSubheading,
                      style: textTheme.bodyText2,
                    ),
                  ),
                  SizedBox(height: layout.formPadding.largeGroupDistance),
                  UsernameInput(
                    initialValue: state.username,
                    errorState: state.usernameFailure,
                    inputValid: (s) => s.isNotEmpty,
                    onChanged: (newUsername) => context
                        .read<CreateAccountCubit>()
                        .usernameEmailChanged(newUsername),
                  ),
                  SizedBox(height: layout.formPadding.groupBottomDistance),
                  PasswordInput(
                    key: TestKey.createAccountPassword,
                    inputHeading: t.passwordHint,
                    password: state.firstPassword,
                    onPasswordChange: (password) => context
                        .read<CreateAccountCubit>()
                        .firstPasswordChanged(password),
                    errorState: state.passwordFailure,
                    validator: (p) => p.isNotEmpty,
                  ),
                  SizedBox(height: layout.formPadding.groupBottomDistance),
                  PasswordInput(
                    key: TestKey.createAccountPasswordConfirm,
                    inputHeading: t.confirmPassword,
                    password: state.secondPassword,
                    onPasswordChange: (password) => context
                        .read<CreateAccountCubit>()
                        .secondPasswordChanged(password),
                    errorState: state.conformPasswordFailure,
                    validator: (p) => p.isNotEmpty,
                  ),
                  SizedBox(height: layout.login.termsPadding),
                  AcceptTermsSwitch(
                    key: TestKey.acceptTermsOfUse,
                    linkText: t.termsOfUse,
                    value: state.termsOfUse,
                    url: t.termsOfUseUrl,
                    errorState: state.termsOfUseFailure,
                    onChanged: (v) => context
                        .read<CreateAccountCubit>()
                        .termsOfUseAccepted(v),
                  ),
                  SizedBox(height: layout.formPadding.verticalItemDistance),
                  AcceptTermsSwitch(
                    key: TestKey.acceptPrivacyPolicy,
                    linkText: t.privacyPolicy,
                    value: state.privacyPolicy,
                    url: t.privacyPolicyUrl,
                    errorState: state.privacyPolicyFailure,
                    onChanged: (v) => context
                        .read<CreateAccountCubit>()
                        .privacyPolicyAccepted(v),
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
  static const abiliaUrl = 'https://www.abilia.com/';

  final String linkText, url;
  final bool value;
  final ValueChanged<bool> onChanged;
  final bool errorState;

  const AcceptTermsSwitch({
    Key? key,
    required this.linkText,
    required this.url,
    required this.value,
    required this.onChanged,
    required this.errorState,
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
                ..onTap = () => showViewDialog(
                      context: context,
                      builder: (_) => WebViewDialog(url: '$abiliaUrl$url'),
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
  const MyAbiliaLogo({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CreateAccountCubit, CreateAccountState>(
      builder: (context, state) {
        if (state is CreateAccountLoading) {
          return SizedBox(
            width: layout.login.logoSize,
            height: layout.login.logoSize,
            child: CircularProgressIndicator(
              valueColor: const AlwaysStoppedAnimation(AbiliaColors.red),
              strokeWidth: layout.login.progressWidth,
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
  const BackToLoginButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LightButton(
      icon: AbiliaIcons.navigationPrevious,
      text: Translator.of(context).translate.backToLogin,
      onPressed: Navigator.of(context).maybePop,
    );
  }
}

class CreateAccountButton extends StatelessWidget {
  const CreateAccountButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CreateAccountCubit, CreateAccountState>(
      builder: (context, state) {
        return GreenButton(
          icon: AbiliaIcons.ok,
          text: Translator.of(context).translate.createAccount,
          onPressed: state is! CreateAccountLoading
              ? () => context
                  .read<CreateAccountCubit>()
                  .createAccountButtonPressed()
              : null,
        );
      },
    );
  }
}

extension CreateAccountErrorMessage on CreateAccountFailed {
  String errorMessage(Translated translate) {
    switch (failure) {
      case CreateAccountFailure.noUsername:
        return translate.enterUsername;
      case CreateAccountFailure.usernameToShort:
        return translate.usernameToShort;
      case CreateAccountFailure.noPassword:
        return translate.enterPassword;
      case CreateAccountFailure.passwordToShort:
        return translate.passwordToShort;
      case CreateAccountFailure.noConfirmPassword:
        return translate.confirmPassword;
      case CreateAccountFailure.passwordMismatch:
        return translate.passwordMismatch;
      case CreateAccountFailure.termsOfUse:
        return translate.confirmTermsOfUse;
      case CreateAccountFailure.privacyPolicy:
        return translate.confirmPrivacyPolicy;
      case CreateAccountFailure.usernameTaken:
        return translate.usernameTaken;
      case CreateAccountFailure.noConnection:
        return translate.noConnection;
      default:
        return translate.unknownError;
    }
  }
}
