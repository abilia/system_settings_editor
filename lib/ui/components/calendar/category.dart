import 'dart:math';

import 'package:seagull/bloc/all.dart';
import 'package:seagull/models/all.dart';
import 'package:seagull/ui/all.dart';

class LeftCategory extends StatelessWidget {
  final double maxWidth;

  const LeftCategory({
    Key? key,
    this.maxWidth = double.infinity,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) =>
      BlocBuilder<MemoplannerSettingBloc, MemoplannerSettingsState>(
        buildWhen: (previous, current) =>
            previous.leftCategoryName != current.leftCategoryName ||
            previous.leftCategoryImage != current.leftCategoryImage ||
            previous.showCategoryColor != current.showCategoryColor,
        builder: (context, memoplannerSettingsState) => CategoryLeft(
          maxWidth: maxWidth,
          categoryName: memoplannerSettingsState.leftCategoryName,
          fileId: memoplannerSettingsState.leftCategoryImage,
          showColors: memoplannerSettingsState.showCategoryColor,
        ),
      );
}

class CategoryLeft extends StatelessWidget {
  final String categoryName, fileId;
  final bool showColors;
  final double maxWidth;

  const CategoryLeft({
    Key? key,
    required this.categoryName,
    required this.fileId,
    required this.showColors,
    this.maxWidth = double.infinity,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) =>
      BlocBuilder<CalendarViewCubit, CalendarViewState>(
        buildWhen: (previous, current) =>
            previous.expandLeftCategory != current.expandLeftCategory,
        builder: (context, calendarViewState) => _Category(
          label: categoryName.isEmpty
              ? Translator.of(context).translate.left
              : categoryName,
          fileId: fileId,
          expanded: calendarViewState.expandLeftCategory,
          icon: AbiliaIcons.navigationPrevious,
          direction: TextDirection.ltr,
          category: Category.left,
          maxWidth: maxWidth,
          showColors: showColors,
        ),
      );
}

class RightCategory extends StatelessWidget {
  final double maxWidth;

  const RightCategory({
    Key? key,
    this.maxWidth = double.infinity,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) =>
      BlocBuilder<MemoplannerSettingBloc, MemoplannerSettingsState>(
        buildWhen: (previous, current) =>
            previous.rightCategoryName != current.rightCategoryName ||
            previous.rightCategoryImage != current.rightCategoryImage ||
            previous.showCategoryColor != current.showCategoryColor,
        builder: (context, memoplannerSettingsState) => CategoryRight(
          maxWidth: maxWidth,
          categoryName: memoplannerSettingsState.rightCategoryName,
          fileId: memoplannerSettingsState.rightCategoryImage,
          showColors: memoplannerSettingsState.showCategoryColor,
        ),
      );
}

class CategoryRight extends StatelessWidget {
  final String categoryName, fileId;
  final bool showColors;
  final double maxWidth;

  const CategoryRight({
    Key? key,
    required this.categoryName,
    required this.fileId,
    required this.showColors,
    this.maxWidth = double.infinity,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) =>
      BlocBuilder<CalendarViewCubit, CalendarViewState>(
        buildWhen: (previous, current) =>
            previous.expandRightCategory != current.expandRightCategory,
        builder: (context, calendarViewState) => _Category(
          label: categoryName.isEmpty
              ? Translator.of(context).translate.right
              : categoryName,
          fileId: fileId,
          expanded: calendarViewState.expandRightCategory,
          icon: AbiliaIcons.navigationNext,
          direction: TextDirection.rtl,
          category: Category.right,
          maxWidth: maxWidth,
          showColors: showColors,
        ),
      );
}

class _Category extends StatefulWidget {
  final String label;
  final String fileId;
  final TextDirection direction;
  final IconData icon;
  final int category;
  final bool expanded;
  final double maxWidth;
  final bool showColors;
  final int letters;
  _Category({
    Key? key,
    required this.label,
    required this.fileId,
    required this.expanded,
    required this.icon,
    required this.direction,
    required this.category,
    required this.maxWidth,
    required this.showColors,
  })  : letters = showColors || fileId.isNotEmpty ? 0 : 1,
        super(key: key);

  @override
  __CategoryState createState() => __CategoryState();
}

class __CategoryState extends State<_Category> with TickerProviderStateMixin {
  late final bool value;
  late final AlignmentGeometry alignment;
  late final BorderRadius borderRadius;
  late final AnimationController controller;
  late final Animation<Matrix4> matrixAnimation;
  late final Animation<EdgeInsetsGeometry> paddingAnimation;
  late final Characters characters = widget.label.characters;

