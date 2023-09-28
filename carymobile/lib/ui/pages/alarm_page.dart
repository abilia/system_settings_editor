import 'package:calendar_events/calendar_events.dart';
import 'package:carymessenger/ui/pages/widgets/abilia_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AlarmPage extends StatelessWidget {
  const AlarmPage(
      {required this.activityDay, required this.providers, super.key});
  final ActivityDay activityDay;
  final List<BlocProvider> providers;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: providers,
      child: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Spacer(),
                if (activityDay.hasImage) AbiliaImage(activityDay.image),
                if (activityDay.activity.hasTitle) Text(activityDay.title),
                const Spacer(),
                FilledButton(
                  child: const Text('Close'),
                  onPressed: () async => Navigator.of(context).maybePop(),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
