import 'package:seagull/bloc/all.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/ui/all.dart';
import 'package:seagull/utils/all.dart';

class FullScreenActivityPage extends StatelessWidget {
  final ActivityDay activityDay;

  const FullScreenActivityPage({
    Key? key,
    required this.activityDay,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider<FullScreenActivityCubit>(
      create: (context) => FullScreenActivityCubit(
        activitiesBloc: context.read<ActivitiesBloc>(),
        clockBloc: context.read<ClockBloc>(),
        alarmCubit: context.read<AlarmCubit>(),
        startingActivity: activityDay,
      ),
      child: BlocListener<FullScreenActivityCubit, FullScreenActivityState>(
        listenWhen: (previous, current) => current.eventsList.isEmpty,
        listener: (context, state) => Navigator.of(context).maybePop(),
        child: const _FullScreenActivityInfo(),
      ),
    );
  }
}

class _FullScreenActivityInfo extends StatelessWidget {
  const _FullScreenActivityInfo({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocSelector<FullScreenActivityCubit, FullScreenActivityState,
        ActivityDay>(
      selector: (state) => state.selected,
      builder: (context, ad) {
        return Scaffold(
          appBar: DayAppBar(
            day: ad.day,
          ),
          body: ActivityInfoWithDots(
            ad,
          ),
          bottomNavigationBar: _FullScreenActivityBottomBar(
            selectedActivity: ad.activity,
          ),
        );
      },
    );
  }
}

class _FullScreenActivityBottomBar extends StatelessWidget with ActivityMixin {
  final Activity selectedActivity;

  _FullScreenActivityBottomBar({Key? key, required this.selectedActivity})
      : super(key: key);

  final OngoingFullscreenActivityToolBarLayout toolBarLayout =
      layout.ongoingFullscreenPage.toolBar;

