import 'package:flutter/services.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/repository/all.dart';
import 'package:seagull/ui/all.dart';
import 'package:seagull/utils/all.dart';

class StartGuidePage extends StatelessWidget {
  const StartGuidePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final serialIdController = TextEditingController();
    return MaterialApp(
      theme: abiliaTheme,
      home: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(32),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const _FancyHeader(text: 'Welcome to the start guide!'),
                const SizedBox(height: 50),
                if (!Config.release) const _DebugRow(),
                const SizedBox(height: 50),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: serialIdController,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Serial number',
                        ),
                      ),
                    ),
                    const SizedBox(width: 20),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const ElevatedButton(
                            onPressed: AndroidIntents.openDeviceInfoSettings,
                            child: Text('Fetch from settings')),
                        ElevatedButton(
                            onPressed: () =>
                                Clipboard.getData(Clipboard.kTextPlain).then(
                                    (value) => serialIdController.text =
                                        value?.text ?? ''),
                            child: const Text('Paste from clipboard')),
                      ],
                    )
                  ],
                ),
                const SizedBox(height: 50),
                TextButton(
                  onPressed: () => context
                      .read<StartGuideCubit>()
                      .verifySerialId(serialIdController.text),
                  child: const Text('Verify'),
                  style: textButtonStyleGreen,
                ),
                BlocBuilder<StartGuideCubit, StartGuideState>(
                  builder: (context, startGuideState) =>
                      startGuideState is VerifySerialIdFailed
                          ? Text(startGuideState.message)
                          : const Text(''),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DebugRow extends StatelessWidget {
  const _DebugRow({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BaseUrlCubit, String>(
      builder: (context, baseUrl) => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton(
                  onPressed: () =>
                      context.read<StartGuideCubit>().skipStartGuide(),
                  child: const Text('Skip start guide'))
              .pad(const EdgeInsets.only(right: 20)),
          ElevatedButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => const BackendSwitchesDialog(),
              );
            },
            child: Text('Switch backend (${backendEnvironments[baseUrl]})'),
          )
        ],
      ),
    );
  }
}

class _FancyHeader extends StatelessWidget {
  const _FancyHeader({
    Key? key,
    required this.text,
  }) : super(key: key);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Text(
          text,
          style: TextStyle(
            fontSize: 40,
            foreground: Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = 6
              ..color = Colors.blue[700]!,
          ),
        ),
        Text(
          text,
          style: TextStyle(
            fontSize: 40,
            color: Colors.grey[300],
          ),
        ),
      ],
    );
  }
}
