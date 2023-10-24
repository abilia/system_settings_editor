part of 'settings_page.dart';

class MyAbiliaPickerButton extends StatelessWidget {
  const MyAbiliaPickerButton({super.key});

  @override
  Widget build(BuildContext context) {
    final user = GetIt.I<UserDb>().getUser();
    return PickerButtonWhite(
      leading: const MyAbiliaIcon(),
      leadingText: 'myAbilia',
      trailing: user != null ?
       Text(
        user.username,
        overflow: TextOverflow.ellipsis,
        textAlign: TextAlign.end,
      ) : null,
      onPressed: () async {
        final authProviders = copiedAuthProviders(context);
        await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => MultiBlocProvider(
              providers: authProviders,
              child: const MyAbiliaPage(),
            ),
          ),
        );
      },
    );
  }
}
