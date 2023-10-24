part of 'login_page.dart';

class LogoWithChangeServer extends StatelessWidget {
  const LogoWithChangeServer({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Image.asset('assets/graphics/cary_login.png'),
      onLongPress: () async => showModalBottomSheet(
        context: context,
        builder: (context) => Padding(
          padding: const EdgeInsets.all(8.0),
          child: Wrap(
            children: [
              const Center(child: SupportIdText()),
              const Center(child: VersionText()),
              ...backendEnvironments.entries.map(
                (kvp) => Builder(
                  builder: (context) => RadioMenuButton(
                    value: kvp.key,
                    onChanged: (s) async =>
                        context.read<BaseUrlCubit>().updateBaseUrl(kvp.key),
                    groupValue: context.watch<BaseUrlCubit>().state,
                    child: Text(kvp.value),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
