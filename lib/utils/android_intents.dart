import 'package:get_it/get_it.dart';
import 'package:intent/flag.dart';
import 'package:intent/intent.dart' as android_intent;
import 'package:package_info/package_info.dart';

class AndroidIntentAction {
  static const settings = 'android.settings.SETTINGS',
      manageOverlay = 'android.settings.action.MANAGE_OVERLAY_PERMISSION';
}

class AndroidIntent {
  static Future<void> openSettings() => (android_intent.Intent()
        ..setAction(AndroidIntentAction.settings)
        ..addFlag(Flag.FLAG_ACTIVITY_EXCLUDE_FROM_RECENTS)
        ..addFlag(Flag.FLAG_ACTIVITY_NO_HISTORY))
      .startActivity();

  static Future<void> openSystemAlertSetting() => (android_intent.Intent()
        ..setAction(AndroidIntentAction.manageOverlay)
        ..setData(
            Uri(scheme: 'package', path: GetIt.I<PackageInfo>().packageName))
        ..addFlag(Flag.FLAG_ACTIVITY_EXCLUDE_FROM_RECENTS)
        ..addFlag(Flag.FLAG_ACTIVITY_NO_HISTORY))
      .startActivity();
}
