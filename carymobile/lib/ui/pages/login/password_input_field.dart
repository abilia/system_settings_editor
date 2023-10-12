part of 'login_page.dart';

class PasswordInputField extends StatefulWidget {
  const PasswordInputField({super.key});

  @override
  State<PasswordInputField> createState() => _PasswordInputFieldState();
}

class _PasswordInputFieldState extends State<PasswordInputField> {
  bool obscureText = true;
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Password'),
        const SizedBox(height: 4),
        Tooltip(
          message: 'Password',
          child: TextField(
            style: inputTextStyle,
            obscureText: obscureText,
            obscuringCharacter: '*',
            enableIMEPersonalizedLearning: false,
            autocorrect: false,
            spellCheckConfiguration: const SpellCheckConfiguration.disabled(),
            decoration: InputDecoration(
              suffixIcon: GestureDetector(
                child: obscureText
                    ? const Icon(AbiliaIcons.show, size: 32)
                    : const Icon(AbiliaIcons.hide, size: 32),
                onTap: () => setState(() => obscureText = !obscureText),
              ),
            ),
            onChanged: context.read<LoginCubit>().passwordChanged,
          ),
        ),
      ],
    );
  }
}
