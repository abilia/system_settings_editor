import 'package:memoplanner/bloc/all.dart';
import 'package:memoplanner/ui/all.dart';

class ResetDeviceDialog extends StatelessWidget {
  const ResetDeviceDialog({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final pageController = PageController();
    final resetDeviceCubit = context.watch<ResetDeviceCubit>();
    return WillPopScope(
      onWillPop: () async {
        resetDeviceCubit.reset();
        return true;
      },
      child: PageView(
        controller: pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          FactoryResetOrClearDataDialog(
            pageController: pageController,
            resetDeviceCubit: resetDeviceCubit,
          ),
          ConfirmFactoryResetDialog(
            resetDeviceCubit: resetDeviceCubit,
          ),
        ],
      ),
    );
  }
}
