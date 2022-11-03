import 'package:memoplanner/ui/all.dart';

class SettingsBasePage extends StatelessWidget {
  final List<Widget> widgets;
  final IconData icon;
  final String title;
  final String? label;
  final Widget? bottomNavigationBar;
  const SettingsBasePage({
    required this.widgets,
    required this.icon,
    required this.title,
    this.label,
    this.bottomNavigationBar,
    Key? key,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AbiliaAppBar(
        title: title,
        label: label,
        iconData: icon,
      ),
      body: DividerTheme(
        data: layout.settingsBasePage.dividerThemeData,
        child: ListView.builder(
          padding: layout.templates.m1.onlyTop,
          itemBuilder: (context, i) {
            final w = widgets[i];
            if (w is Divider) return w;
            return Padding(
              padding: i == 0 ? m1ItemPadding.withoutTop : m1ItemPadding,
              child: w,
            );
          },
          itemCount: widgets.length,
        ),
      ),
      bottomNavigationBar: bottomNavigationBar ??
          const BottomNavigation(backNavigationWidget: PreviousButton()),
    );
  }
}

class SettingsTab extends StatelessWidget {
  final double? dividerPadding;
  const SettingsTab({
    Key? key,
    this.children = const [],
    this.dividerPadding,
  }) : super(key: key);
  final List<Widget> children;
  @override
  Widget build(BuildContext context) {
    final padding = dividerPadding ?? layout.formPadding.groupBottomDistance;
    final scrollController = ScrollController();
    return DefaultTextStyle(
      style: (Theme.of(context).textTheme.bodyText2 ?? bodyText2)
          .copyWith(color: AbiliaColors.black75),
      child: ScrollArrows.vertical(
        controller: scrollController,
        child: ListView(
          controller: scrollController,
          padding: EdgeInsets.only(
            top: layout.templates.m1.top,
            bottom: layout.templates.m1.bottom,
          ),
          children: [
            ...children.map(
              (w) => w is Divider
                  ? Padding(
                      padding: EdgeInsets.symmetric(vertical: padding),
                      child: w,
                    )
                  : Padding(
                      padding: m1ItemPadding,
                      child: w,
                    ),
            )
          ],
        ),
      ),
    );
  }
}
