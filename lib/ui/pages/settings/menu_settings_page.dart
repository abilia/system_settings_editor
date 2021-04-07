import 'package:seagull/ui/all.dart';

class MenuSettingsPage extends StatelessWidget {
  const MenuSettingsPage({Key key}) : super(key: key);
  final widgets = const <Widget>[];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AbiliaAppBar(
          title: Translator.of(context).translate.menu,
          iconData: AbiliaIcons.app_menu),
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
