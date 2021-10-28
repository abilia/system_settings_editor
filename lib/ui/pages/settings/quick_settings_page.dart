import 'package:flutter/services.dart';
import 'package:seagull/logging.dart';
import 'package:seagull/ui/all.dart';
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

class _BrightnessSliderState extends State<BrightnessSlider> {
  final _log = Logger((_BrightnessSliderState).toString());
  double _brightness = 1.0;
  String? version = '';

  @override
  void initState() {
    super.initState();
    initBrightness();
  }

  void initBrightness() async {
    try {
      final b = await SystemSettingsEditor.brightness;
      setState(() {
        _brightness = b ?? 0;
      });
    } on PlatformException catch (e) {
      _log.warning('message', e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = Translator.of(context).translate;
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Text(version ?? ''),
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
}
