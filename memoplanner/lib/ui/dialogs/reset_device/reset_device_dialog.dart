import 'package:get_it/get_it.dart';
import 'package:memoplanner/bloc/all.dart';
import 'package:memoplanner/db/all.dart';
import 'package:memoplanner/repository/all.dart';
import 'package:memoplanner/ui/all.dart';

class ResetDeviceDialog extends StatelessWidget {
  const ResetDeviceDialog({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ResetDeviceCubit>(
      create: (context) => ResetDeviceCubit(
        factoryResetRepository: FactoryResetRepository(
          baseUrlDb: GetIt.I<BaseUrlDb>(),
          client: GetIt.I<ListenableClient>(),
        ),
      ),
      child: const _ResetDeviceDialog(),
    );
  }
}

class _ResetDeviceDialog extends StatelessWidget {
  const _ResetDeviceDialog({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final pageController = PageController();
    final resetDeviceCubit = context.watch<ResetDeviceCubit>();
    return PageView(
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
    );
  }
}
