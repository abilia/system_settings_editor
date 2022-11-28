import 'package:memoplanner/bloc/all.dart';
import 'package:memoplanner/ui/all.dart';
import 'package:memoplanner/utils/all.dart';

class HiddenSetting extends StatefulWidget {
  const HiddenSetting({Key? key}) : super(key: key);

  @override
  State createState() => _HiddenSettingState();
}

class _HiddenSettingState extends State<HiddenSetting> {
  bool rightTapped = false, leftTapped = false;
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        GestureDetector(
          key: TestKey.hiddenSettingsButtonLeft,
          behavior: HitTestBehavior.translucent,
          onTap: () async {
            if (!leftTapped) {
              leftTapped = true;
              rightTapped = false;
            } else if (rightTapped) {
              leftTapped = false;
              rightTapped = false;
              final navigator = Navigator.of(context);
              final authProviders = copiedAuthProviders(context);
              final accessGranted = await codeProtectAccess(
                context,
                restricted: (codeSettings) => codeSettings.protectSettings,
                name: Translator.of(context).translate.settings,
              );
              if (accessGranted) {
                navigator.push(MaterialPageRoute(
                  builder: (_) => MultiBlocProvider(
                    providers: authProviders,
                    child: const SettingsPage(),
                  ),
                  settings:
                      const RouteSettings(name: 'SettingsPage from hidden'),
                ));
              }
            }
          },
          child: SizedBox(
            width: layout.actionButton.size,
            height: layout.actionButton.size,
          ),
        ),
        GestureDetector(
          key: TestKey.hiddenSettingsButtonRight,
          behavior: HitTestBehavior.translucent,
          onTap: () {
            if (leftTapped && !rightTapped) {
              rightTapped = true;
            } else if (rightTapped) {
              leftTapped = false;
              rightTapped = false;
            }
          },
          child: SizedBox(
            width: layout.actionButton.size,
            height: layout.actionButton.size,
          ),
        ),
      ],
    );
  }
}