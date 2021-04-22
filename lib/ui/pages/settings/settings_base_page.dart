import 'package:seagull/ui/all.dart';

class SettingsBasePage extends StatelessWidget {
  final List<Widget> widgets;
  final IconData icon;
  final String title;
  final Widget bottomNavigationBar;
  const SettingsBasePage({
    Key key,
    @required this.widgets,
    @required this.icon,
    @required this.title,
    this.bottomNavigationBar,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AbiliaAppBar(
        title: title,
        iconData: icon,
      ),
      body: ListView.separated(
        padding: EdgeInsets.fromLTRB(12.0.s, 20.0.s, 16.0.s, 20.0.s),
        itemBuilder: (context, i) => widgets[i],
        itemCount: widgets.length,
        separatorBuilder: (context, index) => SizedBox(height: 8.0.s),
      ),
      bottomNavigationBar: bottomNavigationBar ??
          const BottomNavigation(backNavigationWidget: BackButton()),
    );
  }
}

class SettingsTab extends StatelessWidget {
  final double dividerPadding;
  const SettingsTab({
    Key key,
    this.children = const [],
    this.dividerPadding,
  }) : super(key: key);
  final List<Widget> children;
  @override
  Widget build(BuildContext context) {
    final padding = dividerPadding ?? 16.s;
    return DefaultTextStyle(
      style: abiliaTextTheme.bodyText2.copyWith(color: AbiliaColors.black75),
      child: ListView(
        padding: EdgeInsets.symmetric(vertical: 20.s),
        children: [
          ...children.map(
            (w) => w is Divider
                ? Padding(
                    padding: EdgeInsets.only(top: padding, bottom: padding),
                    child: w,
                  )
                : Padding(
                    padding: EdgeInsets.fromLTRB(12.s, 8.s, 16.s, 0),
                    child: w,
                  ),
          )
        ],
      ),
    );
  }
}
