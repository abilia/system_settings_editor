import 'package:memoplanner/bloc/all.dart';
import 'package:memoplanner/ui/all.dart';

class ConfirmFactoryResetDialog extends StatelessWidget {
  final ResetDeviceCubit resetDeviceCubit;

  const ConfirmFactoryResetDialog({required this.resetDeviceCubit, super.key});

  @override
  Widget build(BuildContext context) {
    final translate = Translator.of(context).translate;
    final dialogLayout = layout.resetDeviceDialog;
    final factoryResetState = resetDeviceCubit.state;
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
            SizedBox(height: dialogLayout.titleToImageDistance),
            AbiliaTextInput(
              initialValue: factoryResetState.input,
              icon: AbiliaIcons.contact,
              heading: translate.factoryResetCode,
              inputHeading: translate.factoryResetCode,
              autoCorrect: false,
              errorState: !factoryResetState.correctInputOrEmpty,
              wrapWithAuthProviders: false,
              onChanged: !isResetting ? _onNewInput : null,
            ),
            SizedBox(
              width: double.infinity,
              child: Tts(
                child: Text(
                  _errorText(context),
                  textAlign: TextAlign.left,
                  style: Theme.of(context)
                      .textTheme
                      .bodyText2
                      ?.copyWith(color: AbiliaColors.red),
                ),
              ),
            ),
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
          onPressed: factoryResetState.correctInput && !isResetting
              ? () => _factoryResetDevice(context)
              : null,
        ),
      ),
    );
  }

  String _errorText(BuildContext context) {
    final translate = Translator.of(context).translate;
    final factoryResetState = context.read<ResetDeviceCubit>().state;
    if (!factoryResetState.correctInputOrEmpty) {
      return translate.wrongResetCode;
    }
    if (factoryResetState is FactoryResetFailed) {
      return translate.factoryResetFailed;
    }
    return '';
  }

  void _onNewInput(String input) {
    resetDeviceCubit.setInput(input);
  }

  void _factoryResetDevice(BuildContext context) =>
      context.read<ResetDeviceCubit>().factoryResetDevice();
}
