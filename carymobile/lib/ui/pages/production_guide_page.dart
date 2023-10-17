import 'package:carymessenger/ui/widgets/buttons/android_settings_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:permissions/permission_cubit.dart';
import 'package:text_to_speech/speech_settings_cubit.dart';
import 'package:text_to_speech/voices_cubit.dart';

class ProductionGuidePage extends StatelessWidget {
  const ProductionGuidePage({super.key});

  @override
  Widget build(BuildContext context) {
    final batteryOptimizationGranted = context.select((PermissionCubit cubit) =>
        cubit.state.status[Permission.ignoreBatteryOptimizations]?.isGranted ==
        true);
    return Scaffold(
      body: SafeArea(
          child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Expanded(child: Voices()),
            if (!batteryOptimizationGranted) const BatteryOptimizationButton(),
            const SizedBox(height: 8),
            const AndroidSettingsButton(),
            const SizedBox(height: 8),
          ],
        ),
      )),
    );
  }
}

class BatteryOptimizationButton extends StatelessWidget {
  const BatteryOptimizationButton({super.key});

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: () async => context
          .read<PermissionCubit>()
          .request([Permission.ignoreBatteryOptimizations]),
      child: const Text('Allow Ignore battery optimization'),
    );
  }
}

class Voices extends StatelessWidget {
  const Voices({super.key});

  @override
  Widget build(BuildContext context) {
    final voicesCubit = context.watch<VoicesCubit>();
    final selectedVoice =
        context.select((SpeechSettingsCubit cubit) => cubit.state.voice);
    final voicesState = voicesCubit.state;
    final swedish = voicesState.availableByLanguage['sv']?.toList() ?? [];
    final downloaded = voicesState.downloaded;
    final downloading = voicesState.downloading;
    final isDownloading = voicesState.downloading.isNotEmpty;

    return ListView.builder(
      itemCount: swedish.length,
      itemBuilder: (context, index) {
        final voice = swedish[index];
        final isDownloadingVoice = downloading.contains(voice.name);
        final voiceIsDownloaded = downloaded.contains(voice.name);
        final isSelectedVoice = selectedVoice == voice.name;
        return TextButton(
          onPressed: isDownloading || voiceIsDownloaded
              ? null
              : () async => voicesCubit.downloadVoice(voice),
          child: Row(
            children: [
              if (isDownloadingVoice)
                const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(),
                )
              else if (isSelectedVoice)
                const Icon(Icons.done_all)
              else if (voiceIsDownloaded)
                const Icon(Icons.check)
              else
                const Icon(Icons.download),
              const SizedBox(width: 8),
              Text(
                  '${voice.name} ${voice.lang}-${voice.countryCode} ${voice.file.sizeInMB} MB'),
            ],
          ),
        );
      },
    );
  }
}
