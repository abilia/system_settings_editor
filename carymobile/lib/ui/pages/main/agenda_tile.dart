part of 'main_page.dart';

class AgendaTile extends StatelessWidget {
  static const minHeight = 96.0;
  final ActivityDay activity;

  const AgendaTile({required this.activity, super.key});

  @override
  Widget build(BuildContext context) {
    final occasion = context.select(
      (ClockCubit clock) => activity.toOccasion(clock.state).occasion,
    );

    return Tts.data(
      data: '${activity.title}. '
          '${activity.activity.description}. '
          '${analogTimeString(
        Lt.of(context),
        Localizations.localeOf(context).languageCode,
        activity.start,
      )}',
      child: GestureDetector(
        onLongPress: () => context.read<AlarmCubit>().fakeAlarm(activity),
        child: Container(
          constraints: const BoxConstraints(minHeight: minHeight),
          decoration: ShapeDecoration(
            color: occasion.isPast ? abiliaWhite.withOpacity(.6) : abiliaWhite,
            shape: RoundedRectangleBorder(
              side: const BorderSide(width: 1, color: abiliaBrown20),
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    if (activity.hasImage)
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: SizedBox(
                          width: 80,
                          child: Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Opacity(
                                  opacity: occasion.isPast ? .6 : 1,
                                  child: AbiliaImage(
                                    activity.image,
                                    size: ImageSize.thumb,
                                  ),
                                ),
                              ),
                              if (occasion.isPast) const CrossOver(),
                            ],
                          ),
                        ),
                      ),
                    Flexible(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            DateFormat.Hm().format(activity.start),
                            style: timeTextStyle,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            activity.title,
                            style: headLineLarge.copyWith(
                              decoration: occasion.isPast
                                  ? TextDecoration.lineThrough
                                  : null,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                right: 0,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: SideIcons(activity: activity.activity),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SideIcons extends StatelessWidget {
  final Activity activity;

  const SideIcons({required this.activity, super.key});

  @override
  Widget build(BuildContext context) {
    return IconTheme(
      data: const IconThemeData(
        size: 24,
        color: abiliaBlack60,
      ),
      child: Row(
        children: [
          if (activity.extras.startTimeExtraAlarm.isNotEmpty)
            const Icon(AbiliaIcons.dictaphone),
          if (activity.isRecurring) const Icon(AbiliaIcons.repeat),
        ]
            .map(
              (w) => Padding(
                padding: const EdgeInsets.only(right: 8),
                child: w,
              ),
            )
            .toList(),
      ),
    );
  }
}
