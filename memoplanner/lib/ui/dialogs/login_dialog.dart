import 'package:memoplanner/bloc/all.dart';
import 'package:memoplanner/ui/all.dart';

class LoginDialog extends StatefulWidget {
  final TermsOfUseCubit termsOfUseCubit;
  final bool showTermsOfUseDialog;
  final bool showStarterSetDialog;
  final bool showFullscreenAlarmDialog;

  int get numberOfDialogs => [
        showTermsOfUseDialog,
        showStarterSetDialog,
        showFullscreenAlarmDialog,
      ].fold(0, (i, showDialog) => showDialog ? ++i : i);

  const LoginDialog({
    required this.termsOfUseCubit,
    required this.showTermsOfUseDialog,
    required this.showStarterSetDialog,
    required this.showFullscreenAlarmDialog,
    Key? key,
  }) : super(key: key);

  @override
  State<LoginDialog> createState() => _LoginDialogState();
}

class _LoginDialogState extends State<LoginDialog>
    with TickerProviderStateMixin {
  late final TabController _tabController;

  List<Widget> get _dialogs => [
        if (widget.showTermsOfUseDialog)
          TermsOfUseDialog(
            termsOfUseCubit: widget.termsOfUseCubit,
            isMoreDialogs: _tabController.length > 1,
            onNext: onNext,
          ),
        if (widget.showStarterSetDialog)
          StarterSetDialog(
            onNext: onNext,
          ),
        if (widget.showFullscreenAlarmDialog)
          FullscreenAlarmInfoDialog(
            showRedirect: true,
            onNext: onNext,
          ),
      ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: widget.numberOfDialogs, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return TabBarView(
      physics: const NeverScrollableScrollPhysics(),
      controller: _tabController,
      children: _dialogs,
    );
  }

  void onNext() {
    if (_tabController.index == _tabController.length - 1) {
      return Navigator.of(context).pop();
    }
    _tabController.index++;
  }
}
