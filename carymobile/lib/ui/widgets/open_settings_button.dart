import 'package:android_intent_plus/android_intent.dart';
import 'package:android_intent_plus/flag.dart';
import 'package:flutter/material.dart';

class OpenSettingsButton extends StatelessWidget {
  const OpenSettingsButton({super.key});

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: () async => const AndroidIntent(
        action: 'android.settings.SETTINGS',
        flags: [Flag.FLAG_ACTIVITY_NEW_TASK, Flag.FLAG_ACTIVITY_CLEAR_TASK],
      ).launch(),
      child: const Text('Android settings'),
    );
  }
}
