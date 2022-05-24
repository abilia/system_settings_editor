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
            title: t.textToSpeech,
            label: t.system,
            iconData: AbiliaIcons.handiAlarmVibration,
          ),
          body: Padding(
            padding: layout.settingsBasePage.listPadding,
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
    return Padding(
      padding: layout.settingsBasePage.itemPadding,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          if (downloaded)
            IconActionButtonDark(
              onPressed: () => context.read<VoicesCubit>().deleteVoice(voice),
              child: const Icon(AbiliaIcons.deleteAllClear),
            ).pad(
              EdgeInsets.only(
                left: layout.formPadding.largeHorizontalItemDistance,
              ),
            )
          else if (downloading)
            SizedBox(
              width: layout.actionButton.size,
              height: layout.actionButton.size,
              child: Center(
                child: SizedBox(
                  width: pageLayout.loaderSize,
                  height: pageLayout.loaderSize,
                  child: CircularProgressIndicator(
                    strokeWidth: pageLayout.loaderStrokeWidth,
                    valueColor: const AlwaysStoppedAnimation(AbiliaColors.red),
                  ),
                ),
              ),
            ).pad(
              EdgeInsets.only(
                left: layout.formPadding.largeHorizontalItemDistance,
              ),
            )
          else
            IconActionButtonDark(
              child: const Icon(AbiliaIcons.download),
              onPressed: () async =>
                  await context.read<VoicesCubit>().downloadVoice(voice),
            ).pad(
              EdgeInsets.only(
                left: layout.formPadding.largeHorizontalItemDistance,
              ),
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
                        context
                            .read<SpeechSettingsCubit>()
                            .setVoice(voice.name);
                      }
                    : null,
                value: voice.name,
                text: Text('${voice.name}: ${voice.size}MB'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}