import 'package:android_intent_plus/android_intent.dart';
import 'package:android_intent_plus/flag.dart';
import 'package:carymessenger/ui/components/buttons/action.dart';
import 'package:flutter/material.dart';

class AndroidSettingsButton extends StatelessWidget {
  const AndroidSettingsButton({super.key});

  @override
  Widget build(BuildContext context) => ActionButtonBlack(
        onPressed: () async => const AndroidIntent(
          action: 'android.settings.SETTINGS',
          flags: [Flag.FLAG_ACTIVITY_NEW_TASK, Flag.FLAG_ACTIVITY_CLEAR_TASK],
        ).launch(),
        text: 'Android settings',
      );
}
