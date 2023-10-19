part of 'login_page.dart';

class LogoWithChangeServer extends StatelessWidget {
  const LogoWithChangeServer({super.key});

  @override
  Widget build(BuildContext context) {
    final spacings = AbiliaTheme.of(context).spacings;
    return GestureDetector(
      child: SizedBox.square(
        dimension: spacings.spacing1000,
        child: Image.asset('assets/handi_logo_android.png'),
      ),
      onLongPress: () async => showModalBottomSheet(
        context: context,
        builder: (context) => Wrap(
          children: backendEnvironments.entries
              .map(
                (kvp) => Builder(
                  builder: (context) => RadioMenuButton(
                    value: kvp.key,
                    onChanged: (s) async =>
                        context.read<BaseUrlCubit>().updateBaseUrl(kvp.key),
                    groupValue: context.watch<BaseUrlCubit>().state,
                    child: Text(kvp.value),
                  ),
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}
