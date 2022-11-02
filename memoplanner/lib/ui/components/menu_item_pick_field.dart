import 'package:seagull/bloc/all.dart';
import 'package:seagull/ui/all.dart';
import 'package:seagull/utils/all.dart';

class MenuItemPickField extends StatelessWidget {
  final IconData icon;
  final String text;
  final Widget navigateTo;
  const MenuItemPickField({
    required this.icon,
    required this.text,
    required this.navigateTo,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authProviders = copiedAuthProviders(context);

    return PickField(
      leading: Icon(icon),
      text: Text(text),
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => MultiBlocProvider(
            providers: authProviders,
            child: navigateTo,
          ),
          settings: RouteSettings(name: text),
        ),
      ),
    );
  }
}
