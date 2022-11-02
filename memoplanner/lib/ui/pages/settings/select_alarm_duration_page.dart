import 'dart:io';

import 'package:seagull/models/all.dart';
import 'package:seagull/ui/all.dart';
import 'package:seagull/utils/all.dart';

class SelectAlarmDurationPage extends StatefulWidget {
  final AlarmDuration duration;
  final IconData appBarIcon;
  final String appBarTitle;
  final String? appBarLabel;
  const SelectAlarmDurationPage({
    required this.duration,
    required this.appBarIcon,
    required this.appBarTitle,
    this.appBarLabel,
    Key? key,
  }) : super(key: key);

  @override
  State createState() => _SelectAlarmDurationPageState();
}

class _SelectAlarmDurationPageState extends State<SelectAlarmDurationPage> {
  late AlarmDuration selectedAlarmDuration;

  @override
  void initState() {
    super.initState();
    selectedAlarmDuration = widget.duration;
  }

  @override
  Widget build(BuildContext context) {
    final t = Translator.of(context).translate;
    final widgets = [
      CollapsableWidget(
        collapsed: Platform.isAndroid ||
            selectedAlarmDuration.duration() <=
                iOSPersistentNotificationMaxDuration,
        padding:
            EdgeInsets.only(bottom: layout.formPadding.verticalItemDistance),
        child: ErrorMessage(text: Text(t.iOSAlarmTimeWarning)),
      ),
      ...AlarmDuration.values.map(
        (d) => RadioField<AlarmDuration>(
          groupValue: selectedAlarmDuration,
          onChanged: setSelectedAlarmDuration,
          value: d,
          text: Text(d.displayText(t)),
        ),
      )
    ];
    return Scaffold(
      appBar: AbiliaAppBar(
        iconData: widget.appBarIcon,
        title: widget.appBarTitle,
        label: widget.appBarLabel,
      ),
      body: ListView.separated(
        padding: EdgeInsets.fromLTRB(
          layout.templates.m1.left,
          layout.formPadding.groupBottomDistance,
          layout.templates.m1.right,
          layout.formPadding.groupBottomDistance,
        ),
        itemBuilder: (context, i) => widgets[i],
        itemCount: widgets.length,
        separatorBuilder: (context, index) => SizedBox(
          height: layout.formPadding.verticalItemDistance,
        ),
      ),
      bottomNavigationBar: BottomNavigation(
        backNavigationWidget: const CancelButton(),
        forwardNavigationWidget: OkButton(
          onPressed: () =>
              Navigator.of(context).maybePop(selectedAlarmDuration),
        ),
      ),
    );
  }

  void setSelectedAlarmDuration(AlarmDuration? d) {
    if (d != null) setState(() => selectedAlarmDuration = d);
  }
}
