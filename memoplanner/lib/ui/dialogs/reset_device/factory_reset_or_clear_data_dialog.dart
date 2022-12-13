import 'package:memoplanner/bloc/all.dart';
import 'package:memoplanner/ui/all.dart';
import 'package:memoplanner/utils/all.dart';

class FactoryResetOrClearDataDialog extends StatelessWidget {
  final PageController pageController;
  final ResetDeviceCubit resetDeviceCubit;

  const FactoryResetOrClearDataDialog({
    required this.pageController,
    required this.resetDeviceCubit,
    Key? key,
  }) : super(key: key);

  ResetType? get _resetType => resetDeviceCubit.state.resetType;

  bool get _isClearData => _resetType == ResetType.clearData;

  bool get _isFactoryReset => _resetType == ResetType.factoryReset;

  @override
  Widget build(BuildContext context) {
    final translate = Translator.of(context).translate;
    final isConnected = context.watch<ConnectivityCubit>().state.isConnected;
    final onNextClickable = _isClearData || _isFactoryReset && isConnected;
    return ViewDialog(
      bottomNavigationColor: ViewDialog.light,
      bodyPadding: layout.templates.m4,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: layout.resetDeviceDialog.verticalPadding),
          Center(
            child: Icon(
              AbiliaIcons.reset,
              size: layout.resetDeviceDialog.imageSize,
              color: AbiliaColors.red,
            ),
          ),
          SizedBox(height: layout.resetDeviceDialog.titleToImageDistance),
          Center(
            child: Tts(
              child: Text(
                translate.resetDeviceQuestion,
                style: Theme.of(context).textTheme.headline6,
              ),
            ),
          ),
          SizedBox(height: layout.resetDeviceDialog.bodyToTextDistance),
          RadioField(
            leading: const Icon(AbiliaIcons.irError),
            value: ResetType.factoryReset,
            groupValue: _resetType,
            text: Text(translate.factoryReset),
            onChanged: _onResetTypeChanged,
          ),
          SizedBox(height: layout.resetDeviceDialog.descriptionPadding),
          Tts(
            child: Text(
              translate.factoryResetDescription,
              textAlign: TextAlign.start,
              style: Theme.of(context).textTheme.bodyText2,
            ),
          ),
          if (_isFactoryReset && !isConnected) ...[
            SizedBox(height: layout.resetDeviceDialog.textToTextDistance),
            const NoInternetErrorMessage(),
          ],
          SizedBox(height: layout.resetDeviceDialog.titleToImageDistance),
          RadioField(
            leading: const Icon(AbiliaIcons.delete),
            value: ResetType.clearData,
            groupValue: _resetType,
            text: Text(translate.clearData),
            onChanged: _onResetTypeChanged,
          ),
          SizedBox(height: layout.resetDeviceDialog.descriptionPadding),
          Tts(
            child: Text(
              translate.clearDataDescription,
              style: Theme.of(context).textTheme.bodyText2,
            ),
          ),
          SizedBox(height: layout.resetDeviceDialog.verticalPadding),
        ],
      ),
      backNavigationWidget: LightGreyButton(
        text: translate.cancel,
        icon: AbiliaIcons.closeProgram,
        onPressed: Navigator.of(context).maybePop,
      ),
      forwardNavigationWidget: RedButton(
        text: translate.yes,
        icon: AbiliaIcons.checkButton,
        onPressed: onNextClickable ? () => _onNext(context) : null,
      ),
    );
  }

  void _onResetTypeChanged(ResetType? resetType) {
    resetDeviceCubit.setResetType(resetType);
  }

  void _onNext(BuildContext context) {
    if (_resetType == ResetType.factoryReset) {
      return _nextPage();
    } else if (_resetType == ResetType.clearData) {
      _clearMemoplannerData(context);
    }
  }

  void _nextPage() {
    pageController.nextPage(
      duration: 500.milliseconds(),
      curve: Curves.easeOutQuad,
    );
  }

  void _clearMemoplannerData(BuildContext context) {
    context.read<VoicesCubit>().resetSpeechSettings();
    context.read<StartupCubit>().resetStartGuideDone();
    Navigator.of(context).pop();
  }
}
