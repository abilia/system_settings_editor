part of 'login_page.dart';

class UsernameInputField extends StatelessWidget {
  const UsernameInputField({super.key});

  @override
  Widget build(BuildContext context) {
    final translate = Lt.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(translate.username_email, style: body),
        const SizedBox(height: 4),
        Tooltip(
          message: translate.username_email,
          child: TextField(
            style: inputTextStyle,
            decoration: const InputDecoration(
              suffixIcon: Icon(AbiliaIcons.navigationNext, size: 32),
            ),
            onChanged: context.read<LoginCubit>().usernameChanged,
            textInputAction: TextInputAction.next,
            keyboardType: TextInputType.emailAddress,
          ),
        ),
      ],
    );
  }
}
