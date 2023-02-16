import 'package:flutter/material.dart';
import 'package:seagull_analytics/seagull_analytics.dart';

class TrackableTabBarView extends StatelessWidget {
  final List<Widget> children;
  final SeagullAnalytics analytics;

  const TrackableTabBarView({
    required this.children,
    required this.analytics,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return _TrackableTabBarView(
      controller: DefaultTabController.of(context),
      children: children,
      analytics: analytics,
    );
  }
}

class _TrackableTabBarView extends StatefulWidget {
  final List<Widget> children;
  final TabController controller;
  final SeagullAnalytics analytics;

  const _TrackableTabBarView({
    required this.children,
    required this.controller,
    required this.analytics,
  });

  @override
  State<_TrackableTabBarView> createState() => _TrackableTabBarViewState();
}

class _TrackableTabBarViewState extends State<_TrackableTabBarView> {
  late int _index;

  TabController get _controller => widget.controller;

  List<Widget> get _children => widget.children;

  @override
  void initState() {
    super.initState();
    _onTabViewed();
    _setOnTabViewedListener();
  }

  void _setOnTabViewedListener() {
    _controller.addListener(() {
      if (_index != _controller.index) {
        _onTabViewed();
      }
    });
  }

  void _onTabViewed() {
    _index = _controller.index;
    if (_children.length > _index) {
      final tab = _children[_index];
      _trackTab(tab);
    }
  }

  void _trackTab(Widget tab) {
    widget.analytics.trackNavigation(
      page: tab.runtimeType.toString(),
      action: NavigationAction.viewed,
    );
  }

  @override
  Widget build(BuildContext context) {
    return TabBarView(
      physics: const NeverScrollableScrollPhysics(),
      controller: _controller,
      children: _children,
    );
  }
}
