import 'package:android_intent_plus/android_intent.dart';
import 'package:carymessenger/l10n/generated/l10n.dart';
import 'package:carymessenger/ui/abilia_icons.dart';
import 'package:carymessenger/ui/components/buttons/action.dart';
import 'package:carymessenger/ui/components/cary_app_bar.dart';
import 'package:carymessenger/ui/components/cary_bottom_bar.dart';
import 'package:carymessenger/ui/themes/theme.dart';
import 'package:carymessenger/ui/widgets/buttons/back_button.dart';
import 'package:carymessenger/ui/widgets/support_id_text.dart';
import 'package:carymessenger/ui/widgets/version_text.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:package_info_plus/package_info_plus.dart';

part 'search_for_update_button.dart';
part 'producer_text.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CaryAppBar(
        topPadding: MediaQuery.paddingOf(context).top,
        icon: const Icon(AbiliaIcons.information),
        title: Lt.of(context).about,
      ),
      bottomNavigationBar: const CaryBottomBar(child: CaryBackButton()),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16.0),
        children: const [
          VersionText(),
          SizedBox(height: 16),
          SearchForUpdateButton(),
          Divider(),
          SupportIdText(),
          Divider(),
          ProducerText(),
        ],
      ),
    );
  }
}
