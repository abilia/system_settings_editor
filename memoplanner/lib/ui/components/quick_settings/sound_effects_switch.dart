import 'package:flutter/services.dart';
import 'package:seagull/logging.dart';
import 'package:seagull/ui/all.dart';
import 'package:system_settings_editor/system_settings_editor.dart';

class SoundEffectsSwitch extends StatefulWidget {
  const SoundEffectsSwitch({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _SoundEffectSwitchState();
  }
}

class _SoundEffectSwitchState extends State<SoundEffectsSwitch> {
  final _log = Logger((_SoundEffectSwitchState).toString());
  bool _on = false;

  @override
  void initState() {
    super.initState();
    initSetting();
  }

  @override
  Widget build(BuildContext context) {
    return SwitchField(
      leading: Icon(
        AbiliaIcons.touch,
        size: layout.icon.small,
      ),
      value: _on,
      onChanged: (switchOn) {
        setState(() {
          _on = switchOn;
          SystemSettingsEditor.setSoundEffectsEnabled(switchOn);
        });
      },
      child: Text(Translator.of(context).translate.clickSound),
    );
  }

  void initSetting() async {
    try {
      final on = await SystemSettingsEditor.soundEffectsEnabled;
      setState(() {
        _on = on ?? false;
      });
    } on PlatformException catch (e) {
      _log.warning('Could not get sound effects setting', e);
    }
  }
}