  @override
  void initState() {
    super.initState();
    value = widget.expanded;
    alignment = AlignmentDirectional.topStart.resolve(widget.direction);
    borderRadius = BorderRadiusDirectional.horizontal(
            end: Radius.circular(layout.category.radius))
        .resolve(widget.direction);

    controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    matrixAnimation = Tween<Matrix4>(
      begin: widget.expanded ? Matrix4.identity() : Matrix4.rotationY(pi),
      end: widget.expanded ? Matrix4.rotationY(pi) : Matrix4.identity(),
    ).animate(controller);
    final p1 = EdgeInsetsDirectional.only(
      start: layout.category.startPadding,
      end: layout.category.endPadding,
    ).resolve(widget.direction);
    final p2 = EdgeInsetsDirectional.only(
      start: 0,
      end: layout.category.endPadding,
    ).resolve(widget.direction);
    paddingAnimation = EdgeInsetsGeometryTween(
      begin: value ? p1 : p2,
      end: value ? p2 : p1,
    ).animate(controller);
  }

  @override
  Widget build(BuildContext context) {
    final intAnimation = IntTween(
      begin: value ? characters.length : widget.letters,
      end: value ? widget.letters : characters.length,
    ).animate(
      CurvedAnimation(
        curve: Curves.easeInOutExpo,
        parent: controller,
      ),
    );
    return SafeArea(
      child: GestureDetector(
        onTap: () {
          if (value == widget.expanded) {
            controller.forward();
          } else {
            controller.reverse();
          }
          context.read<CalendarViewCubit>().toggle(widget.category);
        },
        child: Align(
          alignment: alignment,
          child: Tts.fromSemantics(
            SemanticsProperties(
              header: true,
              label: widget.label,
            ),
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: widget.maxWidth),
              child: Container(
                clipBehavior: Clip.hardEdge,
                margin: EdgeInsets.only(top: layout.category.topMargin),
                height: layout.category.height,
                decoration: BoxDecoration(
                  borderRadius: borderRadius,
                  color: AbiliaColors.black80,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  textDirection: widget.direction,
                  children: [
                    AnimatedBuilder(
                      animation: matrixAnimation,
                      builder: (context, child) => Transform(
                        alignment: Alignment.center,
                        transform: matrixAnimation.value,
                        child: child,
                      ),
                      child: Icon(
                        widget.icon,
                        size: layout.icon.small,
                        color: AbiliaColors.black60,
                      ),
                    ),
                    Flexible(
                      child: AnimatedBuilder(
                        animation: controller,
                        key: TestKey.categoryAnimationTestKey,
                        builder: (context, _) => intAnimation.value != 0
                            ? Text(
                                characters.take(intAnimation.value).string,
                                style: Theme.of(context)
                                    .textTheme
                                    .subtitle1
                                    ?.copyWith(color: AbiliaColors.white),
                                softWrap: false,
                                overflow: TextOverflow.fade,
                              )
                            : const SizedBox.shrink(),
                      ),
                    ),
                    if (widget.fileId.isNotEmpty || widget.showColors)
                      AnimatedBuilder(
                        animation: controller,
                        builder: (context, w) => Padding(
                          padding: paddingAnimation.value,
                          child: w,
                        ),
                        child: CategoryImage(
                          fileId: widget.fileId,
                          category: widget.category,
                          showColors: widget.showColors,
                        ),
                      )
                    else
                      SizedBox(width: layout.category.emptySize)
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}

class CategoryImage extends StatelessWidget {
  CategoryImage({
    Key? key,
    required this.fileId,
    required this.category,
    required this.showColors,
  })  : assert(fileId.isNotEmpty || showColors),
        super(key: key);

  static final diameter = layout.category.imageDiameter,
      borderRadius = BorderRadius.circular(diameter / 2),
      noColorsImageSize = layout.category.noColorsImageSize,
      noColorsImageBorderRadius = BorderRadius.circular(noColorsImageSize / 2);
  final String fileId;
  final int category;
  final bool showColors;
  @override
  Widget build(BuildContext context) {
    if (fileId.isNotEmpty && !showColors) {
      return FadeInAbiliaImage(
        imageFileId: fileId,
        width: diameter,
        height: diameter,
        borderRadius: borderRadius,
      );
    }
    return Container(
      width: diameter,
      height: diameter,
      decoration: BoxDecoration(
        color: categoryColor(category: category),
        borderRadius: borderRadius,
      ),
      padding: layout.category.imagePadding,
      child: fileId.isNotEmpty
          ? FadeInAbiliaImage(
              imageFileId: fileId,
              width: noColorsImageSize,
              height: noColorsImageSize,
              borderRadius: noColorsImageBorderRadius,
            )
          : null,
    );
  }
}
