import 'package:memoplanner/bloc/all.dart';
import 'package:memoplanner/listener/all.dart';
import 'package:memoplanner/models/all.dart';
import 'package:memoplanner/repository/all.dart';
import 'package:memoplanner/ui/all.dart';
import 'package:memoplanner/utils/all.dart';
import 'package:vector_math/vector_math_64.dart' hide Colors;

class FullScreenActivityPage extends StatelessWidget {
  final NewAlarm alarm;

  const FullScreenActivityPage({
    required this.alarm,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: abiliaWhiteTheme,
      child: BlocProvider<FullScreenActivityCubit>(
        create: (context) => FullScreenActivityCubit(
          activitiesCubit: context.read<ActivitiesCubit>(),
          activityRepository: context.read<ActivityRepository>(),
          clockCubit: context.read<ClockCubit>(),
          alarmCubit: context.read<AlarmCubit>(),
          startingActivity: alarm.activityDay,
        )..loadActivities(),
        child: FullscreenActivityListener(
          child: BlocSelector<FullScreenActivityCubit, FullScreenActivityState,
              ActivityDay>(
            selector: (state) => state.selected,
            builder: (context, selected) => Scaffold(
              appBar: DayAppBar(day: selected.day),
              body: Column(
                children: [
                  Expanded(child: ActivityInfoWithDots(selected, alarm: alarm)),
                  _FullScreenActivityTabBar(selectedActivityDay: selected),
                ],
              ),
              bottomNavigationBar: BottomAppBar(
                child: SizedBox(
                  height: layout.navigationBar.height,
                  child: Padding(
                    padding: layout.navigationBar.padding,
                    child: const Align(
                      child: CloseButton(),
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
}

class _FullScreenActivityTabBar extends StatelessWidget with ActivityMixin {
  final ActivityDay selectedActivityDay;
  final scrollController = ScrollController();

  _FullScreenActivityTabBar({
    required this.selectedActivityDay,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DefaultTextStyle(
      overflow: TextOverflow.fade,
      style: (Theme.of(context).textTheme.bodySmall ?? bodySmall),
      textAlign: TextAlign.center,
      child: Container(
        height: layout.ongoingFullscreen.height,
        color: AbiliaColors.white110,
        child: ScrollArrows.horizontal(
          controller: scrollController,
          child: BlocSelector<FullScreenActivityCubit, FullScreenActivityState,
              List<ActivityOccasion>>(
            selector: (state) => state.eventsList ?? [],
            builder: (context, eventsList) => ListView.builder(
              controller: scrollController,
              scrollDirection: Axis.horizontal,
              padding: layout.ongoingFullscreen.padding,
              itemCount: eventsList.length,
              itemBuilder: (context, index) => FullScreenActivityTabItem(
                activityOccasion: eventsList[index],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

@visibleForTesting
class FullScreenActivityTabItem extends StatelessWidget {
  const FullScreenActivityTabItem({
    required this.activityOccasion,
    Key? key,
  }) : super(key: key);

  final ActivityOccasion activityOccasion;

  static const _animationDuration = Duration(milliseconds: 200);

  @override
  Widget build(BuildContext context) {
    final activityLayout = layout.ongoingFullscreen.activity;
    final selected = context.select((FullScreenActivityCubit bloc) =>
        activityOccasion.activity.id == bloc.state.selected.activity.id);
    final current = context.select((ClockCubit bloc) =>
        activityOccasion.start.isAtSameMomentAs(bloc.state) ||
        activityOccasion.end.isAtSameMomentAs(bloc.state));
    final border = current || selected
        ? activityLayout.activeBorder
        : activityLayout.border;
    final borderColor = current
        ? AbiliaColors.red
        : selected
            ? AbiliaColors.black80
            : AbiliaColors.white140;
    final innerBorder = BorderRadius.all(innerRadiusFromBorderSize(border));
    final showCategories = context.select((MemoplannerSettingsBloc bloc) =>
        bloc.state.calendar.categories.show &&
        bloc.state.calendar.categories.showColors);
    return AnimatedPadding(
      duration: _animationDuration,
      padding:
          selected ? activityLayout.selectedPadding : activityLayout.padding,
      child: AspectRatio(
        aspectRatio: 1,
        child: Tts.fromSemantics(
          activityOccasion.semanticsProperties(context),
          child: GestureDetector(
            onTap: () => context
                .read<FullScreenActivityCubit>()
                .setCurrentActivity(activityOccasion),
            child: Stack(
              children: [
                AnimatedContainer(
                  duration: _animationDuration,
                  decoration: BoxDecoration(
                    border: Border.fromBorderSide(
                      BorderSide(color: borderColor, width: border),
                    ),
                    borderRadius: borderRadius,
                  ),
                ),
                Stack(
                  children: [
                    AnimatedContainer(
                      duration: _animationDuration,
                      transform: selected
                          ? Matrix4.identity()
                          : Matrix4.translation(
                              Vector3(
                                0.0,
                                activityLayout.arrowSize.height,
                                0.0,
                              ),
                            ),
                      child: _ActivityArrow(
                        border: border,
                        color: borderColor,
                      ),
                    ),
                    AnimatedContainer(
                      duration: _animationDuration,
                      decoration: activityOccasion.activity.hasImage
                          ? const BoxDecoration()
                          : BoxDecoration(
                              borderRadius: innerBorder,
                              color: AbiliaColors.white,
                            ),
                      margin: EdgeInsets.all(border),
                      child: activityOccasion.activity.hasImage
                          ? FadeInAbiliaImage(
                              imageFileId: activityOccasion.activity.fileId,
                              imageFilePath: activityOccasion.activity.icon,
                              height: double.infinity,
                              width: double.infinity,
                              borderRadius: innerBorder,
                            )
                          : Center(
                              child: Text(
                                activityOccasion.activity.title,
                              ),
                            ),
                    ),
                  ],
                ),
                if (showCategories)
                  _CategoryDot(
                    selected: selected,
                    category: activityOccasion.category,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ActivityArrow extends StatelessWidget {
  final double border;
  final Color color;

  const _ActivityArrow({
    required this.border,
    required this.color,
    Key? key,
  }) : super(key: key);

  static Path arrrowPath(Size size) {
    final tweak = layout.ongoingFullscreen.activity.arrowPointRadius.x;
    final midPoint = size.width / 2;
    return Path()
      ..lineTo(
        midPoint - tweak / 2,
        -size.height + tweak,
      )
      ..arcToPoint(
        Offset(
          midPoint + tweak / 2,
          -size.height + tweak,
        ),
        radius: layout.ongoingFullscreen.activity.arrowPointRadius,
      )
      ..lineTo(size.width, 0);
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: Transform.translate(
        offset: Offset(0.0, border * 0.5),
        child: Stack(
          children: [
            Transform.translate(
              offset: Offset(0.0, border * .66),
              child: CustomPaint(
                size: layout.ongoingFullscreen.activity.arrowSize,
                foregroundPainter: _ActivityArrowFillPainter(),
              ),
            ),
            CustomPaint(
              size: layout.ongoingFullscreen.activity.arrowSize,
              painter: _ActivityArrowBorderPainter(border, color),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActivityArrowBorderPainter extends CustomPainter {
  final Paint _arrowPaint;
  _ActivityArrowBorderPainter(double border, Color color)
      : _arrowPaint = Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = border
          ..color = color;

  @override
  void paint(Canvas canvas, Size size) =>
      canvas.drawPath(_ActivityArrow.arrrowPath(size), _arrowPaint);

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class _ActivityArrowFillPainter extends CustomPainter {
  final Paint _fillPaint = Paint()
    ..style = PaintingStyle.fill
    ..color = AbiliaColors.white;

  @override
  void paint(Canvas canvas, Size size) =>
      canvas.drawPath(_ActivityArrow.arrrowPath(size), _fillPaint);

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class _CategoryDot extends StatelessWidget {
  const _CategoryDot({
    required this.category,
    required this.selected,
    Key? key,
  }) : super(key: key);

  final Duration _animationDuration = ActivityInfo.animationDuration;

  final int category;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final dot = layout.ongoingFullscreen.activity.dot;
    final offset = selected ? dot.selectedOffset : dot.offset;
    return AnimatedPositioned(
      duration: _animationDuration,
      right: offset,
      top: offset,
      child: Stack(
        alignment: Alignment.center,
        children: [
          ColorDot(
            radius: dot.outerRadius,
            color: AbiliaColors.white,
          ),
          ColorDot(
            radius: dot.innerRadius,
            color: categoryColor(category: category),
          )
        ],
      ),
    );
  }
}
