import 'package:seagull/bloc/all.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/ui/all.dart';
import 'package:seagull/utils/all.dart';

class ActivityCard extends StatelessWidget {
  final ActivityOccasion activityOccasion;

  final bool preview;
  final bool showCategoryColor;
  final double? crossOverStrokeWidth;
  final Color? crossOverColor;

  static const Duration duration = Duration(seconds: 1);

  const ActivityCard({
    Key? key,
    required this.activityOccasion,
    this.preview = false,
    this.showCategoryColor = false,
    this.crossOverStrokeWidth,
    this.crossOverColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final textTheme = abiliaTheme.textTheme;
    final activity = activityOccasion.activity;
    final signedOff = activityOccasion.isSignedOff && !preview;
    final current = activityOccasion.isCurrent && !preview;
    final past = activityOccasion.isPast && !preview;
    final inactive = past || signedOff;
    final hasSideContent = activity.hasImage || signedOff || past;
    final themeData = inactive
        ? abiliaTheme.copyWith(
            textTheme: textTheme.copyWith(
              bodyText1:
                  textTheme.bodyText1?.copyWith(color: AbiliaColors.white140),
            ),
            iconTheme:
                abiliaTheme.iconTheme.copyWith(color: AbiliaColors.white140))
        : abiliaTheme;
    return AnimatedTheme(
      duration: ActivityCard.duration,
      data: themeData,
      child: Builder(
        builder: (context) => Tts.fromSemantics(
          activity.semanticsProperties(context),
          child: AnimatedContainer(
            duration: ActivityCard.duration,
            height: layout.eventCard.height,
            decoration: getCategoryBoxDecoration(
              current: current,
              inactive: inactive,
              category: activity.category,
              showCategoryColor: showCategoryColor,
            ),
            child: Material(
              type: MaterialType.transparency,
              child: InkWell(
                borderRadius: borderRadius - BorderRadius.circular(1.0),
                onTap: preview
                    ? null
                    : () async {
                        final authProviders = copiedAuthProviders(context);
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => MultiBlocProvider(
                              providers: authProviders,
                              child: ActivityPage(
                                activityDay: activityOccasion,
                              ),
                            ),
                            settings: RouteSettings(
                                name: 'ActivityPage $activityOccasion'),
                          ),
                        );
                      },
                child: Stack(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        if (hasSideContent)
                          Padding(
                            padding: layout.eventCard.imagePadding,
                            child: SizedBox(
                              width: layout.eventCard.imageSize,
                              child: EventImage.fromEventOccasion(
                                eventOccasion: activityOccasion,
                                fit: BoxFit.cover,
                                crossPadding: layout.eventCard.crossPadding,
                                crossOverStrokeWidth: crossOverStrokeWidth,
                                crossOverColor: crossOverColor,
                              ),
                            ),
                          ),
                        Expanded(
                          child: Padding(
                            padding: layout.eventCard.titlePadding,
                            child: Stack(children: <Widget>[
                              if (activity.hasTitle)
                                Text(
                                  activity.title,
                                  style: Theme.of(context).textTheme.subtitle1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              Align(
                                alignment: activity.hasTitle
                                    ? Alignment.bottomLeft
                                    : Alignment.centerLeft,
                                child: Text(
                                  activity.subtitle(context),
                                  style: Theme.of(context).textTheme.bodyText1,
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
                      child: Padding(
                        padding: layout.eventCard.statusesPadding,
                        child: buildInfoIcons(activity, inactive),
                      ),
                    ),
                  ],
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
            if (activity.checkable) AbiliaIcons.handiCheck,
            if (!activity.fullDay) activity.alarm.iconData(),
            if (!activity.fullDay && activity.reminderBefore.isNotEmpty)
              AbiliaIcons.handiReminder,
            if (activity.hasAttachment) AbiliaIcons.handiInfo,
          ].map((icon) => CardIcon(icon)),
          if (activity.secret) PrivateIcon(inactive),
        ],
      );
}

class CardIcon extends StatelessWidget {
  final IconData icon;
  static final EdgeInsets padding = EdgeInsets.only(right: 4.0.s);

  const CardIcon(
    this.icon, {
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Icon(icon, size: layout.eventCard.iconSize),
    );
  }
}

class PrivateIcon extends StatelessWidget {
  final bool inactive;

  const PrivateIcon(
    this.inactive, {
    Key? key,
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
        AbiliaIcons.passwordProtection,
        size: layout.eventCard.iconSize,
        color: inactive ? AbiliaColors.white110 : AbiliaColors.white,
      ),
    );
  }
}
