part of 'settings_page.dart';

class AboutPickerButton extends StatelessWidget {
  const AboutPickerButton({super.key});

  @override
  Widget build(BuildContext context) {
    return PickerButtonWhite(
      leading: const Icon(AbiliaIcons.information),
      leadingText: Lt.of(context).about,
      onPressed: () async => Navigator.of(context)
          .push(MaterialPageRoute(builder: (context) => const AboutPage())),
    );
  }
}
