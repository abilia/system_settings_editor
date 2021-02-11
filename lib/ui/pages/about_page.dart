import 'package:flutter/material.dart';
import 'package:package_info/package_info.dart';
import 'package:seagull/config.dart';

import 'package:seagull/ui/all.dart';
import 'package:seagull/version.dart';

class AboutPage extends StatelessWidget {
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
        style: textTheme.bodyText1,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ...[
              const SizedBox(height: 24.0),
              Text(
                translate.version,
                style:
                    textTheme.bodyText2.copyWith(color: AbiliaColors.black75),
              ),
              const SizedBox(height: 8.0),
              DefaultTextStyle(
                style: textTheme.headline6,
                child: Version(),
              ),
              const Divider(height: 32.0),
              const SizedBox(height: 8.0),
              Text(
                translate.producer,
                style:
                    textTheme.bodyText2.copyWith(color: AbiliaColors.black75),
              ),
              const SizedBox(height: 8.0),
              Text(
                'Abilia AB',
                style: textTheme.headline6,
              ),
              const SizedBox(height: 24.0),
              Text('Råsundavägen 6, 169 67 Solna, Sweden'),
              const SizedBox(height: 8.0),
              Text('+46 (0)8- 594 694 00\n'
                  'info@abilia.com\n'
                  'www.abilia.com'),
              const SizedBox(height: 32.0),
              Text(
                'This product is developed in accordance with and complies to '
                'all necessary requirements, regulations and directives for '
                'medical devices.',
              ),
            ].map(_textToTts).map(_addPadding),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigation(
        backNavigationWidget: PreviousButton(),
      ),
    );
  }

  Widget _textToTts(Widget widget) =>
      widget is Text ? Tts(child: widget) : widget;

  Widget _addPadding(Widget widget) => widget is Divider
      ? widget
      : Padding(
          padding: const EdgeInsets.only(left: 12.0, right: 16.0),
          child: widget,
        );
}

class Version extends StatelessWidget {
  const Version({Key key}) : super(key: key);
  @override
  Widget build(BuildContext context) => FutureBuilder(
        future: PackageInfo.fromPlatform(),
        builder: (context, AsyncSnapshot<PackageInfo> snapshot) => Tts(
          child: Text(snapshot.hasData ? _versionText(snapshot.data) : ''),
        ),
      );

  String _versionText(PackageInfo packageInfo) =>
      '${packageInfo.version}' +
      (VERSION_SUFFIX == 'release' || VERSION_SUFFIX.isEmpty
          ? ''
          : '-$VERSION_SUFFIX') +
      (Config.beta ? ' (${packageInfo.buildNumber})' : '');
}
