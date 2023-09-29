import 'package:calendar_events/calendar_events.dart';
import 'package:carymessenger/bloc/alarm_page_bloc.dart';
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
      providers: [
        ...providers,
        BlocProvider(create: (context) => AlarmPageBloc(activityDay)),
      ],
      child: const AlarmPageListeners(
        child: AlarmPageContent(),
      ),
    );
  }
}

class AlarmPageListeners extends StatelessWidget {
  final Widget child;
  const AlarmPageListeners({required this.child, super.key});

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (_) =>
          context.read<AlarmPageBloc>().add(AlarmPageTouchedEvent()),
      child: BlocListener<AlarmPageBloc, AlarmPageState>(
        listenWhen: (previous, current) => current is CloseAlarmPage,
        listener: (BuildContext context, AlarmPageState state) async =>
            Navigator.of(context).maybePop(),
        child: child,
      ),
    );
  }
}

class AlarmPageContent extends StatelessWidget {
  const AlarmPageContent({super.key});

  @override
  Widget build(BuildContext context) {
    final activity =
        context.select((AlarmPageBloc bloc) => bloc.state.activity);
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              if (activity.hasImage) AbiliaImage(activity.image),
              if (activity.activity.hasTitle) Text(activity.title),
              const Spacer(),
              FilledButton(
                child: const Text('Close'),
                onPressed: () async => Navigator.of(context).maybePop(),
              )
            ],
          ),
        ),
      ),
    );
  }
}
