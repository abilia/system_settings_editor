import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:package_info_plus/package_info_plus.dart';

class VersionText extends StatelessWidget {
  const VersionText({super.key});

  @override
  Widget build(BuildContext context) =>
      Text(versionText(GetIt.I<PackageInfo>()));

  static String versionText(PackageInfo packageInfo) =>
      '${packageInfo.version} (${packageInfo.buildNumber})';
}
