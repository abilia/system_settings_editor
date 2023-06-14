import 'package:auth/models/exceptions.dart';
import 'package:memoplanner/bloc/all.dart';
import 'package:memoplanner/repository/all.dart';
import 'package:memoplanner/ui/all.dart';

class CreateAccountPage extends StatelessWidget {
  static const maxUsernameLength = 20;

  final UserRepository userRepository;

  const CreateAccountPage({
    required this.userRepository,
    Key? key,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final t = Lt.of(context);
    final textTheme = Theme.of(context).textTheme;
    return BlocProvider(
      create: (context) => CreateAccountCubit(
        languageTag: Localizations.localeOf(context).toLanguageTag(),
        repository: userRepository,
      ),
      child: MultiBlocListener(
        listeners: [
          BlocListener<CreateAccountCubit, CreateAccountState>(
            listenWhen: (previous, current) => current is AccountCreated,
            listener: (context, state) async {
              final navigator = Navigator.of(context);
              await showViewDialog(
                context: context,
                wrapWithAuthProviders: false,
                builder: (context) => const AccountCreatedDialog(),
                routeSettings: (AccountCreatedDialog).routeSetting(),
              );
              navigator.pop(state.username);
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
                  routeSettings: (ErrorDialog).routeSetting(
                    properties: {'reason': state.failure.name},
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
                      t.createAccountHeading,
                      style: textTheme.titleLarge,
                    ),
                  ),
                  SizedBox(height: layout.formPadding.verticalItemDistance),
                  Tts(
                    child: Text(
                      t.createAccountSubheading,
                      style: textTheme.bodyMedium,
                    ),
                  ),
                  SizedBox(height: layout.formPadding.largeGroupDistance),
                  UsernameInput(
                    initialValue: state.username,
                    errorState: state.usernameFailure,
                    inputValid: (s) =>
                        s.length >= LoginCubit.minUsernameLength &&
                        s.length <= maxUsernameLength,
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

class AccountCreatedDialog extends StatelessWidget {
  const AccountCreatedDialog({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final t = Lt.of(context);
    return ViewDialog(
      heading: AppBarHeading(
        text: t.accountCreatedHeading,
        iconData: AbiliaIcons.ok,
      ),
      body: Tts(child: Text(t.accountCreatedBody)),
      backNavigationWidget: OkButton(onPressed: Navigator.of(context).maybePop),
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
            child: const AbiliaProgressIndicator(),
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
      text: Lt.of(context).backToLogin,
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
          text: Lt.of(context).createAccount,
          onPressed: state is! CreateAccountLoading
              ? () async => context
                  .read<CreateAccountCubit>()
                  .createAccountButtonPressed()
              : null,
        );
      },
    );
  }
}

extension CreateAccountErrorMessage on CreateAccountFailed {
  String errorMessage(Lt translate) {
    switch (failure) {
      case CreateAccountFailure.noUsername:
        return translate.enterUsername;
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
