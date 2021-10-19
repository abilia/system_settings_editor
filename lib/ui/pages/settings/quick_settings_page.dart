import 'package:flutter/services.dart';
import 'package:seagull/logging.dart';
import 'package:seagull/ui/all.dart';
import 'package:seagull/utils/strings.dart';

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
          Text('Hahj'),
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
  static const screenChannel = MethodChannel('abilia.com/screen');
  double _brightness = 1.0;

  @override
  void initState() {
    super.initState();
    initBrightness();
  }

  void initBrightness() async {
    try {
      final b = await screenChannel.invokeMethod('getBrightness');
      setState(() {
        _brightness = b;
      });
    } on PlatformException catch (e) {
      _log.warning('message', e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Slider(
        value: _brightness,
        onChanged: (double b) {
          setState(() {
            _brightness = b;
            screenChannel.invokeMethod('setBrightness', {'brightness': b});
          });
        });
  }
}
