import 'package:intent/flag.dart';
import 'package:intent/intent.dart' as android_intent;
import 'package:package_info/package_info.dart';

Future<void> openAndroidSettings() => (android_intent.Intent()
      ..setAction('android.settings.SETTINGS')
      ..addFlag(Flag.FLAG_ACTIVITY_EXCLUDE_FROM_RECENTS)
      ..addFlag(Flag.FLAG_ACTIVITY_NO_HISTORY))
    .startActivity();

Future<void> openSystemAlertSetting() =>
    PackageInfo.fromPlatform().then((packageInfo) => (android_intent.Intent()
          ..setAction('android.settings.action.MANAGE_OVERLAY_PERMISSION')
          ..setData(Uri(scheme: 'package', path: packageInfo.packageName))
          ..addFlag(Flag.FLAG_ACTIVITY_EXCLUDE_FROM_RECENTS)
          ..addFlag(Flag.FLAG_ACTIVITY_NO_HISTORY))
        .startActivity());
