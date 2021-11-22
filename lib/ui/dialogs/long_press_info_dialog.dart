import 'package:seagull/models/all.dart';
import 'package:seagull/ui/all.dart';
import 'package:seagull/utils/all.dart';

class LongPressInfoDialog extends StatelessWidget {
  const LongPressInfoDialog({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final translate = Translator.of(context).translate;
    return ViewDialog(
      bodyPadding: EdgeInsets.symmetric(horizontal: 20.s),
      expanded: true,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          const Spacer(flex: 128),
          Stack(children: [
            buildPreviewActivityCard(translate),
            Align(
              alignment: Alignment.bottomCenter,
              child: Icon(
                AbiliaIcons.speakOnEntry,
                size: Lay.out.iconSize.huge,
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

  Widget buildPreviewActivityCard(Translated translate) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 8.0.s),
      child: ActivityCard(
        activityOccasion: ActivityOccasion(
          Activity.createNew(
            title: translate.lunch,
            startTime:
                DateTime.now().withTime(const TimeOfDay(hour: 12, minute: 0)),
          ),
          DateTime.now(),
          Occasion.future,
        ),
        preview: true,
      ),
    );
  }
}
