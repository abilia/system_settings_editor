import 'package:memoplanner/ui/all.dart';

class TabControlledButton extends StatelessWidget {
  final String text;
  final IconData iconData;

  final int tabIndex;
  const TabControlledButton(
    this.text,
    this.iconData, {
    required this.tabIndex,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => DefaultTabControllerBuilder(
        builder: (context, controller) => TextAndOrIconActionButtonLight(
          text,
          iconData,
          onPressed: () => controller?.index = tabIndex,
          selected: controller?.index == tabIndex,
        ),
      );
}
