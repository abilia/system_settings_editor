import 'package:flutter/material.dart';
import 'package:seagull/ui/all.dart';

class AbiliaTabBar extends StatelessWidget implements PreferredSizeWidget {
  const AbiliaTabBar({
    Key key,
    @required this.tabs,
    this.size = const Size.fromHeight(64.0),
    @required this.collapsedCondition,
  }) : super(key: key);

  final List<Widget> tabs;
  final Size size;

  final bool Function(int index) collapsedCondition;

  @override
  Size get preferredSize => size;

  @override
  Widget build(BuildContext context) {
    final wrappedTabs = List<Widget>(tabs.length);
    var offset = 0;
    for (var i = 0; i < tabs.length; i++) {
      wrappedTabs[i] = _Tab(
        index: i,
        offset: offset,
        last: (tabs.length - 1) == i,
        collapsed: () => collapsedCondition(i),
        child: tabs[i],
        controller: DefaultTabController.of(context),
      );
      if (collapsedCondition(i)) offset++;
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: wrappedTabs,
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
    return InkWell(
      onTap: () => widget.controller.animateTo(widget.index - widget.offset),
      child: Row(
        children: <Widget>[
          _AnimatedTab(
            child: widget.child,
            selectedTabAnimation: widget.controller.animation,
            scaleAnimation: _scaleAnimation,
            listenable: Listenable.merge(
                [widget.controller.animation, _collapsedController]),
            index: widget.index,
            offset: widget.offset,
            first: widget.index == 0,
            last: widget.last,
            beginIconThemeData: iconTheme.copyWith(size: smallIconSize),
            endIconThemeData: iconTheme.copyWith(
                color: AbiliaColors.white, size: smallIconSize),
          )
        ],
      ),
    );
  }
}

class _AnimatedTab extends AnimatedWidget {
  static const beginBorder =
          Border.fromBorderSide(BorderSide(color: AbiliaColors.white)),
      endBorder = Border.fromBorderSide(
          BorderSide(color: AbiliaColors.transparentWhite30));
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
                : const BoxDecoration(
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

  @override
  Widget build(BuildContext context) {
    final scaleValue = scaleAnimation.value;
    final lerpValue =
        (selectedTabAnimation.value - index + offset).abs().clamp(0.0, 1.0);

    return Container(
      width: 64.0 * scaleAnimation.value,
      height: 48.0,
      margin: last
          ? const EdgeInsets.only(left: 1.0)
          : first
              ? const EdgeInsets.only(right: 1.0)
              : EdgeInsets.symmetric(horizontal: 1.0 * scaleAnimation.value),
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
      decoration: DecorationTween(begin: beginDecoration, end: endDecoration)
          .lerp(lerpValue),
    );
  }
}
