import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/i18n/app_localizations.dart';
import 'package:seagull/ui/colors.dart';
import 'package:seagull/ui/components/all.dart';

const _radius = Radius.circular(100);

class CategoryLeft extends StatelessWidget {
  final bool expanded;
  const CategoryLeft({
    Key key,
    @required this.expanded,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return _Category(
      text: Translator.of(context).translate.left,
      expanded: expanded,
    );
  }
}

class CategoryRight extends StatelessWidget {
  final bool expanded;

  const CategoryRight({
    Key key,
    @required this.expanded,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) => _Category(
        text: Translator.of(context).translate.right,
        expanded: expanded,
        icon: AbiliaIcons.navigation_next,
        alignment: const Alignment(1, 0),
        borderRadius:
            const BorderRadius.only(topLeft: _radius, bottomLeft: _radius),
        textDirection: TextDirection.rtl,
        toggleCategory: const ToggleRight(),
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
  const _Category({
    Key key,
    @required this.text,
    @required this.expanded,
    this.borderRadius =
        const BorderRadius.only(topRight: _radius, bottomRight: _radius),
    this.icon = AbiliaIcons.navigation_previous,
    this.alignment = const Alignment(-1, 0),
    this.textDirection = TextDirection.ltr,
    this.toggleCategory = const ToggleLeft(),
  })  : left = textDirection == TextDirection.ltr,
        super(key: key);

  @override
  __CategoryState createState() => __CategoryState(expanded);
}

class __CategoryState extends State<_Category> with TickerProviderStateMixin {
  final AlignmentGeometry top = const Alignment(0, -1);
  AnimationController controller;
  Animation<int> intAnimation;
  Animation<Matrix4> matrixAnimation;
  bool value;

  __CategoryState(this.value);
  @override
  void initState() {
    controller = AnimationController(
        duration: const Duration(milliseconds: 500), vsync: this);
    intAnimation = IntTween(
      begin: widget.expanded ? widget.text.length : 1,
      end: widget.expanded ? 1 : widget.text.length,
    ).animate(
      CurvedAnimation(
        curve: Curves.easeInOutExpo,
        parent: controller,
      ),
    );
    matrixAnimation = Tween<Matrix4>(
      begin: widget.expanded ? Matrix4.identity() : Matrix4.rotationY(pi),
      end: widget.expanded ? Matrix4.rotationY(pi) : Matrix4.identity(),
    ).animate(controller);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
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
        child: Container(
          margin: const EdgeInsets.only(top: 4.0),
          padding: EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            borderRadius: widget.borderRadius,
            color: AbiliaColors.black[80],
          ),
          child: Stack(
            textDirection: widget.textDirection,
            alignment: widget.alignment,
            children: [
              AnimatedBuilder(
                animation: matrixAnimation,
                child: Icon(widget.icon, color: AbiliaColors.black[60]),
                builder: (context, child) => Transform(
                  alignment: Alignment.center,
                  transform: matrixAnimation.value,
                  child: child,
                ),
              ),
              Padding(
                padding: widget.left
                    ? const EdgeInsets.only(left: 22, right: 16)
                    : const EdgeInsets.only(left: 16, right: 22),
                child: AnimatedBuilder(
                  animation: intAnimation,
                  builder: (context, _) => Text(
                    widget.text.substring(0, intAnimation.value),
                    style: Theme.of(context)
                        .textTheme
                        .subhead
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
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}