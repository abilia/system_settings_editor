import 'package:memoplanner/bloc/all.dart';
import 'package:memoplanner/models/settings/speech_support/voice_data.dart';
import 'package:memoplanner/ui/all.dart';

class VoicesPage extends StatelessWidget {
  const VoicesPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final translate = Lt.of(context);
    final scrollController = ScrollController();

    return Scaffold(
      appBar: AbiliaAppBar(
        title: translate.voices,
        label: translate.textToSpeech,
        iconData: AbiliaIcons.speakText,
      ),
      body: Builder(builder: (context) {
        final voicesState = context.watch<VoicesCubit>().state;
        final selectedVoice =
            context.select((SpeechSettingsCubit c) => c.state.voice);

        return voicesState is VoicesLoading
            ? const Center(child: AbiliaProgressIndicator())
            : Padding(
                padding:
                    layout.templates.m1.withoutBottom - m1ItemPadding.onlyTop,
                child: ScrollArrows.vertical(
                  controller: scrollController,
                  child: ListView(
                    controller: scrollController,
                    children: voicesState.available.map((VoiceData voice) {
                      final name = voice.name;
                      return _VoiceRow(
                        voice: voice,
                        downloaded: voicesState.downloaded.contains(name),
                        downloading: voicesState.downloading.contains(name),
                        selectedVoice: selectedVoice,
                      );
                    }).toList(),
                  ),
                ),
              );
      }),
      bottomNavigationBar: BottomNavigation(
        backNavigationWidget: OkButton(
          onPressed: () async => Navigator.of(context).maybePop(),
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
    required this.voice,
    required this.selectedVoice,
    this.downloaded = false,
    this.downloading = false,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final SpeechSupportPageLayout pageLayout = layout.speechSupportPage;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        if (downloaded)
          IconActionButtonDark(
            onPressed: () async =>
                context.read<VoicesCubit>().deleteVoice(voice),
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
                  ? (name) async =>
                      context.read<SpeechSettingsCubit>().setVoice(voice.name)
                  : null,
              value: voice.name,
              text: Text('${voice.name}: ${voice.file.sizeInMB} MB'),
            ),
          ),
        ),
      ],
    ).pad(m1ItemPadding.onlyVertical);
  }
}
