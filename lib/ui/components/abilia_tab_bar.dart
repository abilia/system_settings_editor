// @dart=2.9

import 'package:flutter/material.dart';
import 'package:seagull/ui/all.dart';

class AbiliaTabBar extends StatelessWidget implements PreferredSizeWidget {
  const AbiliaTabBar({
    Key key,
    @required this.tabs,
    this.height,
    this.collapsedCondition,
  }) : super(key: key);

  final List<Widget> tabs;
  final double height;

  final bool Function(int index) collapsedCondition;
  bool Function(int) get isCollapsed => collapsedCondition ?? (_) => false;

  @override
  Size get preferredSize => Size.fromHeight(height ?? 64.0.s);

  @override
  Widget build(BuildContext context) {
    var offset = 0;
    final wrappedTabs = [
      for (var i = 0; i < tabs.length; i++)
        _Tab(
          index: i,
          offset: isCollapsed(i) ? offset++ : offset,
          last: (tabs.length - 1) == i,
          collapsed: () => isCollapsed(i),
          controller: DefaultTabController.of(context),
          child: tabs[i],
        )
    ];

    return Material(
      type: MaterialType.transparency,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: wrappedTabs,
      ),
    );
  }
}

class _Tab extends StatefulWidget {
  const _Tab({
    Key key,
    @required this.index,
    @required this.offset,
    @required this.last,
    @required this.collapsed,
    @required this.child,
    @required this.controller,
  }) : super(key: key);

  final int index, offset;
  final bool last;
  final Widget child;
  final TabController controller;
  final bool Function() collapsed;

  @override
  _TabState createState() => _TabState(collapsed());
}

class _TabState extends State<_Tab> with SingleTickerProviderStateMixin {
  _TabState(this.collapsed);
  AnimationController _collapsedController;
  Animation<double> _scaleAnimation;
  bool collapsed;

  @override
  void initState() {
    _collapsedController =
        AnimationController(vsync: this, duration: kTabScrollDuration);
    _scaleAnimation = _collapsedController
        .drive(ReverseTween<double>(Tween<double>(begin: 0.0, end: 1.0)));
    if (collapsed) {
      _collapsedController.forward(from: 1.0);
    }
    super.initState();
  }

  @override
  void dispose() {
    _collapsedController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(_Tab oldWidget) {
    final _collapsed = widget.collapsed();
    if (_collapsed != collapsed) {
      if (_collapsed) {
        _collapsedController.forward();
      } else {
        _collapsedController.reverse();
      }
      collapsed = _collapsed;
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    final iconTheme = IconTheme.of(context);
    return _AnimatedTab(
      selectedTabAnimation: widget.controller.animation,
      scaleAnimation: _scaleAnimation,
      listenable:
          Listenable.merge([widget.controller.animation, _collapsedController]),
      index: widget.index,
      offset: widget.offset,
      first: widget.index == 0,
      last: widget.last,
      beginIconThemeData: iconTheme.copyWith(size: smallIconSize),
      endIconThemeData:
          iconTheme.copyWith(color: AbiliaColors.white, size: smallIconSize),
      onTap: () => widget.controller.animateTo(widget.index - widget.offset),
      child: widget.child,
    );
  }
}

class _AnimatedTab extends AnimatedWidget {
  static final beginBorder = Border.fromBorderSide(
        BorderSide(color: AbiliaColors.white, width: 1.0.s),
      ),
      endBorder = Border.fromBorderSide(
        BorderSide(color: AbiliaColors.transparentWhite30, width: 1.0.s),
      );
  static final firstBorderRadius = BorderRadius.horizontal(left: radius),
      lastBorderRadius = BorderRadius.horizontal(right: radius);
  _AnimatedTab({
    Key key,
    @required this.child,
    @required this.scaleAnimation,
    @required this.selectedTabAnimation,
    @required this.beginIconThemeData,
    @required this.endIconThemeData,
    @required Listenable listenable,
    @required this.index,
    @required this.offset,
    @required this.last,
    @required this.first,
    @required this.onTap,
  })  : beginDecoration = first
            ? BoxDecoration(
                borderRadius: firstBorderRadius,
                color: AbiliaColors.white,
                border: beginBorder)
            : last
                ? BoxDecoration(
                    borderRadius: lastBorderRadius,
                    color: AbiliaColors.white,
                    border: beginBorder,
                  )
                : BoxDecoration(
                    borderRadius: BorderRadius.zero,
                    color: AbiliaColors.white,
                    border: beginBorder),
        endDecoration = first
            ? BoxDecoration(
                borderRadius: firstBorderRadius,
                color: AbiliaColors.transparentWhite20,
                border: endBorder)
            : last
                ? BoxDecoration(
                    borderRadius: lastBorderRadius,
                    color: AbiliaColors.transparentWhite20,
                    border: endBorder,
                  )
                : BoxDecoration(
                    borderRadius: BorderRadius.zero,
                    color: AbiliaColors.transparentWhite20,
                    border: endBorder),
        super(key: key, listenable: listenable);

  final Widget child;
  final Animation<double> selectedTabAnimation;
  final Animation<double> scaleAnimation;
  final int index, offset;
  final Decoration beginDecoration, endDecoration;
  final bool last, first;
  final IconThemeData beginIconThemeData, endIconThemeData;
  final GestureTapCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scaleValue = scaleAnimation.value;
    final lerpValue =
        (selectedTabAnimation.value - index + offset).abs().clamp(0.0, 1.0);

    return InkWell(
      borderRadius: first
          ? borderRadiusLeft
          : last
              ? borderRadiusRight
              : null,
      onTap: onTap,
      child: Container(
        width: 64.0.s * scaleAnimation.value,
        height: 48.0.s,
        margin: last
            ? EdgeInsets.only(left: 1.0.s)
            : first
                ? EdgeInsets.only(right: 1.0.s)
                : EdgeInsets.symmetric(
                    horizontal: 1.0.s * scaleAnimation.value),
        decoration: DecorationTween(begin: beginDecoration, end: endDecoration)
            .lerp(lerpValue),
        child: scaleAnimation.value == 0.0
            ? null
            : IconTheme(
                data: IconThemeData.lerp(
                    beginIconThemeData, endIconThemeData, lerpValue),
                child: Transform(
                  transform: Matrix4.identity()
                    ..scale(scaleValue, scaleValue, 1.0),
                  alignment: Alignment.center,
                  child: Opacity(
                    opacity: scaleValue,
                    child: child,
                  ),
                ),
              ),
      ),
    );
  }
}
