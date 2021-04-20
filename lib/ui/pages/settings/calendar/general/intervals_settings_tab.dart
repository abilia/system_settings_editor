import 'package:seagull/ui/all.dart';

class IntervalsSettingsTab extends StatelessWidget {
  const IntervalsSettingsTab({Key key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final t = Translator.of(context).translate;
    return SettingsTab(
      children: [
        Tts(child: Text(t.earyMorning)),
        const Divider(),
        Tts(child: Text(t.day)),
        const Divider(),
        Tts(child: Text(t.evening)),
        const Divider(),
        Tts(child: Text(t.night)),
      ].map((e) => e is Divider ? e : Center(child: e)).toList(),
    );
  }
}
