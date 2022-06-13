import 'package:seagull/ui/all.dart';

class StarterSetDialog extends StatelessWidget {
  const StarterSetDialog({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final translate = Translator.of(context).translate;
    return ViewDialog(
      bodyPadding: layout.templates.m4,
      expanded: true,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FadeInImage(
            fadeInDuration: const Duration(milliseconds: 50),
            fadeInCurve: Curves.linear,
            placeholder: MemoryImage(kTransparentImage),
            image: AssetImage(
              'assets/graphics/${Config.flavor.id}/starter_set.png',
            ),
          ),
          SizedBox(height: layout.starterSetDialog.imageHeadingDistance),
          Tts(
            child: Text(
              translate.installStarterSet,
              style: Theme.of(context).textTheme.headline6,
            ),
          ),
          SizedBox(height: layout.starterSetDialog.headingBodyDistance),
          Tts(
            child: Text(
              translate.doYouWantToImportADefaultSet,
              style: Theme.of(context).textTheme.bodyText2,
            ),
          ),
        ],
      ),
      backNavigationWidget: const NoButton(),
      forwardNavigationWidget: const YesButton(),
    );
  }
}
