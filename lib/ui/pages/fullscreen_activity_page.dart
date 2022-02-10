import 'package:seagull/bloc/all.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/ui/all.dart';
import 'package:seagull/utils/activity_extension.dart';
import 'package:seagull/utils/datetime.dart';

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
            dayEventsCubit: context.read<DayEventsCubit>(),
            clockBloc: context.read<ClockBloc>()),
        child: _FullScreenActivityInfo(
          activityDay: activityDay,
        ));
  }
}

class _FullScreenActivityInfo extends StatelessWidget {
  const _FullScreenActivityInfo({Key? key, required this.activityDay})
      : super(key: key);
  final ActivityDay activityDay;

  @override
  Widget build(BuildContext context) {
    return BlocSelector<FullScreenActivityCubit, FullScreenActivityState,
        ActivityDay>(
      selector: (state) {
        if (state is NoActivityState) {
          Navigator.of(context).maybePop();
        }
        return state.activityDay ?? activityDay;
      },
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

  @override
  Widget build(BuildContext context) {
    final ScrollController scrollController = ScrollController();
    Translated t = Translator.of(context).translate;
    return BlocBuilder<DayEventsCubit, EventsState>(
      builder: (context, eventState) {
        return BottomAppBar(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                height: layout.ongoingFullscreenPage.activityIcon.toolBarHeight,
                color: AbiliaColors.white110,
                child: ScrollArrows.horizontal(
                  controller: scrollController,
                  leftCollapseMargin:
                      layout.ongoingFullscreenPage.toolBar.collapseMargin,
                  rightCollapseMargin:
                      layout.ongoingFullscreenPage.toolBar.collapseMargin,
                  child: ListView(
                    controller: scrollController,
                    scrollDirection: Axis.horizontal,
                    clipBehavior: Clip.none,
                    children: eventState is EventsLoaded
                        ? <Widget>[
                            ...context
                                .read<FullScreenActivityCubit>()
                                .eventsList
                                .map(
                                  (ao) => FullScreenActivityBottomContent(
                                    activityOccasion:
                                        ao.toOccasion(DateTime.now()),
                                    selected:
                                        ao.activity.id == selectedActivity.id,
                                    minutes: DateTime.now().onlyMinutes(),
                                  ),
                                ),
                          ]
                        : [],
                  ),
                ),
              ),
              SizedBox(
                height: layout.ongoingFullscreenPage.toolBar.height,
                child: Padding(
                  padding: layout.ongoingFullscreenPage.toolBar.buttonPadding,
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
  const FullScreenActivityBottomContent({
    Key? key,
    required this.activityOccasion,
    required this.selected,
    required this.minutes,
  }) : super(key: key);

  final ActivityOccasion activityOccasion;
  final double scaleFactor = 2 / 3;
  final bool selected;
  final DateTime minutes;

  @override
  Widget build(BuildContext context) {
    final size = selected
        ? layout.ongoingFullscreenPage.activityIcon.selectedSize
        : layout.ongoingFullscreenPage.activityIcon.size;
    return Padding(
      padding: selected
          ? layout.ongoingFullscreenPage.activityIcon.selectedPadding
          : layout.ongoingFullscreenPage.activityIcon.padding,
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
                          ? layout.ongoingFullscreenPage.activityIcon
                              .selectedSize.height
                          : layout
                              .ongoingFullscreenPage.activityIcon.size.height,
                      foregroundDecoration: BoxDecoration(
                        border: getCategoryBorder(
                          inactive: false,
                          current: activityOccasion.start
                                  .isAtSameMomentAs(minutes) ||
                              activityOccasion.end.isAtSameMomentAs(minutes),
                          showCategoryColor: false,
                          category: activityOccasion.activity.category,
                          borderWidth:
                              layout.ongoingFullscreenPage.activityIcon.border,
                          currentBorderWidth:
                              layout.ongoingFullscreenPage.activityIcon.border,
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
                        size:
                            layout.ongoingFullscreenPage.activityIcon.arrowSize,
                        painter: _ActivityArrowPainter(layout
                            .ongoingFullscreenPage.activityIcon.arrowStartX),
                      ),
                    if (settings.showCategories)
                      CustomPaint(
                        size: size,
                        painter: _CategoryCirclePainter(
                            categoryColor(category: activityOccasion.category)),
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
  final double startX;

  _ActivityArrowPainter(this.startX) {
    _arrowPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = AbiliaColors.red100;
    _fillPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = AbiliaColors.white;
  }

  @override
  void paint(Canvas canvas, Size size) {
    Path arrow = Path()
      ..lineTo(size.width / 2 - 2, -size.height + 2)
      ..arcToPoint(Offset(size.width / 2 + 2, -size.height + 2),
          radius: const Radius.circular(4))
      ..lineTo(size.width, 0);
    arrow.close();
    arrow = arrow.shift(Offset(startX, 1));
    canvas.drawPath(arrow, _arrowPaint);
    arrow = arrow.shift(const Offset(0, 1.5));
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

  _CategoryCirclePainter(Color color) {
    _circlePaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    _whitePaint = Paint()
      ..color = AbiliaColors.white
      ..style = PaintingStyle.fill;
  }

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawCircle(Offset(size.width - 8, 8), 5, _whitePaint);
    canvas.drawCircle(Offset(size.width - 8, 8), 4, _circlePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
