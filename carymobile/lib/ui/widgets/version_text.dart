import 'package:carymessenger/ui/themes/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:package_info_plus/package_info_plus.dart';

class VersionText extends StatelessWidget {
  const VersionText({super.key});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(8),
        decoration: const ShapeDecoration(
          color: Colors.white,
          shape: StadiumBorder(),
        ),
        child: Text(
          versionText(GetIt.I<PackageInfo>()),
          style: headline4,
        ),
      );

  static String versionText(PackageInfo packageInfo) =>
      '${packageInfo.version} (${packageInfo.buildNumber})';
}
