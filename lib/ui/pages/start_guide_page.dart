import 'package:seagull/bloc/all.dart';
import 'package:seagull/ui/all.dart';
import 'package:seagull/utils/all.dart';

class StartGuidePage extends StatelessWidget {
  const StartGuidePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final serialIdController = TextEditingController();
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const _FancyHeader(text: 'Welcome to the start guide!'),
              const SizedBox(height: 50),
              if (!Config.release)
                ElevatedButton(
                    onPressed: () =>
                        context.read<StartGuideCubit>().skipStartGuide(),
                    child: const Text('Skip start guide')),
              const SizedBox(height: 50),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 300,
                    child: TextField(
                      controller: serialIdController,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Serial number',
                      ),
                    ),
                  ).pad(const EdgeInsets.only(right: 20)),
                  ElevatedButton(
                      onPressed: () {
                        AndroidIntents.openDeviceInfoSettings();
                      },
                      child: const Text('Fetch from settings')),
                ],
              ),
              const SizedBox(height: 50),
              ElevatedButton(
                onPressed: () => context
                    .read<StartGuideCubit>()
                    .verifySerialId(serialIdController.text),
                child: Text(
                  'Verify',
                  style: Theme.of(context)
                      .textTheme
                      .headline4
                      ?.copyWith(color: Colors.white),
                ),
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
