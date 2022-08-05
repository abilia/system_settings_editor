import 'package:get_it/get_it.dart';
import 'package:vector_math/vector_math_64.dart' hide Colors;

import 'package:seagull/bloc/all.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/ui/all.dart';
import 'package:seagull/utils/all.dart';

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
          activitiesBloc: context.read<ActivitiesBloc>(),
          clockBloc: context.read<ClockBloc>(),
          alarmCubit: context.read<AlarmCubit>(),
          startingActivity: alarm.activityDay,
        ),
        child: BlocListener<FullScreenActivityCubit, FullScreenActivityState>(
          listenWhen: (previous, current) => current.eventsList.isEmpty,
          listener: (context, s) =>
              GetIt.I<AlarmNavigator>().popFullscreenRoute(),
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

  _FullScreenActivityTabBar({
    required this.selectedActivityDay,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final _layout = layout.ongoingFullscreen;
    final ScrollController scrollController = ScrollController();
    return DefaultTextStyle(
      overflow: TextOverflow.fade,
      style: (Theme.of(context).textTheme.caption ?? caption),
      textAlign: TextAlign.center,
      child: Container(
        height: _layout.height,
        color: AbiliaColors.white110,
        child: ScrollArrows.horizontal(
          controller: scrollController,
          child: BlocSelector<FullScreenActivityCubit, FullScreenActivityState,
              List<ActivityOccasion>>(
            selector: (state) => state.eventsList,
            builder: (context, eventsList) => ListView.builder(
              controller: scrollController,
              scrollDirection: Axis.horizontal,
              padding: _layout.padding,
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
    final _layout = layout.ongoingFullscreen.activity;
    return BlocSelector<FullScreenActivityCubit, FullScreenActivityState, bool>(
      selector: (state) =>
          activityOccasion.activity.id == state.selected.activity.id,
      builder: (context, selected) => BlocSelector<ClockBloc, DateTime, bool>(
        selector: (minutes) =>
            activityOccasion.start.isAtSameMomentAs(minutes) ||
            activityOccasion.end.isAtSameMomentAs(minutes),
        builder: (context, current) {
          final border =
              current || selected ? _layout.activeBorder : _layout.border;
          final borderColor = current
              ? AbiliaColors.red
              : selected
                  ? AbiliaColors.black80
                  : AbiliaColors.white140;
          final innerBorder =
              BorderRadius.all(innerRadiusFromBorderSize(border));
          return AnimatedPadding(
            duration: _animationDuration,
            padding: selected ? _layout.selectedPadding : _layout.padding,
            child: AspectRatio(
              aspectRatio: 1,
              child: BlocSelector<MemoplannerSettingBloc,
                  MemoplannerSettingsState, bool>(
                selector: (state) =>
                    state.showCategories && state.showCategoryColor,
                builder: (context, showCategories) => Tts.fromSemantics(
                  activityOccasion.activity.semanticsProperties(context),
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
                                        _layout.arrowSize.height,
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
                                      imageFileId:
                                          activityOccasion.activity.fileId,
                                      imageFilePath:
                                          activityOccasion.activity.icon,
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
            ),
          );
        },
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
    final _layout = layout.ongoingFullscreen.activity;
    final tweak = _layout.arrowPointRadius.x;
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
        radius: _layout.arrowPointRadius,
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
