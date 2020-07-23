import 'package:flutter/material.dart';
import 'package:seagull/ui/colors.dart';
import 'package:seagull/ui/theme.dart';

class AbiliaTabBar extends StatelessWidget implements PreferredSizeWidget {
  const AbiliaTabBar({
    Key key,
    @required this.tabs,
    this.size = const Size.fromHeight(64),
  }) : super(key: key);

  final List<Widget> tabs;
  final Size size;

  @override
  Size get preferredSize => size;

  @override
  Widget build(BuildContext context) {
    final wrappedTabs = List<Widget>(tabs.length);

    for (var i = 0; i < tabs.length; i++) {
      wrappedTabs[i] = _Tab(
        index: i,
        tabs: tabs.length,
        child: tabs[i],
        controller: DefaultTabController.of(context),
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: wrappedTabs,
    );
  }
}

class _Tab extends StatelessWidget {
  const _Tab({
    Key key,
    @required this.index,
    @required this.tabs,
    @required this.child,
    @required this.controller,
  })  : last = index == tabs - 1,
        super(key: key);

  final int index, tabs;
  final bool last;
  final Widget child;
  final TabController controller;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => controller.animateTo(index),
      child: Row(
        children: <Widget>[
          Padding(
            padding:
                !last ? const EdgeInsets.only(right: 2.0) : EdgeInsets.zero,
            child: _AnimatedTab(
              child: child,
              animation: controller.animation,
              index: index,
              first: index == 0,
              last: last,
            ),
          )
        ],
      ),
    );
  }
}

class _AnimatedTab extends AnimatedWidget {
  const _AnimatedTab({
    Key key,
    @required this.child,
    @required this.animation,
    @required this.index,
    @required bool first,
    @required bool last,
  })  : beginDecoration = first
            ? const BoxDecoration(
                borderRadius: BorderRadius.horizontal(left: radius),
                color: AbiliaColors.white,
                border: Border.fromBorderSide(
                    BorderSide(color: AbiliaColors.white)))
            : last
                ? const BoxDecoration(
                    borderRadius: BorderRadius.horizontal(right: radius),
                    color: AbiliaColors.white,
                    border: Border.fromBorderSide(
                        BorderSide(color: AbiliaColors.white)),
                  )
                : const BoxDecoration(
                    borderRadius: BorderRadius.zero,
                    color: AbiliaColors.white,
                    border: Border.fromBorderSide(
                        BorderSide(color: AbiliaColors.white)),
                  ),
        endDecoration = first
            ? const BoxDecoration(
                borderRadius: BorderRadius.horizontal(left: radius),
                color: AbiliaColors.transparentWhite20,
                border: Border.fromBorderSide(
                    BorderSide(color: AbiliaColors.transparentWhite30)))
            : last
                ? const BoxDecoration(
                    borderRadius: BorderRadius.horizontal(right: radius),
                    color: AbiliaColors.transparentWhite20,
                    border: Border.fromBorderSide(
                        BorderSide(color: AbiliaColors.transparentWhite30)),
                  )
                : const BoxDecoration(
                    borderRadius: BorderRadius.zero,
                    color: AbiliaColors.transparentWhite20,
                    border: Border.fromBorderSide(
                        BorderSide(color: AbiliaColors.transparentWhite30)),
                  ),
        super(key: key, listenable: animation);

  final Widget child;
  final Animation<double> animation;
  final int index;
  final Decoration beginDecoration, endDecoration;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
      child: child,
      decoration: DecorationTween(begin: beginDecoration, end: endDecoration)
          .lerp((animation.value - index).abs().clamp(0.0, 1.0)),
    );
  }
}
