import 'dart:math';

import 'package:memoplanner/bloc/all.dart';
import 'package:memoplanner/models/all.dart';
import 'package:memoplanner/ui/all.dart';

class LeftCategory extends StatelessWidget {
  final double maxWidth;

  const LeftCategory({
    Key? key,
    this.maxWidth = double.infinity,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final categories = context.select(
        (MemoplannerSettingsBloc bloc) => bloc.state.calendar.categories);
    return CategoryLeft(
      maxWidth: maxWidth,
      categoryName: categories.left.name,
      fileId: categories.left.image.id,
      showColors: categories.showColors,
    );
  }
}

class CategoryLeft extends StatelessWidget {
  final String categoryName, fileId;
  final bool showColors;
  final double maxWidth;

  const CategoryLeft({
    required this.categoryName,
    required this.fileId,
    required this.showColors,
    this.maxWidth = double.infinity,
    Key? key,
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
  Widget build(BuildContext context) {
    final categories = context.select(
        (MemoplannerSettingsBloc bloc) => bloc.state.calendar.categories);
    return CategoryRight(
      maxWidth: maxWidth,
      categoryName: categories.right.name,
      fileId: categories.right.image.id,
      showColors: categories.showColors,
    );
  }
}

class CategoryRight extends StatelessWidget {
  final String categoryName, fileId;
  final bool showColors;
  final double maxWidth;

  const CategoryRight({
    required this.categoryName,
    required this.fileId,
    required this.showColors,
    this.maxWidth = double.infinity,
    Key? key,
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
    required this.label,
    required this.fileId,
    required this.expanded,
    required this.icon,
    required this.direction,
    required this.category,
    required this.maxWidth,
    required this.showColors,
    Key? key,
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
  Characters get characters => widget.label.characters;

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
                          showBorder: widget.showColors,
                          diameter: layout.category.imageDiameter,
                          color: categoryColor(category: widget.category),
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
  final String fileId;
  final bool showBorder;
  final Color? color;
  final double diameter;

  CategoryImage({
    required this.fileId,
    required this.color,
    required this.showBorder,
    required this.diameter,
    Key? key,
  })  : assert(fileId.isNotEmpty || showBorder),
        borderRadius = BorderRadius.circular(diameter / 2),
        noColorsImageSize = layout.category.noColorsImageSize,
        noColorsImageBorderRadius =
            BorderRadius.circular(layout.category.noColorsImageSize / 2),
        super(key: key);

  late final BorderRadius borderRadius;
  late final double noColorsImageSize;
  late final BorderRadius noColorsImageBorderRadius;

  @override
  Widget build(BuildContext context) {
    if (fileId.isNotEmpty && !showBorder) {
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
        color: color,
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
