import 'package:carymessenger/copied_providers.dart';
import 'package:carymessenger/l10n/all.dart';
import 'package:carymessenger/ui/abilia_icons.dart';
import 'package:carymessenger/ui/components/buttons/action.dart';
import 'package:carymessenger/ui/pages/settings/hidden_extra.dart';
import 'package:carymessenger/ui/pages/settings/settings_page.dart';
import 'package:carymessenger/ui/widgets/buttons/close_button.dart';
import 'package:flutter/material.dart' hide CloseButton;
import 'package:flutter_bloc/flutter_bloc.dart';

class SettingsMenu extends StatefulWidget {
  const SettingsMenu({super.key});

  @override
  State<SettingsMenu> createState() => _SettingsMenuState();
}

class _SettingsMenuState extends State<SettingsMenu> {
  bool showFakeTime = false;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: Container(
        decoration: const ShapeDecoration(
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(16),
              bottomRight: Radius.circular(16),
            ),
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ActionButtonWhite(
                  onPressed: () async {
                    final authProviders = copiedAuthProviders(context);
                    await Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => MultiBlocProvider(
                          providers: authProviders,
                          child: const SettingsPage(),
                        ),
                      ),
                    );
                  },
                  onLongPress: () => setState(
                    () => showFakeTime = !showFakeTime,
                  ),
                  text: Lt.of(context).settings,
                  leading: const Icon(AbiliaIcons.settings),
                ),
                const SizedBox(height: 12),
                if (showFakeTime) ...[
                  const FakeTime(),
                  const SizedBox(height: 12),
                ],
                const CaryCloseButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
