import 'package:memoplanner/ui/all.dart';

class DefaultTabControllerBuilder extends StatefulWidget {
  final Widget Function(BuildContext context, TabController? tabController)
      builder;
  const DefaultTabControllerBuilder({
    required this.builder,
    super.key,
  });

  @override
  State<DefaultTabControllerBuilder> createState() =>
      _DefaultTabControllerBuilderState();
}

class _DefaultTabControllerBuilderState
    extends State<DefaultTabControllerBuilder> {
  TabController? tabController;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    tabController?.removeListener(_tabControllerListener);
    tabController = DefaultTabController.of(context)
      ..addListener(_tabControllerListener);
  }

  @override
  void dispose() {
    tabController?.removeListener(_tabControllerListener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.builder(context, tabController);

  void _tabControllerListener() => setState(() {});
}
