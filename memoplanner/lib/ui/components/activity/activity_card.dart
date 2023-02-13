import 'package:memoplanner/bloc/all.dart';
import 'package:memoplanner/models/all.dart';
import 'package:memoplanner/ui/all.dart';
import 'package:memoplanner/utils/all.dart';

class ActivityCard extends StatelessWidget {
  final ActivityOccasion activityOccasion;

  final bool preview, showCategoryColor, showInfoIcons, useOpacity;

  static const Duration duration = Duration(seconds: 1);

  const ActivityCard({
    required this.activityOccasion,
    this.preview = false,
    this.showCategoryColor = false,
    this.showInfoIcons = true,
    this.useOpacity = false,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final activity = activityOccasion.activity;
    final signedOff = activityOccasion.isSignedOff && !preview;
    final current = activityOccasion.isCurrent && !preview;
    final past = activityOccasion.isPast && !preview;
    final inactive = past || signedOff;
    final hasSideContent = activity.hasImage || signedOff || past;
    final showAvailableForIcon = context.select(
        (SupportPersonsCubit cubit) => cubit.state.supportPersons.isNotEmpty);
    final bodyText4 = layout.eventCard.bodyText4.copyWith(
      color: inactive ? AbiliaColors.white140 : null,
      height: 1,
    );
    final themeData = abiliaTheme.copyWith(
      iconTheme: abiliaTheme.iconTheme.copyWith(
        color: inactive ? AbiliaColors.white140 : null,
      ),
    );

    return AnimatedTheme(
      duration: ActivityCard.duration,
      data: themeData,
      child: Builder(
        builder: (context) {
          return Tts.fromSemantics(
            activity.semanticsProperties(context),
            child: Opacity(
              opacity: useOpacity ? (signedOff || past ? 0.3 : 0.4) : 1,
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
                              ActivityPage.route(
                                activityDay: activityOccasion,
                                authProviders: authProviders,
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
                                    radius: layout.eventCard.imageRadius,
                                  ),
                                ),
                              ),
                            Expanded(
                              child: Padding(
                                padding: layout.eventCard.titlePadding,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    if (activity.hasTitle) ...[
                                      Text(
                                        activity.title,
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleMedium
                                            ?.copyWith(height: 1),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      SizedBox(
                                          height: layout
                                              .eventCard.titleSubtitleSpacing),
                                    ],
                                    Text(
                                      activity.subtitle(context),
                                      style: bodyText4,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (showInfoIcons)
                          Positioned(
                            right: 0,
                            bottom: 0,
                            child: Padding(
                              padding: layout.eventCard.statusesPadding,
                              child: _buildInfoIcons(
                                activity,
                                inactive,
                                showAvailableForIcon,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoIcons(
    Activity activity,
    bool inactive,
    bool showAvailableForIcon,
  ) =>
      Row(
        children: [
          ...[
            if (activity.checkable) AbiliaIcons.handiCheck,
            if (!activity.fullDay) activity.alarm.iconData(),
            if (!activity.fullDay && activity.reminderBefore.isNotEmpty)
              AbiliaIcons.handiReminder,
            if (activity.hasAttachment) AbiliaIcons.handiInfo,
          ].map((icon) => CardIcon(icon)),
          if (showAvailableForIcon)
            AvailableForIcon(activity.availableFor, inactive),
        ],
      );
}

class CardIcon extends StatelessWidget {
  final IconData icon;

  const CardIcon(
    this.icon, {
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: layout.eventCard.cardIconPadding,
      child: SizedBox(
          height: layout.eventCard.iconContainerSize,
          child: Icon(icon, size: layout.eventCard.iconSize)),
    );
  }
}

class AvailableForIcon extends StatelessWidget {
  final AvailableForType availableFor;
  final bool inactive;

  const AvailableForIcon(
    this.availableFor,
    this.inactive, {
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IconTheme(
      data: Theme.of(context).iconTheme.copyWith(
            color: iconColor,
          ),
      child: AnimatedContainer(
        duration: ActivityCard.duration,
        width: availableFor == AvailableForType.onlyMe
            ? layout.eventCard.iconContainerSize
            : layout.eventCard.iconSize,
        height: layout.eventCard.iconContainerSize,
        decoration: BoxDecoration(
          color: decorationColor,
          borderRadius: borderRadius,
        ),
        child: Icon(
          availableFor.icon,
          size: layout.eventCard.iconSize,
        ),
      ),
    );
  }

  Color get iconColor {
    switch (availableFor) {
      case AvailableForType.onlyMe:
        return inactive ? AbiliaColors.white110 : AbiliaColors.white;
      default:
        return inactive ? AbiliaColors.white140 : AbiliaColors.black75;
    }
  }

  Color get decorationColor {
    switch (availableFor) {
      case AvailableForType.onlyMe:
        return inactive ? AbiliaColors.white140 : AbiliaColors.black75;
      default:
        return inactive ? AbiliaColors.white110 : AbiliaColors.white;
    }
  }
}
