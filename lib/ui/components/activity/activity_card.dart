// @dart=2.9

import 'package:flutter/material.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/utils/all.dart';
import 'package:seagull/ui/all.dart';

class ActivityCard extends StatelessWidget {
  final ActivityOccasion activityOccasion;
  final double bottomPadding;
  final bool preview;
  final bool showCategories;

  static final double cardHeight = 56.0.s,
      cardPadding = 4.0.s,
      cardMarginSmall = 6.0.s,
      cardMarginLarge = 10.0.s,
      imageSize = 48.0.s,
      categorySideOffset = 56.0.s;

  static const Duration duration = Duration(seconds: 1);

  const ActivityCard({
    Key key,
    @required this.activityOccasion,
    this.bottomPadding = 0.0,
    this.preview = false,
    this.showCategories = true,
  })  : assert(activityOccasion != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    final textTheme = abiliaTheme.textTheme;
    final occasion = activityOccasion.occasion;
    final activity = activityOccasion.activity;
    final signedOff = activityOccasion.isSignedOff && !preview;
    final current = occasion == Occasion.current && !preview;
    final past = occasion == Occasion.past && !preview;
    final inactive = past || signedOff;
    final themeData = inactive
        ? abiliaTheme.copyWith(
            textTheme: textTheme.copyWith(
              bodyText1:
                  textTheme.bodyText1.copyWith(color: AbiliaColors.white140),
            ),
            iconTheme:
                abiliaTheme.iconTheme.copyWith(color: AbiliaColors.white140))
        : abiliaTheme;
    return AnimatedTheme(
      duration: duration,
      data: themeData,
      child: Builder(
        builder: (context) => Padding(
          padding: EdgeInsets.only(bottom: bottomPadding),
          child: Tts.fromSemantics(
            activity.semanticsProperties(context),
            child: AnimatedContainer(
              duration: duration,
              height: cardHeight,
              decoration: getBoxDecoration(current, inactive),
              margin: preview || activity.fullDay || !showCategories
                  ? EdgeInsets.zero
                  : activity.category == Category.right
                      ? EdgeInsets.only(left: categorySideOffset)
                      : EdgeInsets.only(right: categorySideOffset),
              child: Material(
                type: MaterialType.transparency,
                child: InkWell(
                  borderRadius:
                      borderRadius.subtract(BorderRadius.circular(1.0)),
                  onTap: preview
                      ? null
                      : () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => CopiedAuthProviders(
                                blocContext: context,
                                child: ActivityPage(occasion: activityOccasion),
                              ),
                              settings: RouteSettings(
                                  name: 'ActivityPage $activityOccasion'),
                            ),
                          );
                        },
                  child: Padding(
                    padding: EdgeInsets.all(cardPadding),
                    child: Stack(
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: <Widget>[
                            if (activity.hasImage || signedOff || past)
                              ActivityImage.fromActivityOccasion(
                                activityOccasion: activityOccasion,
                                size: imageSize,
                                fit: BoxFit.cover,
                              ),
                            Expanded(
                              child: Padding(
                                padding: EdgeInsets.only(left: cardPadding),
                                child: Stack(children: <Widget>[
                                  if (activity.hasTitle)
                                    Text(
                                      activity.title,
                                      style:
                                          Theme.of(context).textTheme.subtitle1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  Align(
                                    alignment: Alignment.bottomLeft,
                                    child: Text(
                                      activity.subtitle(context),
                                      style:
                                          Theme.of(context).textTheme.bodyText1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ]),
                              ),
                            ),
                          ],
                        ),
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: buildInfoIcons(activity, inactive),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildInfoIcons(Activity activity, bool inactive) => Row(
        children: [
          ...[
            if (activity.checkable) AbiliaIcons.handi_check,
            if (!activity.fullDay) activity.alarm.iconData(),
            if (!activity.fullDay && activity.reminderBefore.isNotEmpty)
              AbiliaIcons.handi_reminder,
            if (activity.hasAttachment) AbiliaIcons.handi_info,
          ].map((icon) => CardIcon(icon)),
          if (activity.secret) PrivateIcon(inactive),
        ],
      );
}

class CardIcon extends StatelessWidget {
  final IconData icon;
  static final EdgeInsets padding = EdgeInsets.only(right: 4.0.s);
  static final double iconSize = 18.0.s;
  const CardIcon(
    this.icon, {
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Icon(icon, size: iconSize),
    );
  }
}

class PrivateIcon extends StatelessWidget {
  final bool inactive;
  const PrivateIcon(
    this.inactive, {
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      margin: CardIcon.padding,
      duration: ActivityCard.duration,
      width: 24.s,
      height: 24.s,
      decoration: BoxDecoration(
        color: inactive ? AbiliaColors.white140 : AbiliaColors.black75,
        borderRadius: borderRadius,
      ),
      child: Icon(
        AbiliaIcons.password_protection,
        size: CardIcon.iconSize,
        color: inactive ? AbiliaColors.white110 : AbiliaColors.white,
      ),
    );
  }
}
