import 'package:memoplanner/bloc/all.dart';
import 'package:memoplanner/ui/all.dart';

class StarterSetDialog extends StatelessWidget {
  final Function() onNext;
  const StarterSetDialog({required this.onNext, Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final translate = Lt.of(context);
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
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          SizedBox(height: layout.starterSetDialog.headingBodyDistance),
          Tts(
            child: Text(
              translate.doYouWantToImportADefaultSet,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
      backNavigationWidget: NoButton(
        onPressed: onNext,
      ),
      forwardNavigationWidget: YesButton(
        onPressed: () async {
          final language = Localizations.localeOf(context).languageCode;
          await context.read<SortableBloc>().addStarter(language);
          onNext();
        },
      ),
    );
  }
}
