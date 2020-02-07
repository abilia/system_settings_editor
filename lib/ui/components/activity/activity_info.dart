import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/i18n/app_localizations.dart';
import 'package:seagull/ui/colors.dart';
import 'package:seagull/ui/components/all.dart';
import 'package:seagull/ui/theme.dart';

class ActivityInfo extends StatelessWidget {
  final ActivityOccasion occasion;
  const ActivityInfo({Key key, this.occasion}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeData = weekDayTheme[occasion.day.weekday];
    final timeFormat = DateFormat('jm', Locale.cachedLocale.languageCode);
    final hasImage = occasion.activity.fileId?.isNotEmpty ?? false;
    final hasAttachment = occasion.activity.infoItem?.isNotEmpty ?? false;
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Container(
        decoration: BoxDecoration(
            color: AbiliaColors.white,
            borderRadius: BorderRadius.all(
              const Radius.circular(12.0),
            )),
        constraints: BoxConstraints.expand(),
        child: Column(
          children: <Widget>[
            Flexible(
              flex: 5,
              child: TopInfo(
                  occasion: occasion,
                  themeData: themeData,
                  timeFormat: timeFormat),
            ),
            if (hasAttachment)
              Flexible(
                flex: 8,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                  child: Container(
                    child: Center(
                      child: Text('Attachment'),
                    ),
                    decoration: BoxDecoration(
                        color: AbiliaColors.white[110],
                        borderRadius: BorderRadius.all(
                          const Radius.circular(12.0),
                        )),
                  ),
                ),
              ),
            if (hasImage && !hasAttachment)
              Flexible(
                flex: 8,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                  child: FadeInCalenderImage(
                    imageFileId: occasion.activity.fileId,
                    width: 327.0,
                    height: 289.0,
                  ),
                ),
              )
          ],
        ),
      ),
    );
  }
}

class TopInfo extends StatelessWidget {
  const TopInfo({
    Key key,
    @required this.occasion,
    @required this.themeData,
    @required this.timeFormat,
  }) : super(key: key);

  final ActivityOccasion occasion;
  final ThemeData themeData;
  final DateFormat timeFormat;

  @override
  Widget build(BuildContext context) {
    final hasImage = occasion.activity.fileId?.isNotEmpty ?? false;
    final hasAttachment = occasion.activity.infoItem?.isNotEmpty ?? false;
    final hasTitle = occasion.activity.title?.isNotEmpty ?? false;
    final imageToTheLeft = hasImage && hasAttachment && hasTitle;
    final imageBelow = hasImage && hasAttachment && !hasTitle;
    return Row(
      mainAxisAlignment:
          imageToTheLeft ? MainAxisAlignment.start : MainAxisAlignment.center,
      children: <Widget>[
        if (imageToTheLeft)
          Padding(
            padding: const EdgeInsets.only(left: 12.0),
            child: FadeInCalenderImage(
              imageFileId: occasion.activity.fileId,
              height: 109,
              width: 109,
            ),
          ),
        Column(
          crossAxisAlignment: imageToTheLeft
              ? CrossAxisAlignment.start
              : CrossAxisAlignment.center,
          mainAxisAlignment:
              imageBelow ? MainAxisAlignment.end : MainAxisAlignment.center,
          children: <Widget>[
            if (occasion.activity.title?.isNotEmpty ?? false)
              Text(
                occasion.activity.title,
                style: themeData.textTheme.headline,
              ),
            Text(
              occasion.activity.fullDay
                  ? Translator.of(context).translate.fullDay
                  : occasion.activity.hasEndTime
                      ? '${timeFormat.format(occasion.activity.start)} - ${timeFormat.format(occasion.activity.end)}'
                      : '${timeFormat.format(occasion.activity.start)}',
              style: themeData.textTheme.subhead.copyWith(
                color: AbiliaColors.black,
              ),
            ),
            if (imageBelow)
              Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: FadeInCalenderImage(
                  imageFileId: occasion.activity.fileId,
                  height: 109,
                  width: 109,
                ),
              )
          ],
        ),
      ],
    );
  }
}
