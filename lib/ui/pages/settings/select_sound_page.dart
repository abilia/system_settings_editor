import 'package:flutter/material.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/ui/all.dart';
import 'package:seagull/ui/components/buttons/play_sound_button.dart';

class SelectSoundPage extends StatefulWidget {
  final Sound sound;
  final IconData appBarIcon;
  final String appBarTitle;
  final bool noSoundOption;

  const SelectSoundPage({
    Key? key,
    required this.sound,
    required this.appBarIcon,
    required this.appBarTitle,
    this.noSoundOption = false,
  }) : super(key: key);

  @override
  _SelectSoundPageState createState() => _SelectSoundPageState();
}

class _SelectSoundPageState extends State<SelectSoundPage> {
  Sound? selectedSound;

  @override
  void initState() {
    super.initState();
    selectedSound = widget.sound;
  }

  @override
  Widget build(BuildContext context) {
    final t = Translator.of(context).translate;
    final widgets = Sound.values
        .where((s) => widget.noSoundOption ? true : s != Sound.NoSound)
        .map(
          (s) => Row(
            children: [
              Expanded(
                child: RadioField<Sound>(
                  groupValue: selectedSound,
                  onChanged: setSelectedSound,
                  value: s,
                  text: Text(s.displayName(t)),
                ),
              ),
              CollapsableWidget(
                axis: Axis.horizontal,
                collapsed: !(selectedSound == s && s != Sound.NoSound),
                child: Padding(
                  padding: EdgeInsets.only(left: 12.0.s),
                  child: PlaySoundButton(sound: s),
                ),
              ),
            ],
          ),
        )
        .toList();
    return Scaffold(
      appBar: AbiliaAppBar(
        iconData: widget.appBarIcon,
        title: widget.appBarTitle,
      ),
      body: ListView.separated(
        padding: EdgeInsets.fromLTRB(12.0.s, 20.0.s, 16.0.s, 20.0.s),
        itemBuilder: (context, i) => widgets[i],
        itemCount: widgets.length,
        separatorBuilder: (context, index) => SizedBox(height: 8.0.s),
      ),
      bottomNavigationBar: BottomNavigation(
        backNavigationWidget: CancelButton(),
        forwardNavigationWidget: OkButton(
          onPressed: () => Navigator.of(context).maybePop(selectedSound),
        ),
      ),
    );
  }

  void setSelectedSound(Sound? s) => setState(() => selectedSound = s);
}
