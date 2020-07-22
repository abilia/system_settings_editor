import 'package:flutter/material.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/utils/all.dart';
import 'package:seagull/i18n/app_localizations.dart';
import 'package:seagull/ui/colors.dart';
import 'package:seagull/ui/components/all.dart';
import 'package:seagull/ui/theme.dart';

class TimeIllustation extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final translate = Translator.of(context).translate;
    final theme = abiliaTheme;
    return BlocBuilder<SettingsBloc, SettingsState>(
      builder: (context, state) => ViewDialog(
        expanded: false,
        heading:
            Text(translate.activityDuration, style: theme.textTheme.headline6),
        preview:
            TimeIllustationPreview(dotsInTimepillar: state.dotsInTimepillar),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            RadioField<bool>(
              groupValue: state.dotsInTimepillar,
              onChanged: (v) => BlocProvider.of<SettingsBloc>(context)
                  .add(DotsInTimepillarUpdated(v)),
              value: true,
              child: Row(
                children: <Widget>[
                  Icon(AbiliaIcons.options),
                  const SizedBox(width: 12.0),
                  Text(translate.dots),
                ],
              ),
            ),
            const SizedBox(height: 8.0),
            RadioField<bool>(
              groupValue: state.dotsInTimepillar,
              onChanged: (v) => BlocProvider.of<SettingsBloc>(context)
                  .add(DotsInTimepillarUpdated(v)),
              value: false,
              child: Row(
                children: <Widget>[
                  Icon(AbiliaIcons.flarp),
                  const SizedBox(width: 12),
                  Text(translate.edge),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TimeIllustationPreview extends StatelessWidget {
  const TimeIllustationPreview({
    Key key,
    @required this.dotsInTimepillar,
  }) : super(key: key);
  final bool dotsInTimepillar;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12.0, 0.0, 16.0, 0.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              Translator.of(context).translate.preview,
              style: abiliaTheme.textTheme.bodyText1
                  .copyWith(color: AbiliaColors.white),
            ),
            const SizedBox(height: 8.0),
            AnimatedCrossFade(
              key: TestKey.preview,
              firstCurve: Curves.easeInBack,
              secondCurve: Curves.easeOutBack,
              firstChild: Image.asset(
                'assets/graphics/settingsPreviewActivityDurationDots.png',
                key: TestKey.dotsPreview,
              ),
              secondChild: Image.asset(
                'assets/graphics/settingsPreviewActivityDurationFlarps.png',
                key: TestKey.edgePreview,
              ),
              crossFadeState: dotsInTimepillar
                  ? CrossFadeState.showFirst
                  : CrossFadeState.showSecond,
              duration: 400.milliseconds(),
            ),
          ],
        ),
      ),
    );
  }
}
