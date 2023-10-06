import 'package:carymessenger/cubit/production_guide_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:permissions/permission_cubit.dart';
import 'package:text_to_speech/voices_cubit.dart';

class ProductionGuidePage extends StatelessWidget {
  const ProductionGuidePage({super.key});

  @override
  Widget build(BuildContext context) {
    final productionGuideCubit = context.watch<ProductionGuideCubit>();
    final batteryOptimizationGranted = context.select((PermissionCubit cubit) =>
        cubit.state.status[Permission.ignoreBatteryOptimizations]?.isGranted ==
        true);
    final voiceIsDownloaded = context.select(
      (VoicesCubit cubit) => cubit.state.downloaded.isNotEmpty,
    );
    return Scaffold(
      body: SafeArea(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (!batteryOptimizationGranted) const BatteryOptimizationButton(),
          if (!voiceIsDownloaded) const Expanded(child: Voices()),
          FilledButton(
            onPressed: batteryOptimizationGranted && voiceIsDownloaded
                ? productionGuideCubit.setDone
                : null,
            child: const Text('Done'),
          ),
        ],
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
    final voicesState = voicesCubit.state;
    final swedish = voicesState.availableByLanguage['sv']?.toList() ?? [];
    final downloadning = voicesState.downloading;
    final isDownloadning = voicesState.downloading.isNotEmpty;

    return ListView.builder(
      itemCount: swedish.length,
      itemBuilder: (context, index) {
        final v = swedish[index];
        return TextButton(
          onPressed:
              isDownloadning ? null : () async => voicesCubit.downloadVoice(v),
          child: Row(
            children: [
              if (downloadning.contains(v.name))
                const CircularProgressIndicator()
              else
                const Icon(Icons.download),
              Text(
                  '${v.name} ${v.lang}-${v.countryCode} ${v.file.sizeInMB} MB'),
            ],
          ),
        );
      },
    );
  }
}
