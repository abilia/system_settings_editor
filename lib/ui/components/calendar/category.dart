import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/ui/all.dart';

final _radius = Radius.circular(100.s);

abstract class _CategoryWidget extends StatelessWidget {
  final bool expanded;
  final MemoplannerSettingsState settingsState;
  final double maxWidth;

  const _CategoryWidget({
    Key key,
    @required this.expanded,
    @required this.settingsState,
    @required this.maxWidth,
  }) : super(key: key);
}

class CategoryLeft extends _CategoryWidget {
  const CategoryLeft({
    Key key,
    @required bool expanded,
    @required MemoplannerSettingsState settingsState,
    double maxWidth = double.infinity,
  }) : super(
          key: key,
          expanded: expanded,
          maxWidth: maxWidth,
          settingsState: settingsState,
        );
  @override
  Widget build(BuildContext context) => _Category(
        text: settingsState.leftCategoryName ??
            Translator.of(context).translate.left,
        borderRadius:
            BorderRadius.only(topRight: _radius, bottomRight: _radius),
        expanded: expanded,
        maxWidth: maxWidth,
      );
}

class CategoryRight extends _CategoryWidget {
  const CategoryRight({
    Key key,
    @required bool expanded,
    @required MemoplannerSettingsState settingsState,
    double maxWidth = double.infinity,
  }) : super(
          key: key,
          expanded: expanded,
          maxWidth: maxWidth,
          settingsState: settingsState,
        );
  @override
  Widget build(BuildContext context) => _Category(
        text: settingsState.rightCategoryName ??
            Translator.of(context).translate.right,
        expanded: expanded,
        icon: AbiliaIcons.navigation_next,
        alignment: const Alignment(1, 0),
        borderRadius: BorderRadius.only(topLeft: _radius, bottomLeft: _radius),
        textDirection: TextDirection.rtl,
        toggleCategory: const ToggleRight(),
        maxWidth: maxWidth,
      );
}

class _Category extends StatefulWidget {
  final AlignmentGeometry alignment;
  final BorderRadius borderRadius;
  final String text;
  final TextDirection textDirection;
  final IconData icon;
  final bool left;
  final ToggleCategory toggleCategory;
  final bool expanded;
  final double maxWidth;
  const _Category({
    Key key,
    @required this.text,
    @required this.expanded,
    @required this.borderRadius,
    this.icon = AbiliaIcons.navigation_previous,
    this.alignment = const Alignment(-1, 0),
    this.textDirection = TextDirection.ltr,
    this.toggleCategory = const ToggleLeft(),
    this.maxWidth = double.infinity,
  })  : left = textDirection == TextDirection.ltr,
        super(key: key);

  @override
  __CategoryState createState() => __CategoryState(expanded);
}

class __CategoryState extends State<_Category> with TickerProviderStateMixin {
  final AlignmentGeometry top = const Alignment(0, -1);
  AnimationController controller;
  Animation<Matrix4> matrixAnimation;
  final bool value;

  __CategoryState(this.value);
  @override
  void initState() {
    controller = AnimationController(
        duration: const Duration(milliseconds: 500), vsync: this);
    matrixAnimation = Tween<Matrix4>(
      begin: widget.expanded ? Matrix4.identity() : Matrix4.rotationY(pi),
      end: widget.expanded ? Matrix4.rotationY(pi) : Matrix4.identity(),
    ).animate(controller);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final intAnimation = IntTween(
      begin: value ? widget.text.length : 1,
      end: value ? 1 : widget.text.length,
    ).animate(
      CurvedAnimation(
        curve: Curves.easeInOutExpo,
        parent: controller,
      ),
    );
    return GestureDetector(
      onTap: () {
        if (value == widget.expanded) {
          controller.forward();
        } else {
          controller.reverse();
        }
        BlocProvider.of<CalendarViewBloc>(context).add(widget.toggleCategory);
      },
      child: Align(
        alignment: widget.alignment.add(top),
        child: Tts.fromSemantics(
          SemanticsProperties(
            header: true,
            label: widget.text,
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: widget.maxWidth),
            child: Container(
              margin: EdgeInsets.only(top: 4.0.s),
              padding: EdgeInsets.symmetric(vertical: 10.s),
              decoration: BoxDecoration(
                borderRadius: widget.borderRadius,
                color: AbiliaColors.black80,
              ),
              child: Stack(
                textDirection: widget.textDirection,
                alignment: widget.alignment,
                children: [
                  AnimatedBuilder(
                    animation: matrixAnimation,
                    child: Icon(
                      widget.icon,
                      size: smallIconSize,
                      color: AbiliaColors.black60,
                    ),
                    builder: (context, child) => Transform(
                      alignment: Alignment.center,
                      transform: matrixAnimation.value,
                      child: child,
                    ),
                  ),
                  Padding(
                    padding: widget.left
                        ? EdgeInsets.only(left: 22.s, right: 16.s)
                        : EdgeInsets.only(left: 16.s, right: 22.s),
                    child: AnimatedBuilder(
                      animation: controller,
                      builder: (context, _) => Text(
                        widget.text.substring(0, intAnimation.value),
                        style: Theme.of(context)
                            .textTheme
                            .subtitle1
                            .copyWith(color: AbiliaColors.white),
                        softWrap: false,
                        overflow: TextOverflow.fade,
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
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}
