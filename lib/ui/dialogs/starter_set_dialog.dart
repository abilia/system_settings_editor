import 'package:seagull/ui/all.dart';

class StartedSetDialog extends StatelessWidget {
  const StartedSetDialog({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final translate = Translator.of(context).translate;
    return ViewDialog(
      bodyPadding: layout.templates.m4,
      expanded: true,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              FadeInImage(
                fadeInDuration: const Duration(milliseconds: 50),
                fadeInCurve: Curves.linear,
                placeholder: MemoryImage(kTransparentImage),
                image: AssetImage(
                  'assets/graphics/${Config.flavor.id}/starter_set.png',
                ),
              ),
              if (Config.isMP) SizedBox(height: 36) else SizedBox(height: 24),
              Tts(
                child: Text(
                  translate.installStarterSet,
                  style: Theme.of(context).textTheme.headline6,
                ),
              ),
              if (Config.isMP) SizedBox(height: 16) else SizedBox(height: 9),
              Tts(
                child: Text(
                  translate.doYouWantToImportADefaultSet,
                  style: Theme.of(context).textTheme.bodyText2,
                ),
              ),
            ],
          )
        ],
      ),
      backNavigationWidget: const NoButton(),
      forwardNavigationWidget: const YesButton(),
    );
  }
}
