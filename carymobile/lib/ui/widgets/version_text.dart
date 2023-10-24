import 'package:android_intent_plus/android_intent.dart';
import 'package:android_intent_plus/flag.dart';
import 'package:carymessenger/l10n/generated/l10n.dart';
import 'package:carymessenger/ui/themes/theme.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:package_info_plus/package_info_plus.dart';

class VersionText extends StatelessWidget {
  const VersionText({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: () async => const AndroidIntent(
        action: 'android.settings.SETTINGS',
        flags: [Flag.FLAG_ACTIVITY_NEW_TASK, Flag.FLAG_ACTIVITY_CLEAR_TASK],
      ).launch(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(Lt.of(context).app_version, style: subHeading),
          const SizedBox(height: 8),
          Text(versionText(GetIt.I<PackageInfo>()), style: heading),
        ],
      ),
    );
  }

  static String versionText(PackageInfo packageInfo) =>
      '${packageInfo.version} - ${packageInfo.buildNumber}';
}
