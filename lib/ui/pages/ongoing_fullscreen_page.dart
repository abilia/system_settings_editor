import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:seagull/bloc/activities/activities_bloc.dart';
import 'package:seagull/bloc/clock/clock_bloc.dart';
import 'package:seagull/bloc/events/day_events_cubit.dart';
import 'package:seagull/bloc/events/events_state.dart';
import 'package:seagull/bloc/generic/memoplannersetting/memoplanner_setting_bloc.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/ui/all.dart';
import 'package:seagull/utils/activities_state_extensions.dart';
import 'package:seagull/utils/activity_extension.dart';
import 'package:seagull/utils/copied_auth_providers.dart';
import 'package:seagull/utils/datetime.dart';

class OngoingFullscreenActivityPage extends StatelessWidget {
  final ActivityDay activityDay;

  const OngoingFullscreenActivityPage({
    Key? key,
    required this.activityDay,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocSelector<ActivitiesBloc, ActivitiesState, ActivityDay>(
      selector: (activitiesState) {
        final a =
            activitiesState.newActivityFromLoadedOrGiven(activityDay.activity);
        return ActivityDay(
          a,
          a.isRecurring ? activityDay.day : a.startTime,
        );
      },
      builder: (context, ad) {
        return const _FullscreenActivityInfo();
      },
    );
  }
}

class _FullscreenActivityInfo extends StatefulWidget {
  const _FullscreenActivityInfo({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _FullScreenActivityInfoState();
  }
}

class _FullScreenActivityInfoState extends State<_FullscreenActivityInfo> {
  _FullScreenActivityInfoState();

  late DateTime time;

  @override
  void initState() {
    super.initState();
    time = DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ClockBloc, DateTime>(
      listener: (context, state) async {
        setState(() => {time = state});
      },
      child: BlocSelector<DayEventsCubit, EventsState, ActivityDay>(
        selector: (eventsState) {
          ActivityDay? ad;
          if (eventsState is EventsLoaded) {
            eventsState.activities.toSet().forEach((activityDay) {
              ActivityOccasion oc = activityDay.toOccasion(time);
              if (oc.isCurrent) {
                ad = activityDay;
                return;
              }
            });
          }
          if (ad == null) {
            Navigator.of(context).maybePop();
          }
          return ad!;
        },
        builder: (context, ad) {
          return Scaffold(
            appBar: DayAppBar(
              day: ad.day,
              leftAction: IconActionButton(
                key: TestKey.activityBackButton,
                onPressed: () => Navigator.of(context).maybePop(),
                child: const Icon(AbiliaIcons.navigationPrevious),
              ),
            ),
            body: Padding(
              padding: EdgeInsets.all(ActivityInfo.margin)
                  .subtract(EdgeInsets.only(left: ActivityInfo.margin)),
              child: ActivityInfoWithDots(
                ad,
              ),
            ),
            bottomNavigationBar: _FullScreenActivityBottomBar(
              selectedActivity: ad.activity,
            ),
          );
        },
      ),
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
                height: layout.ongoingFullscreenPage.toolBar.height,
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
                            ...eventState
                                .notPastEvents(DateTime.now())
                                .where((ao) =>
                                    ao.start.isBefore(DateTime.now()) &&
                                    ao.end
                                        .isAtSameMomentOrAfter(DateTime.now()))
                                .map(
                                  (ao) => _OngoingActivityContent(
                                    activityOccasion: ao as ActivityOccasion,
                                    selected:
                                        ao.activity.id == selectedActivity.id,
                                  ),
                                ),
                          ]
                        : [],
                  ),
                ),
              ),
              SizedBox(
                height: layout.ongoingFullscreenPage.toolBar.buttonHeight,
                child: Padding(
                  padding: layout.ongoingFullscreenPage.toolBar.buttonPadding,
                  child: IconAndTextButton(
                    onPressed: () => Navigator.of(context).pop(),
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

class _OngoingActivityContent extends StatelessWidget {
  const _OngoingActivityContent({
    Key? key,
    required this.activityOccasion,
    required this.selected,
  }) : super(key: key);

  final ActivityOccasion activityOccasion;
  final double scaleFactor = 2 / 3;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final size = selected
        ? layout.ongoingFullscreenPage.activityIcon.selectedSize
        : layout.ongoingFullscreenPage.activityIcon.size;

    final authProviders = copiedAuthProviders(context);
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
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => MultiBlocProvider(
                        providers: authProviders,
                        child: OngoingFullscreenActivityPage(
                            activityDay: activityOccasion),
                      ),
                      settings: RouteSettings(
                        name: 'ActivityPage $activityOccasion',
                      ),
                    ),
                  );
                },
                child: Stack(
                  children: [
                    Container(
                      clipBehavior: selected ? Clip.none : Clip.hardEdge,
                      height: size.height,
                      foregroundDecoration: BoxDecoration(
                        border: getCategoryBorder(
                          inactive: activityOccasion.isSignedOff,
                          current: activityOccasion.isCurrent,
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
                            .ongoingFullscreenPage
                            .activityIcon
                            .arrowSize
                            .width),
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
      ..strokeWidth = 2.s
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
