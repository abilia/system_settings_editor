import 'package:get_it/get_it.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/repository/all.dart';
import 'package:seagull/ui/all.dart';
import 'package:seagull/utils/all.dart';

class LongPressInfoDialog extends StatelessWidget {
  const LongPressInfoDialog({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final translate = Translator.of(context).translate;
    return ViewDialog(
      bodyPadding: layout.templates.m4,
      expanded: true,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          const Spacer(flex: 128),
          Stack(children: [
            const _Preview(),
            Align(
              alignment: Alignment.bottomCenter,
              child: Icon(
                AbiliaIcons.speakOnEntry,
                size: layout.icon.huge,
              ),
            ),
          ]),
          const Spacer(flex: 80),
          Tts(
            child: Text(
              translate.longpressToSpeak,
              textAlign: TextAlign.center,
              style: abiliaTextTheme.headline6,
            ),
          ),
          Tts(
            child: Text(
              translate.longPressInfoText,
              textAlign: TextAlign.center,
              style:
                  (Theme.of(context).textTheme.bodyText2 ?? bodyText2).copyWith(
                color: AbiliaColors.black75,
              ),
            ),
          ),
          const Spacer(flex: 111),
        ],
      ),
      backNavigationWidget: CloseButton(
        onPressed: () => Navigator.of(context).maybePop(false),
      ),
    );
  }
}

class _Preview extends StatelessWidget {
  const _Preview({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final time = GetIt.I<Ticker>().time;
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: layout.formPadding.horizontalItemDistance,
      ),
      child: ActivityCard(
        activityOccasion: ActivityOccasion(
          Activity.createNew(
            title: Translator.of(context).translate.lunch,
            startTime: time.withTime(const TimeOfDay(hour: 12, minute: 0)),
          ),
          time.onlyDays(),
          Occasion.future,
        ),
        preview: true,
      ),
    );
  }
}
