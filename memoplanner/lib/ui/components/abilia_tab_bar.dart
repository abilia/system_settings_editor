import 'dart:math';

import 'package:memoplanner/ui/all.dart';

class TabItem extends StatelessWidget {
  final String text;
  final IconData iconData;
  const TabItem(
    this.text,
    this.iconData, {
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => Tts.data(
        data: text,
        child: Column(
          children: [
            Text(text),
            SizedBox(height: layout.actionButton.spacing),
            Icon(iconData),
          ],
        ),
      );
}

class AbiliaTabBar extends StatelessWidget implements PreferredSizeWidget {
  const AbiliaTabBar({
    required this.tabs,
    this.collapsedCondition,
    this.onTabTap,
    Key? key,
  }) : super(key: key);

  final List<Widget> tabs;

  final bool Function(int index)? collapsedCondition;
  final void Function(int index)? onTabTap;
  bool Function(int) get isCollapsed => collapsedCondition ?? (_) => false;

  @override
  Size get preferredSize => Size.fromHeight(layout.tabBar.height);

  @override
  Widget build(BuildContext context) => Padding(
        padding: EdgeInsets.only(bottom: layout.tabBar.bottomPadding),
        child: AbiliaTabs(
          tabs: tabs,
          collapsedCondition: collapsedCondition,
          onTabTap: onTabTap,
        ),
      );
}

class AbiliaTabs extends StatelessWidget {
  const AbiliaTabs({
    required this.tabs,
    this.collapsedCondition,
    this.onTabTap,
    this.useOffset = true,
    Key? key,
  }) : super(key: key);

  final List<Widget> tabs;
  final bool useOffset;

  final bool Function(int index)? collapsedCondition;
  final void Function(int index)? onTabTap;
  bool Function(int) get isCollapsed => collapsedCondition ?? (_) => false;

  @override
  Widget build(BuildContext context) {
    final nonCollapsedIndexes =
        [for (var i = 0; i < tabs.length; i++) i].where((j) => !isCollapsed(j));

    if (nonCollapsedIndexes.isEmpty) {
      return const SizedBox.shrink();
    }

    var offset = 0;
    int incrementOffset(int i) {
      if (useOffset) {
        return isCollapsed(i) ? offset++ : offset;
      }
      return 0;
    }

    final tabController = DefaultTabController.of(context);
    final wrappedTabs = [
      if (tabController != null)
        for (var i = 0; i < tabs.length; i++)
          _Tab(
            index: i,
            offset: incrementOffset(i),
            first: i == nonCollapsedIndexes.reduce(min),
            last: i == nonCollapsedIndexes.reduce(max),
            collapsed: () => isCollapsed(i),
            controller: tabController,
            onTabTap: onTabTap,
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
    required this.index,
    required this.offset,
    required this.first,
    required this.last,
    required this.collapsed,
    required this.child,
    required this.controller,
    this.onTabTap,
    Key? key,
  }) : super(key: key);

  final int index, offset;
  final bool first, last;
  final Widget child;
  final TabController controller;
  final bool Function() collapsed;
  final void Function(int index)? onTabTap;

  @override
  _TabState createState() => _TabState();
}

class _TabState extends State<_Tab> with SingleTickerProviderStateMixin {
  _TabState();
  late AnimationController _collapsedController;
  late Animation<double> _collapseAnimation;
  late bool _collapsed;

  @override
  void initState() {
    super.initState();
    _collapsed = widget.collapsed();
    _collapsedController =
        AnimationController(vsync: this, duration: kTabScrollDuration);
    _collapseAnimation = _collapsedController
        .drive(ReverseTween<double>(Tween<double>(begin: 0.0, end: 1.0)));
    if (_collapsed) {
      _collapsedController.forward(from: 1.0);
    }
  }

  @override
  void dispose() {
    _collapsedController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(_Tab oldWidget) {
    final collapsed = widget.collapsed();
    if (collapsed != _collapsed) {
      if (collapsed) {
        _collapsedController.forward();
      } else {
        _collapsedController.reverse();
      }
      _collapsed = collapsed;
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    final iconTheme = IconTheme.of(context);
    final textStyle =
        (Theme.of(context).textTheme.caption ?? caption).copyWith(height: 1);
    final controllerAnimation = widget.controller.animation;
    if (controllerAnimation == null) throw 'TabController missing animation';
    return _AnimatedTab(
      selectedTabAnimation: controllerAnimation,
      collapsedAnimation: _collapseAnimation,
      listenable:
          Listenable.merge([widget.controller.animation, _collapsedController]),
      index: widget.index,
      offset: widget.offset,
      first: widget.first,
      last: widget.last,
      beginIconThemeData: iconTheme.copyWith(
        size: layout.actionButton.withTextIconSize,
      ),
      endIconThemeData: iconTheme.copyWith(
        color: AbiliaColors.white,
        size: layout.actionButton.withTextIconSize,
      ),
      beginTextStyle: textStyle,
      endTextStyle: textStyle.copyWith(color: AbiliaColors.white),
      onTap: () {
        widget.onTabTap?.call(widget.index - widget.offset);
        widget.controller.animateTo(widget.index - widget.offset);
      },
      child: widget.child,
    );
  }
}

class _AnimatedTab extends AnimatedWidget {
  static final firstBorderRadius = BorderRadius.horizontal(left: radius),
      lastBorderRadius = BorderRadius.horizontal(right: radius),
      firstInnerBorderRadius = BorderRadius.horizontal(
          left: innerRadiusFromBorderSize(layout.tabBar.item.border)),
      lastInnerBorderRadius = BorderRadius.horizontal(
          right: innerRadiusFromBorderSize(layout.tabBar.item.border));
  _AnimatedTab({
    required this.child,
    required this.collapsedAnimation,
    required this.selectedTabAnimation,
    required this.beginIconThemeData,
    required this.endIconThemeData,
    required this.beginTextStyle,
    required this.endTextStyle,
    required Listenable listenable,
    required this.index,
    required this.offset,
    required this.last,
    required this.first,
    required this.onTap,
    Key? key,
  })  : padding = EdgeInsets.only(
          left: first ? layout.tabBar.item.border : 0,
          right: last ? layout.tabBar.item.border : 0,
          top: layout.tabBar.item.border,
          bottom: layout.tabBar.item.border,
        ),
        super(key: key, listenable: listenable) {
    selectedDecoration =
        const BoxDecoration(color: AbiliaColors.white).copyWith(
      borderRadius: first && last
          ? firstBorderRadius + lastBorderRadius
          : first
              ? firstBorderRadius
              : last
                  ? lastBorderRadius
                  : null,
    );
    notSelectedBorder = selectedDecoration.copyWith(
      color: AbiliaColors.transparentWhite30,
    );
    notSelectedInnerDecoration =
        const BoxDecoration(color: AbiliaColors.transparentWhite20).copyWith(
      borderRadius: first && last
          ? firstInnerBorderRadius + lastInnerBorderRadius
          : first
              ? firstInnerBorderRadius
              : last
                  ? lastInnerBorderRadius
                  : null,
    );
  }
  final Widget child;
  final Animation<double> selectedTabAnimation;
  final Animation<double> collapsedAnimation;
  final int index, offset;
  final bool last, first;
  final IconThemeData beginIconThemeData, endIconThemeData;
  final TextStyle beginTextStyle, endTextStyle;
  final GestureTapCallback onTap;

  late final BoxDecoration selectedDecoration,
      notSelectedBorder,
      notSelectedInnerDecoration;

  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    final collapsedValue = collapsedAnimation.value;
    final selectedValue =
        (selectedTabAnimation.value - index + offset).abs().clamp(0.0, 1.0);
    final marginValue = layout.tabBar.item.border * collapsedValue / 2;
    return InkWell(
      borderRadius: first && last
          ? borderRadiusLeft + borderRadiusRight
          : first
              ? borderRadiusLeft
              : last
                  ? borderRadiusRight
                  : null,
      onTap: onTap,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minWidth: layout.tabBar.item.width * collapsedValue,
          maxWidth: layout.tabBar.item.width * 2 * collapsedValue,
        ),
        child: Ink(
          decoration: DecorationTween(
            begin: selectedDecoration,
            end: notSelectedBorder,
          ).lerp(selectedValue),
          height: layout.actionButton.size,
          padding: padding,
          child: Ink(
            decoration: DecorationTween(
              end: notSelectedInnerDecoration.copyWith(
                color: AbiliaColors.black80,
              ),
            ).lerp(selectedValue),
            child: Padding(
              padding: EdgeInsets.only(
                left: first ? 0 : marginValue,
                right: last ? 0 : marginValue,
              ),
              child: Ink(
                decoration: DecorationTween(
                  begin: null,
                  end: notSelectedInnerDecoration,
                ).lerp(selectedValue),
                child: collapsedValue == 0.0
                    ? null
                    : Padding(
                        padding: layout.tabBar.item.padding
                            .subtract(padding.onlyTop),
                        child: DefaultTextStyle(
                          maxLines: 1,
                          overflow: TextOverflow.clip,
                          style: TextStyle.lerp(
                                beginTextStyle,
                                endTextStyle,
                                selectedValue,
                              ) ??
                              beginTextStyle,
                          child: IconTheme(
                            data: IconThemeData.lerp(
                              beginIconThemeData,
                              endIconThemeData,
                              selectedValue,
                            ),
                            child: Transform(
                              transform: Matrix4.identity()
                                ..scale(collapsedValue, collapsedValue, 1.0),
                              alignment: Alignment.center,
                              child: Opacity(
                                opacity: collapsedValue,
                                child: child,
                              ),
                            ),
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
