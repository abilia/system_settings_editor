import 'package:android_intent_plus/android_intent.dart';
import 'package:android_intent_plus/flag.dart';
import 'package:carymessenger/l10n/generated/l10n.dart';
import 'package:carymessenger/ui/abilia_icons.dart';
import 'package:carymessenger/ui/components/buttons/action.dart';
import 'package:carymessenger/ui/themes/theme.dart';
import 'package:flutter/material.dart';

part 'wifi_button.dart';

class ConnectToWifiPage extends StatelessWidget {
  const ConnectToWifiPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 40, top: 64, right: 40),
              child: Column(
                children: [
                  Image.asset('assets/graphics/wifi_connect.png'),
                  const SizedBox(height: 40),
                  Text(
                    Lt.of(context).onboarding_hint,
                    style: headlineSmall,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: WifiButton(),
            ),
          ],
        ),
      ),
    );
  }
}
