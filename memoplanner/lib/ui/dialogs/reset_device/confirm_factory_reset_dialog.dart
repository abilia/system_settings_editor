import 'package:memoplanner/bloc/all.dart';
import 'package:memoplanner/ui/all.dart';

class ConfirmFactoryResetDialog extends StatelessWidget {
  const ConfirmFactoryResetDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final isConnected = context.watch<ConnectivityCubit>().state.isConnected;
    final translate = Lt.of(context);
    final dialogLayout = layout.resetDeviceDialog;
    final resetDeviceCubit = context.watch<ResetDeviceCubit>();
    final isResetting = resetDeviceCubit.isResetting;
    final errorMessage = _errorMessage(
      context,
      isConnected,
      resetDeviceCubit.state,
    );
    return WillPopScope(
      onWillPop: () async => !isResetting,
      child: ViewDialog(
        bottomNavigationColor: ViewDialog.light,
        bodyPadding: layout.templates.m4,
        body: Column(
          children: [
            SizedBox(height: dialogLayout.verticalPadding),
            if (isResetting)
              SizedBox(
                width: dialogLayout.imageSize,
                height: dialogLayout.imageSize,
                child: const AbiliaProgressIndicator(),
              )
            else
              Icon(
                AbiliaIcons.irError,
                size: dialogLayout.imageSize,
                color: AbiliaColors.red,
              ),
            SizedBox(height: dialogLayout.titleToImageDistance),
            Tts(
              child: Text(
                translate.confirmFactoryReset,
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            SizedBox(height: dialogLayout.textToTextDistance),
            Tts(
              child: Text(
                translate.confirmFactoryResetDescription,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
            if (errorMessage != null) ...[
              SizedBox(height: dialogLayout.textToTextDistance),
              errorMessage,
            ],
            SizedBox(height: dialogLayout.verticalPadding),
          ],
        ),
        backNavigationWidget: LightGreyButton(
          text: translate.cancel,
          icon: AbiliaIcons.closeProgram,
          onPressed: !isResetting ? Navigator.of(context).maybePop : null,
        ),
        forwardNavigationWidget: RedButton(
          text: translate.factoryReset,
          icon: AbiliaIcons.reset,
          onPressed: !isResetting && isConnected
              ? resetDeviceCubit.factoryResetDevice
              : null,
        ),
      ),
    );
  }

  Widget? _errorMessage(
      BuildContext context, bool isConnected, ResetDeviceState state) {
    if (!isConnected) return const NoInternetErrorMessage();
    if (state is FactoryResetFailed) {
      return ErrorMessage(
        text: Text(Lt.of(context).factoryResetFailed),
      );
    }
    return null;
  }
}
