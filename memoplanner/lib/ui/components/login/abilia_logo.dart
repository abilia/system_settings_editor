import 'package:memoplanner/ui/all.dart';

class AbiliaLogo extends StatelessWidget {
  const AbiliaLogo({super.key});

  @override
  Widget build(BuildContext context) {
    return FadeInImage(
      fadeInDuration: const Duration(milliseconds: 50),
      fadeInCurve: Curves.linear,
      placeholder: MemoryImage(kTransparentImage),
      image: AssetImage(
        'assets/graphics/${Config.flavor.id}/abilia.png',
      ),
    );
  }
}
