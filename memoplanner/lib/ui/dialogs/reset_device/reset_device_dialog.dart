import 'package:get_it/get_it.dart';
import 'package:memoplanner/bloc/all.dart';
import 'package:memoplanner/db/all.dart';
import 'package:memoplanner/repository/all.dart';
import 'package:memoplanner/ui/all.dart';

class ResetDeviceDialog extends StatelessWidget {
  const ResetDeviceDialog({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ResetDeviceCubit>(
      create: (context) => ResetDeviceCubit(
        factoryResetRepository: FactoryResetRepository(
          deviceDb: GetIt.I<DeviceDb>(),
          baseUrlDb: GetIt.I<BaseUrlDb>(),
          client: GetIt.I<ListenableClient>(),
        ),
      ),
      child: const _ResetDeviceDialog(),
    );
  }
}

class _ResetDeviceDialog extends StatelessWidget {
  const _ResetDeviceDialog();

  @override
  Widget build(BuildContext context) {
    final pageController = PageController();
    return TrackablePageView(
      controller: pageController,
      analytics: GetIt.I<SeagullAnalytics>(),
      children: [
        FactoryResetOrClearDataDialog(
          pageController: pageController,
        ),
        const ConfirmFactoryResetDialog(),
      ],
    );
  }
}
