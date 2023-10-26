part of 'login_page.dart';

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
                FocusManager.instance.primaryFocus?.unfocus();
                await context.read<LoginCubit>().loginButtonPressed();
              }
            : null,
      ),
    );
  }
}
