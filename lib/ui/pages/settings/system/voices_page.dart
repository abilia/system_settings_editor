import 'package:seagull/bloc/all.dart';
import 'package:seagull/models/settings/speech_support/voice_data.dart';
import 'package:seagull/ui/all.dart';

class VoicesPage extends StatelessWidget {
  const VoicesPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final t = Translator.of(context).translate;
    final scrollController = ScrollController();
    return BlocBuilder<VoicesCubit, VoicesState>(
      builder: (context, state) =>
          BlocBuilder<SpeechSettingsCubit, SpeechSettingsState>(
        builder: (context, settingsState) => Scaffold(
          appBar: AbiliaAppBar(
            title: t.voices,
            label: t.textToSpeech,
            iconData: AbiliaIcons.speakText,
          ),
          body: Padding(
            padding: layout.templates.m1.withoutBottom - m1ItemPadding.onlyTop,
            child: ScrollArrows.vertical(
              controller: scrollController,
              child: ListView(
                controller: scrollController,
                children: state.available.map((VoiceData voice) {
                  final name = voice.name;
                  final selectedVoice = settingsState.voice;
                  return _VoiceRow(
                    voice: voice,
                    downloaded: state.downloaded.contains(name),
                    downloading: state.downloading.contains(name),
                    selectedVoice: selectedVoice,
                  );
                }).toList(),
              ),
            ),
          ),
          bottomNavigationBar: BottomNavigation(
            backNavigationWidget: OkButton(
              onPressed: () => Navigator.of(context).maybePop(),
            ),
          ),
        ),
      ),
    );
  }
}

class _VoiceRow extends StatelessWidget {
  final bool downloaded;
  final bool downloading;
  final VoiceData voice;
  final String selectedVoice;

  const _VoiceRow({
    Key? key,
    required this.voice,
    this.downloaded = false,
    this.downloading = false,
    required this.selectedVoice,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final SpeechSupportPageLayout pageLayout = layout.speechSupportPage;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        if (downloaded)
          IconActionButtonDark(
            onPressed: () => context.read<VoicesCubit>().deleteVoice(voice),
            child: const Icon(AbiliaIcons.deleteAllClear),
          )
        else if (downloading)
          SizedBox(
            width: layout.actionButton.size,
            height: layout.actionButton.size,
            child: Center(
              child: SizedBox(
                width: pageLayout.loaderSize,
                height: pageLayout.loaderSize,
                child: const AbiliaProgressIndicator(),
              ),
            ),
          )
        else
          IconActionButtonDark(
            child: const Icon(AbiliaIcons.download),
            onPressed: () async =>
                await context.read<VoicesCubit>().downloadVoice(voice),
          ),
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(
              left: layout.formPadding.largeHorizontalItemDistance,
            ),
            child: RadioField<String>(
              groupValue: selectedVoice,
              onChanged: downloaded
                  ? (name) {
                      context.read<SpeechSettingsCubit>().setVoice(voice.name);
                    }
                  : null,
              value: voice.name,
              text: Text('${voice.name}: ${voice.size}MB'),
            ),
          ),
        ),
      ],
    ).pad(m1ItemPadding.onlyVertical);
  }
}