  @override
  Widget build(BuildContext context) {
    final ScrollController scrollController = ScrollController();
    Translated t = Translator.of(context).translate;
    return BlocBuilder<FullScreenActivityCubit, FullScreenActivityState>(
      builder: (context, state) {
        return BottomAppBar(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                height: layout.ongoingFullscreenPage.activityIcon.toolBarHeight,
                color: AbiliaColors.white110,
                child: ScrollArrows.horizontal(
                  controller: scrollController,
                  leftCollapseMargin: toolBarLayout.collapseMargin,
                  rightCollapseMargin: toolBarLayout.collapseMargin,
                  child: ListView(
                    controller: scrollController,
                    scrollDirection: Axis.horizontal,
                    clipBehavior: Clip.none,
                    children: <Widget>[
                      ...state.eventsList.map(
                        (ao) => FullScreenActivityBottomContent(
                          activityOccasion: ao,
                          selected: ao.activity.id == selectedActivity.id,
                          minutes: DateTime.now().onlyMinutes(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(
                height: toolBarLayout.height,
                child: Padding(
                  padding: toolBarLayout.buttonPadding,
                  child: IconAndTextButton(
                    onPressed: () => Navigator.of(context).maybePop(),
                    icon: AbiliaIcons.closeProgram,
                    text: t.close,
                    style: iconTextButtonStyleLight,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

@visibleForTesting
class FullScreenActivityBottomContent extends StatelessWidget {
  FullScreenActivityBottomContent({
    Key? key,
    required this.activityOccasion,
    required this.selected,
    required this.minutes,
  }) : super(key: key);

  final ActivityOccasion activityOccasion;
  final double scaleFactor = 2 / 3;
  final bool selected;
  final DateTime minutes;
  final OngoingFullscreenActivityIconLayout iconLayout =
      layout.ongoingFullscreenPage.activityIcon;

  @override
  Widget build(BuildContext context) {
    bool current = activityOccasion.start.isAtSameMomentAs(minutes) ||
        activityOccasion.end.isAtSameMomentAs(minutes);
    final size = selected ? iconLayout.selectedSize : iconLayout.size;
    return Padding(
      padding: selected ? iconLayout.selectedPadding : iconLayout.padding,
      child: AspectRatio(
        aspectRatio: 1,
        child: BlocBuilder<MemoplannerSettingBloc, MemoplannerSettingsState>(
          buildWhen: (previous, current) =>
              previous.showCategoryColor != current.showCategoryColor &&
              previous.showCategories != current.showCategories,
          builder: (context, settings) {
            return Tts.fromSemantics(
              activityOccasion.activity.semanticsProperties(context),
              child: GestureDetector(
                onTap: () {
                  context
                      .read<FullScreenActivityCubit>()
                      .setCurrentActivity(activityOccasion);
                },
                child: Stack(
                  children: [
                    Container(
                      clipBehavior: selected ? Clip.none : Clip.hardEdge,
                      height: selected
                          ? iconLayout.selectedSize.height
                          : iconLayout.size.height,
                      foregroundDecoration: BoxDecoration(
                        border: Border.fromBorderSide(
                          BorderSide(
                              color: current
                                  ? AbiliaColors.red
                                  : AbiliaColors.white140,
                              width: current
                                  ? iconLayout.currentBorder
                                  : iconLayout.border),
                        ),
                        borderRadius: borderRadius,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: borderRadius,
                        color: AbiliaColors.white,
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          if (activityOccasion.activity.hasImage)
                            _ActivityWithIcon(
                                activityOccasion: activityOccasion)
                          else
                            _ActivityWithText(
                                title: activityOccasion.activity.title),
                        ],
                      ),
                    ),
                    if (selected)
                      CustomPaint(
                        size: iconLayout.arrowSize,
                        painter: _ActivityArrowPainter(current),
                      ),
                    if (settings.showCategories)
                      CustomPaint(
                        size: size,
                        painter: _CategoryCirclePainter(
                            radius: iconLayout.dotRadius,
                            offset: selected
                                ? iconLayout.dotOffsetSelected
                                : iconLayout.dotOffset,
                            color: categoryColor(
                                category: activityOccasion.category)),
                      ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _ActivityWithIcon extends StatelessWidget {
  final ActivityOccasion activityOccasion;

  const _ActivityWithIcon({Key? key, required this.activityOccasion})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 400),
      opacity: 1.0,
      child: FadeInAbiliaImage(
        imageFileId: activityOccasion.activity.fileId,
        imageFilePath: activityOccasion.activity.icon,
        height: double.infinity,
        width: double.infinity,
      ),
    );
  }
}

class _ActivityWithText extends StatelessWidget {
  final String title;

  const _ActivityWithText({Key? key, required this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: layout.ongoingFullscreenPage.activityIcon.textPadding,
      child: Center(
        child: Text(
          title,
          overflow: TextOverflow.clip,
          style: (Theme.of(context).textTheme.caption ?? caption)
              .copyWith(height: 20 / 16),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

class _ActivityArrowPainter extends CustomPainter {
  late Paint _arrowPaint;
  late Paint _fillPaint;

  _ActivityArrowPainter(bool current) {
    _arrowPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = current
          ? layout.ongoingFullscreenPage.activityIcon.currentBorder
          : layout.ongoingFullscreenPage.activityIcon.border
      ..color = current ? AbiliaColors.red100 : AbiliaColors.white140;
    _fillPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = AbiliaColors.white;
  }

  @override
  void paint(Canvas canvas, Size size) {
    Path arrow = Path()
      ..lineTo(size.width / 2 - 2, -size.height + 2)
      ..arcToPoint(Offset(size.width / 2 + 2, -size.height + 2),
          radius: layout.ongoingFullscreenPage.activityIcon.arrowPointRadius)
      ..lineTo(size.width, 0);
    arrow.close();
    arrow =
        arrow.shift(layout.ongoingFullscreenPage.activityIcon.arrowPreOffset);
    canvas.drawPath(arrow, _arrowPaint);
    arrow =
        arrow.shift(layout.ongoingFullscreenPage.activityIcon.arrowPostOffset);
    canvas.drawPath(arrow, _fillPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

class _CategoryCirclePainter extends CustomPainter {
  late Paint _circlePaint;
  late Paint _whitePaint;
  final double radius;
  final double offset;

  _CategoryCirclePainter({
    required this.radius,
    required this.offset,
    required color,
  }) {
    _circlePaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    _whitePaint = Paint()
      ..color = AbiliaColors.white
      ..style = PaintingStyle.fill;
  }

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawCircle(
        Offset(size.width - offset, offset), this.radius + 1, _whitePaint);
    canvas.drawCircle(
        Offset(size.width - offset, offset), this.radius, _circlePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
