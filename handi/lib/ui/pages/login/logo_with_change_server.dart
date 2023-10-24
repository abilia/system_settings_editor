part of 'login_page.dart';

class LogoWithChangeServer extends StatelessWidget {
  const LogoWithChangeServer({super.key});

  @override
  Widget build(BuildContext context) {
    final ablilaTheme = AbiliaTheme.of(context);
    final spacings = ablilaTheme.spacings;
    final colors = ablilaTheme.colors;
    return GestureDetector(
      child: Container(
        height: spacings.spacing1000,
        width: spacings.spacing1000,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(spacings.spacing300),
          boxShadow: [
            BoxShadow(
              color: colors.primary.shade200,
              spreadRadius: spacings.spacing100,
            ),
          ],
        ),
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
