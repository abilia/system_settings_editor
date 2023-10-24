import 'package:android_intent_plus/android_intent.dart';
import 'package:android_intent_plus/flag.dart';
import 'package:auth/db/user_db.dart';
import 'package:carymessenger/copied_providers.dart';
import 'package:carymessenger/l10n/all.dart';
import 'package:carymessenger/ui/abilia_icons.dart';
import 'package:carymessenger/ui/components/buttons/picker.dart';
import 'package:carymessenger/ui/components/cary_app_bar.dart';
import 'package:carymessenger/ui/components/cary_bottom_bar.dart';
import 'package:carymessenger/ui/components/myabilia_icon.dart';
import 'package:carymessenger/ui/pages/about/about_page.dart';
import 'package:carymessenger/ui/pages/myAbilia/myabilia_page.dart';
import 'package:carymessenger/ui/themes/colors.dart';
import 'package:carymessenger/ui/themes/theme.dart';
import 'package:carymessenger/ui/widgets/buttons/close_button.dart';
import 'package:connectivity/connectivity_cubit.dart';
import 'package:flutter/material.dart' hide CloseButton;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

part 'about_picker_button.dart';

part 'myabilia_picker_button.dart';

part 'wifi_picker_button.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CaryAppBar(
        topPadding: MediaQuery.paddingOf(context).top,
        title: Lt.of(context).settings,
        icon: const Icon(AbiliaIcons.settings),
      ),
      bottomNavigationBar: const CaryBottomBar(
        child: CaryCloseButton(),
      ),
      body: const Padding(
        padding: EdgeInsets.symmetric(vertical: 24, horizontal: 16.0),
        child: Column(
          children: [
            WifiPickerButton(),
            SizedBox(height: 12),
            MyAbiliaPickerButton(),
            SizedBox(height: 12),
            AboutPickerButton(),
          ],
        ),
      ),
    );
  }
}
