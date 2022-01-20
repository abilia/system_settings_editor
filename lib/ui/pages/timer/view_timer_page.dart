import 'package:seagull/bloc/all.dart';
import 'package:seagull/models/abilia_timer.dart';
import 'package:seagull/ui/all.dart';
import 'package:seagull/utils/datetime.dart';

class ViewTimerPage extends StatelessWidget {
  final AbiliaTimer timer;

  const ViewTimerPage({Key? key, required this.timer}) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
                flex: layout.timerPage.topRowFlex,
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: ActivityInfo.margin,
                    vertical: layout.timerPage.topRowPadding,
                  ),
                  child: _TopInfo(timer: timer),
                ),
              ),
              Divider(
                endIndent: 0,
                indent: ActivityInfo.margin,
              ),
              Flexible(
                flex: layout.timerPage.mainContentFlex,
                child: Padding(
                  padding: EdgeInsets.all(layout.timerPage.mainContentPadding),
                  child: TimerWheel.nonInteractive(
                    activeSeconds: timer.duration.inSeconds,
                    timerLengthInMinutes: timer.duration.inMinutes,
                  ),
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
            padding: EdgeInsets.only(right: ActivityInfo.margin),
            child: FadeInCalendarImage(
              width: layout.timerPage.imageSize,
              height: layout.timerPage.imageSize,
              fit: BoxFit.cover,
              imageFileId: timer.fileId,
            ),
          ),
        Expanded(
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
        height: layout.toolbar.height,
        child: Row(
          children: <Widget>[
            IconActionButtonLight(
              onPressed: () {}, // TODO: add pause/play functionality
              child: const Icon(AbiliaIcons.pause),
            ),
            IconActionButtonLight(
              onPressed: () async {
                final confirmDeletion = await showViewDialog(
                  context: context,
                  builder: (context) => ConfirmWarningDialog(
                    text: Translator.of(context).translate.timerDelete,
                  ),
                );
                if (confirmDeletion) {
                  context.read<TimerCubit>().deleteTimer(timer);
                  Navigator.pop(context);
                }
              },
              child: const Icon(AbiliaIcons.deleteAllClear),
            ),
          ]
              .map((b) => [const Spacer(), b, const Spacer()])
              .expand((w) => w)
              .toList(),
        ),
      ),
    );
  }
}
