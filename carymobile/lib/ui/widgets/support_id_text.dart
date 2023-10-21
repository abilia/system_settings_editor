import 'package:auth/auth.dart';
import 'package:carymessenger/l10n/generated/l10n.dart';
import 'package:carymessenger/ui/themes/theme.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:seagull_logging/logging.dart';

class SupportIdText extends StatelessWidget {
  const SupportIdText({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      // ignore: discarded_futures
      future: GetIt.I<DeviceDb>().getSupportId(),
      builder: (context, snapshot) => GestureDetector(
        onLongPress: () async => GetIt.I<SeagullLogger>().uploadLogsToBackend(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(Lt.of(context).support_id, style: subHeading),
            const SizedBox(height: 8),
            Text(snapshot.data?.split('-').firstOrNull ?? '', style: heading),
          ],
        ),
      ),
    );
  }
}
