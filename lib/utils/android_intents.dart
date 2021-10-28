import 'package:get_it/get_it.dart';
import 'package:android_intent_plus/android_intent.dart';
import 'package:android_intent_plus/flag.dart';
import 'package:package_info/package_info.dart';

class AndroidIntentAction {
  static const settings = 'android.settings.SETTINGS',
      manageOverlay = 'android.settings.action.MANAGE_OVERLAY_PERMISSION';
}

class AndroidIntents {
  static Future<void> openSettings() => const AndroidIntent(
        action: AndroidIntentAction.settings,
        flags: [
          Flag.FLAG_ACTIVITY_EXCLUDE_FROM_RECENTS,
          Flag.FLAG_ACTIVITY_NO_HISTORY
        ],
      ).launch();

  static Future<void> openSystemAlertSetting() => AndroidIntent(
        action: AndroidIntentAction.manageOverlay,
        data: Uri(scheme: 'package', path: GetIt.I<PackageInfo>().packageName)
            .toString(),
        flags: [
          Flag.FLAG_ACTIVITY_EXCLUDE_FROM_RECENTS,
          Flag.FLAG_ACTIVITY_NO_HISTORY
        ],
      ).launch();
}
