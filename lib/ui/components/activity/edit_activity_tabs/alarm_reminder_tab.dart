import 'package:seagull/models/all.dart';
import 'package:seagull/ui/all.dart';
import 'package:seagull/ui/components/activity/record_sound_widgets.dart';

class AlarmAndReminderTab extends StatefulWidget {
  const AlarmAndReminderTab({
    Key? key,
    required this.activity,
  }) : super(key: key);

  final Activity activity;

  @override
  _AlarmAndReminderTabState createState() => _AlarmAndReminderTabState();
}

class _AlarmAndReminderTabState extends State<AlarmAndReminderTab>
    with EditActivityTab {
  late final ScrollController _scrollController;
  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  Widget build(BuildContext context) {
    return VerticalScrollArrows(
      controller: _scrollController,
      child: ListView(
        controller: _scrollController,
        padding:
            EditActivityTab.rightPadding.add(EditActivityTab.bottomPadding),
        children: <Widget>[
          separatedAndPadded(
            AlarmWidget(widget.activity),
          ),
          separatedAndPadded(
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                SubHeading(Translator.of(context).translate.reminders),
                ReminderSwitch(activity: widget.activity),
                CollapsableWidget(
                  padding: EdgeInsets.only(top: 8.0.s),
                  collapsed: widget.activity.fullDay ||
                      widget.activity.reminderBefore.isEmpty,
                  child: Reminders(activity: widget.activity),
                ),
              ],
            ),
          ),
          padded(
            RecordSoundWidget(activity: widget.activity),
          ),
        ],
      ),
    );
  }
}
