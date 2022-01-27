import 'package:seagull/ui/all.dart';

class SettingsBasePage extends StatelessWidget {
  final List<Widget> widgets;
  final IconData icon;
  final String title;
  final Widget? bottomNavigationBar;
  const SettingsBasePage({
    Key? key,
    required this.widgets,
    required this.icon,
    required this.title,
    this.bottomNavigationBar,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AbiliaAppBar(
        title: title,
        iconData: icon,
      ),
      body: ListView.builder(
        padding:
            EdgeInsets.symmetric(vertical: layout.settingsBasePage.listPadding),
        itemBuilder: (context, i) {
          final w = widgets[i];
          if (w is Divider) {
            return Padding(
              padding: layout.settingsBasePage.dividerExtraPadding,
              child: w,
            );
          }
          return Padding(
            padding: layout.settingsBasePage.itemPadding,
            child: w,
          );
        },
        itemCount: widgets.length,
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
    final padding = dividerPadding ?? 16.s;
    return DefaultTextStyle(
      style: (Theme.of(context).textTheme.bodyText2 ?? bodyText2)
          .copyWith(color: AbiliaColors.black75),
      child: ListView(
        padding: EdgeInsets.symmetric(vertical: 20.s),
        children: [
          ...children.map(
            (w) => w is Divider
                ? Padding(
                    padding: EdgeInsets.symmetric(vertical: padding),
                    child: w,
                  )
                : Padding(
                    padding: layout.settingsBasePage.itemPadding,
                    child: w,
                  ),
          )
        ],
      ),
    );
  }
}
