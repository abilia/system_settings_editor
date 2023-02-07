import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:get_it/get_it.dart';
import 'package:package_info/package_info.dart';

import 'package:memoplanner/db/all.dart';
import 'package:memoplanner/models/license.dart';
import 'package:memoplanner/ui/all.dart';
import 'package:memoplanner/utils/all.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final translate = Translator.of(context).translate;
    return Scaffold(
      appBar: AbiliaAppBar(
        title: translate.aboutMemoplanner,
        label: Config.isMP ? translate.system : null,
        iconData: AbiliaIcons.information,
      ),
      body: const AboutContent(),
      bottomNavigationBar: const BottomNavigation(
        backNavigationWidget: PreviousButton(),
      ),
    );
  }
}

class AboutContent extends StatelessWidget {
  final bool updateButton;

  const AboutContent({Key? key, this.updateButton = true}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final scrollController = ScrollController();
    final textTheme = Theme.of(context).textTheme;
    return ScrollArrows.vertical(
      controller: scrollController,
      child: DefaultTextStyle(
        style: textTheme.bodyLarge ?? bodyLarge,
        child: ListView(
          controller: scrollController,
          children: [
            const AboutMemoplannerColumn(),
            const Divider(),
            const LoggedInAccountColumn(),
            const Divider(),
            const AboutDeviceColumn(),
            const Divider(),
            const ProducerColumn(),
            if (Config.isMP && updateButton) ...[
              SizedBox(height: layout.formPadding.groupTopDistance),
              const Divider(),
              SizedBox(height: layout.formPadding.groupTopDistance),
              const SearchForUpdateButton().pad(m1ItemPadding),
            ],
            SizedBox(height: layout.templates.m1.bottom),
          ],
        ),
      ),
    );
  }
}

class AboutMemoplannerColumn extends StatelessWidget {
  const AboutMemoplannerColumn({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final translate = Translator.of(context).translate;
    final textTheme = Theme.of(context).textTheme;
    final license = GetIt.I<DeviceDb>().getDeviceLicense();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${translate.aboutMemoplanner} ${Config.flavor.name}',
          style: textTheme.titleLarge,
        ).withTts().pad(layout.templates.m1.withoutBottom),
        SizedBox(height: layout.formPadding.groupBottomDistance),
        DoubleText(
          translate.version,
          Version.versionText(GetIt.I<PackageInfo>()),
          bold: true,
        ),
        DoubleText(
          translate.licenseNumber,
          license != null ? _licenseKey(license) : '',
        ),
        DoubleText(
          translate.licenseValidDate,
          license != null ? _licenseValidDate(license) : '',
        ),
        SizedBox(height: layout.formPadding.groupBottomDistance),
      ],
    );
  }

  String _licenseKey(License license) {
    return license.key;
  }

  String _licenseValidDate(License license) {
    final dateString = license.endTime.toString();
    return dateString.substring(0, dateString.indexOf(' '));
  }
}

class LoggedInAccountColumn extends StatelessWidget {
  const LoggedInAccountColumn({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final translate = Translator.of(context).translate;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: layout.formPadding.groupTopDistance),
        DoubleText(translate.loggedInUser, _username(GetIt.I<UserDb>()),
            vertical: true),
        SizedBox(height: layout.formPadding.groupBottomDistance),
      ],
    );
  }

  String _username(UserDb userDb) => userDb.getUser()?.username ?? '';
}

class AboutDeviceColumn extends StatelessWidget {
  const AboutDeviceColumn({Key? key}) : super(key: key);

  Future<BaseDeviceInfo?> deviceInfo() async {
    final deviceInfo = DeviceInfoPlugin();
    if (Platform.isAndroid) {
      final androidInfo = await deviceInfo.androidInfo;
      return androidInfo;
    } else if (Platform.isIOS) {
      final iosInfo = await deviceInfo.iosInfo;
      return iosInfo;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final translate = Translator.of(context).translate;
    final textTheme = Theme.of(context).textTheme;
    return FutureBuilder(
      future: deviceInfo(),
      builder: (context, snapshot) {
        final deviceInfo = snapshot.data;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              translate.aboutDevice,
              style: textTheme.titleLarge,
            ).withTts().pad(layout.templates.m1.withoutBottom),
            SizedBox(height: layout.formPadding.groupBottomDistance),
            if (Config.isMP)
              DoubleText(
                  translate.serialNumber, _serialNumber(GetIt.I<DeviceDb>())),
            if (deviceInfo is AndroidDeviceInfo) ...[
              DoubleText(translate.deviceName, deviceInfo.model),
              DoubleText(translate.androidVersion, deviceInfo.version.release),
            ],
            if (deviceInfo is IosDeviceInfo) ...[
              if (deviceInfo.utsname.machine != null)
                DoubleText(
                    translate.deviceName, deviceInfo.utsname.machine ?? ''),
              if (deviceInfo.systemVersion != null)
                DoubleText(
                    translate.iosVersion, deviceInfo.systemVersion ?? ''),
            ],
            SizedBox(height: layout.formPadding.groupBottomDistance),
          ],
        );
      },
    );
  }

  String _serialNumber(DeviceDb deviceDb) => deviceDb.serialId.toString();
}

class ProducerColumn extends StatelessWidget {
  const ProducerColumn({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final translate = Translator.of(context).translate;
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          translate.producer,
          style: textTheme.titleLarge,
        ).withTts().pad(layout.templates.m1.withoutBottom),
        Text(
          'Abilia AB',
          style: textTheme.titleMedium,
        ).withTts().pad(layout.templates.s2.withoutBottom),
        const Text('Råsundavägen 6, 169 67 Solna, Sweden')
            .withTts()
            .pad(layout.templates.s2.withoutBottom),
        const Text('+46 (0)8- 594 694 00\n'
                'info@abilia.com\n'
                'www.abilia.com')
            .withTts()
            .pad(m1ItemPadding),
        SizedBox(height: layout.formPadding.groupBottomDistance),
        const Text(
          'This product is developed in accordance with and complies to '
          'all necessary requirements, regulations and directives for '
          'medical devices.',
        ).withTts().pad(m1ItemPadding),
      ],
    );
  }
}

class SearchForUpdateButton extends StatelessWidget {
  const SearchForUpdateButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final translate = Translator.of(context).translate;
    return Tts.data(
      data: translate.searchForUpdate,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minWidth: double.infinity),
        child: TextButton(
          style: textButtonStyleGreen,
          onPressed: AndroidIntents.openPlayStore,
          child: Text(translate.searchForUpdate),
        ),
      ),
    );
  }
}

class DoubleText extends StatelessWidget {
  final String text1;
  final String text2;
  final bool vertical;
  final bool bold;

  const DoubleText(
    this.text1,
    this.text2, {
    this.vertical = false,
    this.bold = false,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final defaultTextStyle = textTheme.bodyLarge ?? bodyLarge;
    final textStyle = bold
        ? defaultTextStyle.copyWith(fontWeight: FontWeight.bold)
        : defaultTextStyle.copyWith(color: AbiliaColors.black75);
    final spacing = vertical
        ? layout.about.verticalTextSpacing
        : layout.about.horizontalTextSpacing;
    return _rowOrColumn(
      [
        Text('$text1:').withTts(),
        SizedBox(width: spacing),
        Text(text2, style: textStyle).withTts(),
      ],
    ).pad(
      layout.templates.m1.onlyHorizontal.copyWith(
        bottom: layout.about.smallTextSpacing,
      ),
    );
  }

  Widget _rowOrColumn(List<Widget> children) {
    return vertical
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.start, children: children)
        : Row(children: children);
  }
}
