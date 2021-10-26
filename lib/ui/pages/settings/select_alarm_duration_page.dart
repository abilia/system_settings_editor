import 'dart:io';
import 'package:flutter/material.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/ui/all.dart';
import 'package:seagull/utils/all.dart';

class SelectAlarmDurationPage extends StatefulWidget {
  final AlarmDuration duration;
  final IconData appBarIcon;
  final String appBarTitle;

  const SelectAlarmDurationPage({
    Key? key,
    required this.duration,
    required this.appBarIcon,
    required this.appBarTitle,
  }) : super(key: key);

  @override
  _SelectAlarmDurationPageState createState() =>
      _SelectAlarmDurationPageState();
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
            selectedAlarmDuration.duration() <= iOSMaxAlarmDuration,
        padding: EdgeInsets.only(bottom: 8.s),
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
