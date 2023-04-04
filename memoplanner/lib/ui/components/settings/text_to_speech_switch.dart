import 'package:memoplanner/bloc/all.dart';
import 'package:memoplanner/ui/all.dart';

class TextToSpeechSwitch extends StatelessWidget {
  const TextToSpeechSwitch({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SpeechSettingsCubit, SpeechSettingsState>(
      builder: (context, settingsState) => Row(
        children: [
          Expanded(
            child: SwitchField(
              value: settingsState.textToSpeech,
              leading: const Icon(AbiliaIcons.speakText),
              onChanged: context.read<SpeechSettingsCubit>().setTextToSpeech,
              child: Text(Translator.of(context).translate.textToSpeech),
            ),
          ),
          SizedBox(width: layout.formPadding.horizontalItemDistance),
          InfoButton(
            onTap: () async => showViewDialog(
              useSafeArea: false,
              context: context,
              builder: (context) => const LongPressInfoDialog(),
              routeSettings: (LongPressInfoDialog).routeSetting(),
            ),
          ),
        ],
      ),
    );
  }
}
