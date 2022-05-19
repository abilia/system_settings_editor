import 'package:seagull/bloc/all.dart';
import 'package:seagull/ui/all.dart';

class TextToSpeechSwitch extends StatelessWidget {
  const TextToSpeechSwitch({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsCubit, SettingsState>(
      builder: (context, settingsState) => Row(children: [
        Expanded(
          child: SwitchField(
            value: settingsState.textToSpeech,
            leading: const Icon(AbiliaIcons.speakText),
            onChanged: context.read<SettingsCubit>().setTextToSpeech,
            child: Text(Translator.of(context).translate.textToSpeech),
          ),
        ),
        Padding(
          padding: layout.settings.textToSpeechPadding,
          child: InfoButton(
            onTap: () => showViewDialog(
              useSafeArea: false,
              context: context,
              builder: (context) => const LongPressInfoDialog(),
            ),
          ),
        ),
      ]),
    );
  }
}
