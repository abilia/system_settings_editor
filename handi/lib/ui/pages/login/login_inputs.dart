part of 'login_page.dart';

class _UsernameLoginInput extends StatelessWidget {
  final MessageState? messageState;

  const _UsernameLoginInput({
    required this.messageState,
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
      ),
    );
  }
}

class _PasswordLoginInput extends StatelessWidget {
  final MessageState? messageState;
  final IconData? helperBoxIcon;
  final String? helperBoxMessage;

  const _PasswordLoginInput({
    required this.messageState,
    required this.helperBoxIcon,
    required this.helperBoxMessage,
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
        helperBoxIcon:
            messageState == MessageState.error ? helperBoxIcon : null,
        helperBoxMessage:
            messageState == MessageState.error ? helperBoxMessage : null,
      ),
    );
  }
}
