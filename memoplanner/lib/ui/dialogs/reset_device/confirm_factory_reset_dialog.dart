import 'package:memoplanner/bloc/all.dart';
import 'package:memoplanner/ui/all.dart';

class ConfirmFactoryResetDialog extends StatelessWidget {
  final ResetDeviceCubit resetDeviceCubit;

  const ConfirmFactoryResetDialog({required this.resetDeviceCubit, super.key});

  @override
  Widget build(BuildContext context) {
    final isConnected = context.watch<ConnectivityCubit>().state.isConnected;
    final translate = Translator.of(context).translate;
    final dialogLayout = layout.resetDeviceDialog;
    final isResetting = resetDeviceCubit.isResetting;
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
                style: Theme.of(context).textTheme.headline6,
              ),
            ),
            SizedBox(height: dialogLayout.textToTextDistance),
            Tts(
              child: Text(
                translate.confirmFactoryResetDescription,
                style: Theme.of(context).textTheme.bodyText2,
              ),
            ),
            if (!isConnected) ...[
              SizedBox(height: dialogLayout.bodyToTextDistance),
              const NoInternetErrorMessage(),
            ],
            SizedBox(height: dialogLayout.verticalPadding),
          ],
        ),
        backNavigationWidget: GreyButton(
          text: translate.cancel,
          icon: AbiliaIcons.closeProgram,
          onPressed: !isResetting ? Navigator.of(context).maybePop : null,
        ),
        forwardNavigationWidget: RedButton(
          text: translate.factoryReset,
          icon: AbiliaIcons.reset,
          onPressed: !isResetting && isConnected ? _factoryResetDevice : null,
        ),
      ),
    );
  }

  void _factoryResetDevice() => resetDeviceCubit.factoryResetDevice();
}
