import 'package:seagull/ui/all.dart';

class SettingsBasePage extends StatelessWidget {
  final List<Widget> widgets;
  final IconData icon;
  final String title;
  const SettingsBasePage({
    Key key,
    @required this.widgets,
    @required this.icon,
    @required this.title,
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
      bottomNavigationBar: const BottomNavigation(
        backNavigationWidget: BackButton(),
      ),
    );
  }
}
