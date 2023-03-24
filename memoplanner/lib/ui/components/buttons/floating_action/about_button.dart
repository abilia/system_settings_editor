import 'package:memoplanner/ui/all.dart';

class AboutButton extends StatelessWidget {
  const AboutButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InfoButton(
      onTap: () => showViewDialog(
        context: context,
        wrapWithAuthProviders: false,
        builder: (_) => const AboutDialog(),
        routeSettings: (AboutDialog).routeSetting(),
      ),
    ).pad(layout.menuPage.aboutButtonPadding);
  }
}
