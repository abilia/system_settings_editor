import 'package:seagull/bloc/all.dart';
import 'package:seagull/ui/all.dart';

class MenuButton extends StatefulWidget {
  const MenuButton({
    Key? key,
    required this.tabIndex,
  }) : super(key: key);

  final int tabIndex;

  @override
  State<MenuButton> createState() => _MenuButtonState();
}

class _MenuButtonState extends State<MenuButton> {
  TabController? controller;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (controller == null) {
      controller = DefaultTabController.of(context);
      controller?.addListener(_tabControllerListener);
    }
  }

  @override
  void dispose() {
    controller?.removeListener(_tabControllerListener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocSelector<PermissionBloc, PermissionState, bool>(
      selector: (state) => state.importantPermissionMissing,
      builder: (context, importantPermissionMissing) {
        return Stack(
          clipBehavior: Clip.none,
          children: [
            TextAndOrIconActionButtonLight(
              Translator.of(context).translate.menu,
              AbiliaIcons.appMenu,
              onPressed: () {
                controller?.index = widget.tabIndex;
              },
              selected: controller?.index == widget.tabIndex,
            ),
            if (importantPermissionMissing)
              Positioned(
                top: -3.s,
                right: -3.s,
                child: const OrangeDot(),
              ),
          ],
        );
      },
    );
  }

  _tabControllerListener() => setState(() {});
}
