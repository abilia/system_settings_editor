part of 'login_page.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final ScrollController _scrollController = ScrollController();
  final userNameKey = GlobalKey();
  final passwordKey = GlobalKey();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final spacings = AbiliaTheme.of(context).spacings;
    final loginFailureCause = context.select((LoginCubit cubit) {
      final state = cubit.state;
      return state is LoginFailure ? state.cause : null;
    });

    final helperBoxIcon = _getHelperBoxIcon(loginFailureCause);
    final helperBoxMessage = _getHelperBoxMessage(context, loginFailureCause);
    final messageState = _getMessageState(loginFailureCause);
    return SafeArea(
      child: SingleChildScrollView(
        controller: _scrollController,
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: spacings.spacing400,
            vertical: spacings.spacing600,
          ),
          child: Column(
            children: [
              const LogoWithChangeServer(),
              SizedBox(height: spacings.spacing800),
              const _WelcomeToHandiText(),
              SizedBox(height: spacings.spacing800),
              _UsernameLoginInput(
                key: userNameKey,
                scrollController: _scrollController,
                onFocused: () async => _onInputFocused(userNameKey),
                messageState: messageState,
              ),
              SizedBox(height: spacings.spacing300),
              _PasswordLoginInput(
                key: passwordKey,
                scrollController: _scrollController,
                onFocused: () async => _onInputFocused(passwordKey),
                messageState: messageState,
                helperBoxIcon: helperBoxIcon,
                helperBoxMessage: helperBoxMessage,
              ),
              SizedBox(height: spacings.spacing600),
              const _LoginButton(),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _onInputFocused(GlobalKey key) async {
    final inputObject = key.currentContext?.findRenderObject();
    if (inputObject == null) return;
    await Future.delayed(const Duration(milliseconds: 250));
    await _scrollController.position.ensureVisible(
      inputObject,
      alignment: 0.5,
      duration: const Duration(milliseconds: 500),
    );
  }
}

IconData? _getHelperBoxIcon(LoginFailureCause? failureCause) {
  if (failureCause == null) return null;
  switch (failureCause) {
    case LoginFailureCause.noUsername:
    case LoginFailureCause.noPassword:
    case LoginFailureCause.credentials:
    case LoginFailureCause.licenseExpired:
    case LoginFailureCause.noLicense:
    case LoginFailureCause.unsupportedUserType:
    case LoginFailureCause.noConnection:
    case LoginFailureCause.notEmptyDatabase:
      return Symbols.error;
    case LoginFailureCause.tooManyAttempts:
      return Symbols.lightbulb;
  }
}

String? _getHelperBoxMessage(
  BuildContext context,
  LoginFailureCause? failureCause,
) {
  final translate = Lt.of(context);
  if (failureCause == null) return null;
  switch (failureCause) {
    case LoginFailureCause.noUsername:
    case LoginFailureCause.noPassword:
    case LoginFailureCause.credentials:
      return translate.verifyCredentials;
    case LoginFailureCause.licenseExpired:
      return translate.lincenseExpired;
    case LoginFailureCause.noLicense:
      return translate.noHandiLicence;
    case LoginFailureCause.unsupportedUserType:
      return translate.unsupportedUserType;
    case LoginFailureCause.tooManyAttempts:
      return translate.tooManyAttempts;
    case LoginFailureCause.noConnection:
      return translate.connectToInternet;
    case LoginFailureCause.notEmptyDatabase:
      return translate.somethingWentWrong;
  }
}

MessageState? _getMessageState(LoginFailureCause? failureCause) {
  if (failureCause == null) return null;
  switch (failureCause) {
    case LoginFailureCause.noUsername:
    case LoginFailureCause.noPassword:
    case LoginFailureCause.credentials:
    case LoginFailureCause.licenseExpired:
    case LoginFailureCause.noLicense:
    case LoginFailureCause.unsupportedUserType:
    case LoginFailureCause.notEmptyDatabase:
      return MessageState.error;
    case LoginFailureCause.tooManyAttempts:
    case LoginFailureCause.noConnection:
      return MessageState.caution;
  }
}

class _WelcomeToHandiText extends StatelessWidget {
  const _WelcomeToHandiText();

  @override
  Widget build(BuildContext context) {
    return Text(
      Lt.of(context).welcomeToHandi,
      style: AbiliaTheme.of(context).textStyles.primary525,
      textAlign: TextAlign.center,
    );
  }
}

class _UsernameLoginInput extends StatelessWidget {
  final MessageState? messageState;
  final ScrollController scrollController;
  final VoidCallback onFocused;

  const _UsernameLoginInput({
    required this.messageState,
    required this.scrollController,
    required this.onFocused,
    required super.key,
  });

  @override
  Widget build(BuildContext context) {
    final translate = Lt.of(context);
    final username = context.select((LoginCubit cubit) => cubit.state.username);
    return Tooltip(
      message: translate.userNameOrEmail,
      child: SeagullComboBox(
        label: translate.userNameOrEmail,
        size: ComboBoxSize.medium,
        leadingIcon: Symbols.account_circle,
        maxLength: 128,
        trailingIcon: username.isNotEmpty ? Symbols.play_circle : null,
        onTrailingIconOnTap: () async => GetIt.I<TtsHandler>().speak(username),
        textInputAction: TextInputAction.next,
        onChanged: context.read<LoginCubit>().usernameChanged,
        messageState: messageState,
        onFocused: onFocused,
      ),
    );
  }
}

class _PasswordLoginInput extends StatelessWidget {
  final MessageState? messageState;
  final IconData? helperBoxIcon;
  final String? helperBoxMessage;
  final ScrollController scrollController;
  final VoidCallback onFocused;

  const _PasswordLoginInput({
    required this.messageState,
    required this.helperBoxIcon,
    required this.helperBoxMessage,
    required this.scrollController,
    required this.onFocused,
    required super.key,
  });

  @override
  Widget build(BuildContext context) {
    final translate = Lt.of(context);
    final obscurePassword =
        context.select((LoginCubit cubit) => cubit.state.obscurePassword);
    return Tooltip(
      message: translate.password,
      child: SeagullComboBox(
        label: translate.password,
        size: ComboBoxSize.medium,
        leadingIcon: Symbols.key,
        trailingIcon: Symbols.visibility,
        obscureText: obscurePassword,
        maxLength: 128,
        onTrailingIconOnTap: context.read<LoginCubit>().toggleObscurePassword,
        onChanged: context.read<LoginCubit>().passwordChanged,
        onSubmitted: (_) async =>
            context.read<LoginCubit>().loginButtonPressed(),
        messageState: messageState,
        helperBoxIcon: helperBoxIcon,
        helperBoxMessage: helperBoxMessage,
        onFocused: onFocused,
      ),
    );
  }
}

class _LoginButton extends StatelessWidget {
  const _LoginButton();

  @override
  Widget build(BuildContext context) {
    final isLoading =
        context.select((LoginCubit cubit) => cubit.state is LoginLoading);
    final isFormValid =
        context.select((LoginCubit cubit) => cubit.state.isFormValid);
    return SizedBox(
      width: double.infinity,
      child: SeagullActionButton(
        text: Lt.of(context).signIn,
        type: ActionButtonType.primary,
        size: ButtonSize.medium,
        isLoading: isLoading,
        leadingIcon: Symbols.login,
        onPressed: isFormValid
            ? () async {
                FocusScope.of(context).requestFocus(FocusNode());
                await context.read<LoginCubit>().loginButtonPressed();
              }
            : null,
      ),
    );
  }
}
