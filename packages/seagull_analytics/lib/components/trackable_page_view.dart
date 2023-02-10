import 'package:flutter/material.dart';
import 'package:seagull_analytics/seagull_analytics.dart';

class TrackablePageView extends StatelessWidget {
  final PageController controller;
  final SeagullAnalytics analytics;
  final Widget Function(BuildContext context)? getPage;
  final List<Widget>? children;

  const TrackablePageView({
    required this.controller,
    required this.analytics,
    this.getPage,
    this.children,
    super.key,
  })  : assert(getPage != null || children != null),
        assert(getPage == null || children == null);

  @override
  Widget build(BuildContext context) {
    return PageView.builder(
      physics: const NeverScrollableScrollPhysics(),
      controller: controller,
      itemBuilder: (context, index) {
        final page = getPage?.call(context) ?? children?[index];
        if (page != null) _trackPage(page);
        return page;
      },
    );
  }

  void _trackPage(Widget page) {
    analytics.trackNavigation(
      page: page.runtimeType.toString(),
      action: NavigationAction.viewed,
      properties: {},
    );
  }
}
