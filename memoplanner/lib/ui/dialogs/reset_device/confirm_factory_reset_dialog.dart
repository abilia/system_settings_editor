import 'package:memoplanner/bloc/all.dart';
import 'package:memoplanner/ui/all.dart';

class ConfirmFactoryResetDialog extends StatefulWidget {
  const ConfirmFactoryResetDialog({Key? key}) : super(key: key);

  @override
  State<ConfirmFactoryResetDialog> createState() =>
      _ConfirmFactoryResetDialogState();
}

class _ConfirmFactoryResetDialogState extends State<ConfirmFactoryResetDialog> {
  static const String _factoryResetCode = 'FactoryresetMP4';
  String _input = '';

  bool get _correctInputOrEmpty => _correctInput || _input.isEmpty;

  bool get _correctInput => _input == _factoryResetCode;

  @override
  Widget build(BuildContext context) {
    final translate = Translator.of(context).translate;
    final dialogLayout = layout.resetDeviceDialog;
    final isResetting = context.watch<FactoryResetCubit>().isResetting;
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
              initialValue: _input,
              icon: AbiliaIcons.contact,
              heading: translate.factoryResetCode,
              inputHeading: translate.factoryReset,
              autoCorrect: false,
              errorState: !_correctInputOrEmpty,
              wrapWithAuthProviders: false,
              onChanged: !isResetting ? _onNewInput : null,
            ),
            SizedBox(
              width: double.infinity,
              child: Tts(
                child: Text(
                  _errorText,
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
          onPressed: _correctInput && !isResetting ? _factoryResetDevice : null,
        ),
      ),
    );
  }

  String get _errorText {
    final translate = Translator.of(context).translate;
    final factoryResetCubit = context.read<FactoryResetCubit>();
    if (!_correctInputOrEmpty) {
      return translate.wrongResetCode;
    }
    if (factoryResetCubit.state is FactoryResetFailed) {
      return translate.factoryResetFailed;
    }
    return '';
  }

  void _onNewInput(String input) {
    setState(() {
      _input = input;
    });
  }

  void _factoryResetDevice() =>
      context.read<FactoryResetCubit>().factoryResetDevice();
}
