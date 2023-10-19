import 'package:android_intent_plus/android_intent.dart';
import 'package:carymessenger/l10n/generated/l10n.dart';

import 'package:carymessenger/ui/components/buttons/action.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:package_info_plus/package_info_plus.dart';

class GooglePlayButton extends StatelessWidget {
  const GooglePlayButton({super.key});

  @override
  Widget build(BuildContext context) {
    return ActionButtonBlack(
      onPressed: () async => AndroidIntent(
        action: 'action_view',
        data: Uri.encodeFull(
          'market://details?id=${GetIt.I<PackageInfo>().packageName}',
        ),
      ).launch(),
      text: Lt.of(context).check_for_updates,
    );
  }
}
