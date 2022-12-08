import 'package:memoplanner/ui/all.dart';

class ResetDeviceDialog extends StatelessWidget {
  const ResetDeviceDialog({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final pageController = PageController();
    return PageView(
      controller: pageController,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        FactoryResetOrClearDataDialog(pageController: pageController),
        const ConfirmFactoryResetDialog(),
      ],
    );
  }
}
