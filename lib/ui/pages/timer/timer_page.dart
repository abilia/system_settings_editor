import 'package:seagull/bloc/all.dart';
import 'package:seagull/models/abilia_timer.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/ui/all.dart';

class TimerPage extends StatelessWidget {
  final AbiliaTimer timer;
  final DateTime day;

  const TimerPage({
    Key? key,
    required this.timer,
    required this.day,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: DayAppBar(day: day),
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
              _TopInfo(timer: timer),
              Divider(
                endIndent: 0,
                indent: layout.timerPage.topVerticalPadding,
              ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.all(layout.timerPage.mainContentPadding),
                  child: TimerWheel.nonInteractive(
                    secondsLeft: timer.duration.inSeconds,
                    lengthInMinutes: timer.duration.inMinutes,
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

    return SizedBox(
      height: layout.timerPage.topInfoHeight,
      child: Padding(
        padding: EdgeInsets.symmetric(
          vertical: layout.timerPage.topVerticalPadding,
          horizontal: layout.timerPage.topHorizontalPadding,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            if (timer.hasImage)
              Padding(
                padding: EdgeInsets.only(right: layout.timerPage.imagePadding),
                child: FadeInCalendarImage(
                  width: layout.timerPage.imageSize,
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
        ),
      ),
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
            IconActionButtonLight(
              onPressed: () => Navigator.of(context).maybePop(),
              child: const Icon(AbiliaIcons.navigationPrevious),
            )
          ]
              .map((b) => [const Spacer(), b, const Spacer()])
              .expand((w) => w)
              .toList(),
        ),
      ),
    );
  }
}
