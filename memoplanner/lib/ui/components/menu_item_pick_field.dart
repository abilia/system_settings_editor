import 'package:memoplanner/bloc/all.dart';
import 'package:memoplanner/ui/all.dart';
import 'package:memoplanner/utils/all.dart';

class MenuItemPickField extends StatelessWidget {
  final IconData icon;
  final String text;
  final Widget navigateTo;
  const MenuItemPickField({
    required this.icon,
    required this.text,
    required this.navigateTo,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final authProviders = copiedAuthProviders(context);

    return PickField(
      leading: Icon(icon),
      text: Text(text),
      onTap: () async => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => MultiBlocProvider(
            providers: authProviders,
            child: navigateTo,
          ),
          settings: navigateTo.runtimeType.routeSetting(),
        ),
      ),
    );
  }
}
