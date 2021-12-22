import 'package:seagull/models/abilia_timer.dart';
import 'package:seagull/ui/all.dart';
import 'package:seagull/utils/datetime.dart';

class ViewTimerPage extends StatelessWidget {
  final AbiliaTimer timer;

  const ViewTimerPage({Key? key, required this.timer}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final hasImage = timer.hasImage;
    return Scaffold(
      appBar: DayAppBar(
        day: timer.startTime.onlyDays(),
        leftAction: IconActionButton(
          onPressed: () => Navigator.of(context).maybePop(),
          child: const Icon(AbiliaIcons.navigationPrevious),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(ActivityInfo.margin),
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: borderRadius,
          ),
          constraints: const BoxConstraints.expand(),
          child: Column(
            children: <Widget>[
              Flexible(
                flex: 126,
                child: Padding(
                  padding: EdgeInsets.all(ActivityInfo.margin).subtract(
                    EdgeInsets.only(
                      bottom: hasImage ? 0 : ActivityInfo.margin,
                    ),
                  ),
                  child: _TopInfo(timer: timer),
                ),
              ),
              const Divider(),
              Flexible(
                flex: 298,
                child: Column(
                  // TODO: Replace with timer wheel thing widget
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Center(
                      child: Text(timer.duration.toString(),
                          style: Theme.of(context).textTheme.headline5),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _TimerBottomBar(timer: timer),
    );
  }
}

class _TopInfo extends StatelessWidget {
  const _TopInfo({
    Key? key,
    required this.timer,
  }) : super(key: key);

  final AbiliaTimer timer;

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        if (timer.hasImage)
          Padding(
            padding: EdgeInsets.only(
                left: ActivityInfo.margin, right: ActivityInfo.margin),
            child: FadeInCalendarImage(
              imageFileId: timer.fileId,
              imageFilePath: '',
            ),
          ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.only(bottom: 8.0.s),
                child: Tts(
                  child: Text(
                    timer.title,
                    style: themeData.textTheme.headline5,
                    overflow: TextOverflow.visible,
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _TimerBottomBar extends StatelessWidget {
  const _TimerBottomBar({
    Key? key,
    required this.timer,
  }) : super(key: key);

  final AbiliaTimer timer;

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      child: SizedBox(
        height: layout.toolbar.heigth,
        child: Padding(
          padding: EdgeInsets.only(left: 78.s, right: 69.s),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              IconActionButtonLight(
                onPressed: () {}, // TODO: add pause/play functionality
                child: const Icon(AbiliaIcons.pause),
              ),
              IconActionButtonLight(
                onPressed: () {}, // TODO: add delete functionality
                child: const Icon(AbiliaIcons.deleteAllClear),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
