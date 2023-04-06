import 'package:android_intent_plus/android_intent.dart';
import 'package:android_intent_plus/flag.dart';
import 'package:get_it/get_it.dart';
import 'package:package_info_plus/package_info_plus.dart';

class AndroidIntentAction {
  static const settings = 'android.settings.SETTINGS',
      manageOverlay = 'android.settings.action.MANAGE_OVERLAY_PERMISSION',
      deviceInfo = 'android.settings.DEVICE_INFO_SETTINGS',
      wifi = 'android.settings.WIFI_SETTINGS',
      writeSettings = 'android.settings.action.MANAGE_WRITE_SETTINGS',
      homeButton = 'android.intent.action.MAIN';
}

class AndroidIntents {
  static Future<void> openSettings() => const AndroidIntent(
        action: AndroidIntentAction.settings,
        flags: [Flag.FLAG_ACTIVITY_NEW_TASK, Flag.FLAG_ACTIVITY_CLEAR_TASK],
      ).launch();

  static Future<void> openSystemAlertSetting() => AndroidIntent(
        action: AndroidIntentAction.manageOverlay,
        flags: [Flag.FLAG_ACTIVITY_NEW_TASK, Flag.FLAG_ACTIVITY_CLEAR_TASK],
        data: Uri(scheme: 'package', path: GetIt.I<PackageInfo>().packageName)
            .toString(),
      ).launch();

  static Future<void> openWifiSettings() => const AndroidIntent(
        action: AndroidIntentAction.wifi,
        flags: [Flag.FLAG_ACTIVITY_NEW_TASK, Flag.FLAG_ACTIVITY_CLEAR_TASK],
      ).launch();

  static Future<void> openDeviceInfoSettings() => const AndroidIntent(
        action: AndroidIntentAction.deviceInfo,
        flags: [Flag.FLAG_ACTIVITY_NEW_TASK, Flag.FLAG_ACTIVITY_CLEAR_TASK],
      ).launch();

  static Future<void> openWriteSettingsPermissionSettings() => AndroidIntent(
        action: AndroidIntentAction.writeSettings,
        flags: [Flag.FLAG_ACTIVITY_NEW_TASK, Flag.FLAG_ACTIVITY_CLEAR_TASK],
        data: Uri.encodeFull(
          'package:${GetIt.I<PackageInfo>().packageName}',
        ),
      ).launch();

  static Future<void> openPlayStore() => AndroidIntent(
        action: 'action_view',
        data: Uri.encodeFull(
          'market://details?id=${GetIt.I<PackageInfo>().packageName}',
        ),
      ).launch();
}
