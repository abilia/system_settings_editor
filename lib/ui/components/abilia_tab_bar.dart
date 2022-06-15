import 'package:seagull/ui/all.dart';

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
    Key? key,
    required this.tabs,
    this.collapsedCondition,
    this.onTabTap,
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
    Key? key,
    required this.tabs,
    this.collapsedCondition,
    this.onTabTap,
  }) : super(key: key);

  final List<Widget> tabs;

  final bool Function(int index)? collapsedCondition;
  final void Function(int index)? onTabTap;
  bool Function(int) get isCollapsed => collapsedCondition ?? (_) => false;

  @override
  Widget build(BuildContext context) {
    var offset = 0;
    final tabController = DefaultTabController.of(context);
    final wrappedTabs = [
      if (tabController != null)
        for (var i = 0; i < tabs.length; i++)
          _Tab(
            index: i,
            offset: isCollapsed(i) ? offset++ : offset,
            last: (tabs.length - 1) == i,
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
    Key? key,
    required this.index,
    required this.offset,
    required this.last,
    required this.collapsed,
    required this.child,
    required this.controller,
    this.onTabTap,
  }) : super(key: key);

  final int index, offset;
  final bool last;
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
  late bool collapsed;

  @override
  void initState() {
    super.initState();
    collapsed = widget.collapsed();
    _collapsedController =
        AnimationController(vsync: this, duration: kTabScrollDuration);
    _collapseAnimation = _collapsedController
        .drive(ReverseTween<double>(Tween<double>(begin: 0.0, end: 1.0)));
    if (collapsed) {
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
      first: widget.index == 0,
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
    Key? key,
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
  })  : selectedDecoration = first
            ? BoxDecoration(
                borderRadius: firstBorderRadius,
                color: AbiliaColors.white,
              )
            : last
                ? BoxDecoration(
                    borderRadius: lastBorderRadius,
                    color: AbiliaColors.white,
                  )
                : const BoxDecoration(color: AbiliaColors.white),
        notSelectedBorder = first
            ? BoxDecoration(
                borderRadius: firstBorderRadius,
                color: AbiliaColors.transparentWhite30,
              )
            : last
                ? BoxDecoration(
                    borderRadius: lastBorderRadius,
                    color: AbiliaColors.transparentWhite30,
                  )
                : const BoxDecoration(color: AbiliaColors.transparentWhite30),
        notSelectedInnerDecoration = first
            ? BoxDecoration(
                borderRadius: firstInnerBorderRadius,
                color: AbiliaColors.transparentWhite20,
              )
            : last
                ? BoxDecoration(
                    borderRadius: lastInnerBorderRadius,
                    color: AbiliaColors.transparentWhite20,
                  )
                : const BoxDecoration(color: AbiliaColors.transparentWhite20),
        padding = first
            ? EdgeInsets.only(
                left: layout.tabBar.item.border,
                top: layout.tabBar.item.border,
                bottom: layout.tabBar.item.border)
            : last
                ? EdgeInsets.only(
                    top: layout.tabBar.item.border,
                    right: layout.tabBar.item.border,
                    bottom: layout.tabBar.item.border)
                : EdgeInsets.symmetric(vertical: layout.tabBar.item.border),
        super(key: key, listenable: listenable);

  final Widget child;
  final Animation<double> selectedTabAnimation;
  final Animation<double> collapsedAnimation;
  final int index, offset;
  final bool last, first;
  final IconThemeData beginIconThemeData, endIconThemeData;
  final TextStyle beginTextStyle, endTextStyle;
  final GestureTapCallback onTap;

  final BoxDecoration selectedDecoration,
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
      borderRadius: first
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
              padding: last
                  ? EdgeInsets.only(left: marginValue)
                  : first
                      ? EdgeInsets.only(right: marginValue)
                      : EdgeInsets.symmetric(horizontal: marginValue),
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
