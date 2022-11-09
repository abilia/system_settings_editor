import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:memoplanner/i18n/app_localizations.dart';
import 'package:memoplanner/logging.dart';
import 'package:memoplanner/ui/components/all.dart';
import 'package:memoplanner/ui/widget_test_keys.dart';
import 'package:system_settings_editor/system_settings_editor.dart';

class BrightnessSlider extends StatefulWidget {
  const BrightnessSlider({Key? key}) : super(key: key);

  @override
  State<BrightnessSlider> createState() => _BrightnessSliderState();
}

class _BrightnessSliderState extends State<BrightnessSlider>
    with WidgetsBindingObserver {
  final _log = Logger((_BrightnessSliderState).toString());
  double _brightness = 1.0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    initBrightness();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      initBrightness();
    }
  }

  Future<void> initBrightness() async {
    try {
      final b = await SystemSettingsEditor.brightness;
      setState(() {
        _brightness = b ?? 0;
      });
    } on PlatformException catch (e) {
      _log.warning('Could not get brightness', e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = Translator.of(context).translate;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SubHeading(t.screenBrightness),
        AbiliaSlider(
            key: TestKey.brightnessSlider,
            leading: const Icon(AbiliaIcons.brightnessNormal),
            value: _brightness,
            onChanged: (double b) {
              setState(() {
                _brightness = b;
                SystemSettingsEditor.setBrightness(b);
              });
            }),
      ],
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
}
