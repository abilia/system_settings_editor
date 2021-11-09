import 'package:flutter/services.dart';
import 'package:seagull/logging.dart';
import 'package:seagull/ui/all.dart';
import 'package:seagull/ui/components/quick_settings/sound_effects_switch.dart';
import 'package:seagull/utils/strings.dart';
import 'package:system_settings_editor/system_settings_editor.dart';

class QuickSettingsPage extends StatelessWidget {
  const QuickSettingsPage({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final t = Translator.of(context).translate;
    return Scaffold(
      appBar: AbiliaAppBar(
        title: t.quickSettingsMenu.singleLine,
        iconData: AbiliaIcons.settings,
      ),
      body: Column(
        children: const [
          BrightnessSlider(),
          SoundEffectsSwitch(),
        ],
      ),
      bottomNavigationBar:
          const BottomNavigation(backNavigationWidget: PreviousButton()),
    );
  }
}

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
    WidgetsBinding.instance?.addObserver(this);
    initBrightness();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      initBrightness();
    }
  }

  void initBrightness() async {
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
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SubHeading(t.screenBrightness),
              AbiliaSlider(
                  leading: const Icon(AbiliaIcons.brightnessNormal),
                  value: _brightness,
                  onChanged: (double b) {
                    setState(() {
                      _brightness = b;
                      SystemSettingsEditor.setBrightness(b);
                    });
                  }),
            ],
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance?.removeObserver(this);
    super.dispose();
  }
}
