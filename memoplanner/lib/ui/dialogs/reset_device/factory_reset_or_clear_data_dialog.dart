import 'package:memoplanner/bloc/all.dart';
import 'package:memoplanner/ui/all.dart';
import 'package:memoplanner/utils/all.dart';

class FactoryResetOrClearDataDialog extends StatelessWidget {
  final PageController pageController;

  const FactoryResetOrClearDataDialog({
    required this.pageController,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final state = context.watch<ResetDeviceCubit>().state;

    final translate = Translator.of(context).translate;
    final isConnected = context.watch<ConnectivityCubit>().state.isConnected;
    final isClearData = state.resetType == ResetType.clearData;
    final isFactoryReset = state.resetType == ResetType.factoryReset;
    final onNextClickable = isClearData || isFactoryReset && isConnected;
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
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
          ),
          SizedBox(height: layout.resetDeviceDialog.bodyToTextDistance),
          RadioField(
            leading: const Icon(AbiliaIcons.irError),
            value: ResetType.factoryReset,
            groupValue: state.resetType,
            text: Text(translate.factoryReset),
            onChanged: (type) => _onResetTypeChanged(context, type),
          ),
          SizedBox(height: layout.resetDeviceDialog.descriptionPadding),
          Tts(
            child: Text(
              translate.factoryResetDescription,
              textAlign: TextAlign.start,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          if (isFactoryReset && !isConnected) ...[
            SizedBox(height: layout.resetDeviceDialog.textToTextDistance),
            const NoInternetErrorMessage(),
          ],
          SizedBox(height: layout.resetDeviceDialog.titleToImageDistance),
          RadioField(
            leading: const Icon(AbiliaIcons.delete),
            value: ResetType.clearData,
            groupValue: state.resetType,
            text: Text(translate.clearData),
            onChanged: (type) => _onResetTypeChanged(context, type),
          ),
          SizedBox(height: layout.resetDeviceDialog.descriptionPadding),
          Tts(
            child: Text(
              translate.clearDataDescription,
              style: Theme.of(context).textTheme.bodyMedium,
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
        onPressed:
            onNextClickable ? () => _onNext(context, state.resetType) : null,
      ),
    );
  }

  void _onResetTypeChanged(
    BuildContext context,
    ResetType? resetType,
  ) =>
      context.read<ResetDeviceCubit>().setResetType(resetType);

  void _onNext(BuildContext context, ResetType? resetType) {
    if (resetType == ResetType.factoryReset) {
      return _nextPage();
    } else if (resetType == ResetType.clearData) {
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
