import 'package:get_it/get_it.dart';
import 'package:package_info/package_info.dart';

import 'package:seagull/ui/all.dart';
import 'package:seagull/utils/all.dart';
import 'package:seagull/version.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final translate = Translator.of(context).translate;
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AbiliaAppBar(
        title: translate.about,
        iconData: AbiliaIcons.information,
      ),
      body: DefaultTextStyle(
        style: textTheme.bodyText1 ?? bodyText1,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ...[
              Text(
                translate.version,
                style:
                    textTheme.bodyText2?.copyWith(color: AbiliaColors.black75),
              ).pad(m1TopPadding),
              DefaultTextStyle(
                style: textTheme.headline6 ?? headline6,
                child: const Version(),
              ).pad(m1ItemPadding),
              if (Config.isMP) ...[
                const SearchForUpdateButton().pad(m1ItemPadding),
              ],
              SizedBox(height: layout.formPadding.dividerDistance),
              const Divider(),
              Text(
                translate.producer,
                style:
                    textTheme.bodyText2?.copyWith(color: AbiliaColors.black75),
              ).pad(m1TopPadding),
              Text(
                'Abilia AB',
                style: textTheme.headline6,
              ).pad(m1ItemPadding),
              const Text('Råsundavägen 6, 169 67 Solna, Sweden')
                  .pad(m1TopPadding),
              const Text('+46 (0)8- 594 694 00\n'
                      'info@abilia.com\n'
                      'www.abilia.com')
                  .pad(m1ItemPadding),
              SizedBox(height: layout.formPadding.dividerDistance),
              const Text(
                'This product is developed in accordance with and complies to '
                'all necessary requirements, regulations and directives for '
                'medical devices.',
              ).pad(m1ItemPadding),
            ].map(_textToTts),
          ],
        ),
      ),
      bottomNavigationBar: const BottomNavigation(
        backNavigationWidget: PreviousButton(),
      ),
    );
  }

  Widget _textToTts(Widget widget) =>
      widget is Text ? Tts(child: widget) : widget;
}

class SearchForUpdateButton extends StatelessWidget {
  const SearchForUpdateButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final translate = Translator.of(context).translate;
    return Tts.data(
      data: translate.searchForUpdate,
      child: TextButton(
        style: textButtonStyleGreen,
        child: Text(translate.searchForUpdate),
        onPressed: AndroidIntents.openPlayStore,
      ),
    );
  }
}

class Version extends StatelessWidget {
  const Version({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) =>
      Tts(child: Text(_versionText(GetIt.I<PackageInfo>())));

  String _versionText(PackageInfo packageInfo) =>
      packageInfo.version +
      (versionSuffix == 'release' || versionSuffix.isEmpty
          ? ''
          : '-$versionSuffix') +
      (Config.beta ? ' (${packageInfo.buildNumber})' : '');
}
