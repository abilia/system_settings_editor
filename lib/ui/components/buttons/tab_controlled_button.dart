import 'package:seagull/ui/all.dart';

class TabControlledButton extends StatefulWidget {
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
  State<TabControlledButton> createState() => _TabControlledButtonState();
}

class _TabControlledButtonState extends State<TabControlledButton> {
  TabController? controller;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    controller?.removeListener(_tabControllerListener);
    controller = DefaultTabController.of(context)
      ?..addListener(_tabControllerListener);
  }

  @override
  void dispose() {
    controller?.removeListener(_tabControllerListener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextAndOrIconActionButtonLight(
      widget.text,
      widget.iconData,
      onPressed: () {
        controller?.index = widget.tabIndex;
      },
      selected: controller?.index == widget.tabIndex,
    );
  }

  void _tabControllerListener() => setState(() {});
}
