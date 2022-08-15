import 'package:seagull/models/all.dart';
import 'package:seagull/ui/all.dart';

class SelectSoundPage extends StatefulWidget {
  final Sound sound;
  final IconData appBarIcon;
  final String appBarTitle;
  final String? appBarLabel;
  final bool noSoundOption;

  const SelectSoundPage({
    required this.sound,
    required this.appBarIcon,
    required this.appBarTitle,
    this.appBarLabel,
    this.noSoundOption = false,
    Key? key,
  }) : super(key: key);

  @override
  State createState() => _SelectSoundPageState();
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
        .where((s) => widget.noSoundOption || s != Sound.NoSound)
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
                  padding: EdgeInsets.only(
                    left: layout.formPadding.largeHorizontalItemDistance,
                  ),
                  child: PlayAlarmSoundButton(sound: s),
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
        label: widget.appBarLabel,
      ),
      body: ListView.separated(
        padding: layout.templates.m1,
        itemBuilder: (context, i) => widgets[i],
        itemCount: widgets.length,
        separatorBuilder: (context, index) => SizedBox(
          height: layout.formPadding.verticalItemDistance,
        ),
      ),
      bottomNavigationBar: BottomNavigation(
        backNavigationWidget: const CancelButton(),
        forwardNavigationWidget: OkButton(
          onPressed: () => Navigator.of(context).maybePop(selectedSound),
        ),
      ),
    );
  }

  void setSelectedSound(Sound? s) => setState(() => selectedSound = s);
}
