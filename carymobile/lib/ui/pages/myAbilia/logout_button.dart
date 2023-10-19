part of 'myabilia_page.dart';

class LogoutButton extends StatelessWidget {
  const LogoutButton({super.key});

  @override
  Widget build(BuildContext context) {
    return ActionButtonRed(
      onPressed: () =>
          context.read<AuthenticationBloc>().add(const LoggedOut()),
      text: Lt.of(context).log_out,
    );
  }
}
