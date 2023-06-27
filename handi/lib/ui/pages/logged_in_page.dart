import 'package:abilia_sync/abilia_sync.dart';
import 'package:auth/auth.dart';
import 'package:calendar_events/calendar_events.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:generics/generics.dart';
import 'package:handi/bloc/settings_cubit.dart';
import 'package:handi/l10n/generated/l10n.dart';
import 'package:handi/ui/components/tts.dart';
import 'package:sortables/sortables.dart';
import 'package:support_persons/bloc/support_persons_cubit.dart';
import 'package:ui/buttons/link_button.dart';
import 'package:user_files/user_files.dart';

class LoggedInPage extends StatelessWidget {
  final Authenticated authenticated;

  const LoggedInPage({
    required this.authenticated,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final sortables = context.select((SortableBloc sortables) {
      final state = sortables.state;
      return state is SortablesLoaded ? state.sortables.length : 0;
    });
    final generics = context.select((GenericCubit generics) {
      final state = generics.state;
      return state is GenericsLoaded ? state.generics.length : 0;
    });
    final userFiles = context
        .select((UserFileBloc userFiles) => userFiles.state.userFiles.length);
    final supportPersons = context.select(
        (SupportPersonsCubit cubit) => cubit.state.supportPersons.length);
    final tts = context.select(
        (SettingsCubit settingsCubit) => settingsCubit.state.textToSpeech);

    final hasSynced = context.select((SyncBloc bloc) => bloc.hasSynced);
    final translate = Lt.of(context);
    return Scaffold(
      body: BlocListener<PushCubit, RemoteMessage>(
        listener: (context, message) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${translate.pushReceived} ${message.data}'),
            ),
          );
        },
        child: !hasSynced
            ? const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation(Colors.blue),
                ),
              )
            : Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 100),
                    Center(
                      child: Tts(
                        child: Text('${authenticated.user}'),
                      ),
                    ),
                    const SizedBox(height: 100),
                    Column(
                      children: [
                        FutureBuilder(
                          future: context
                              .read<ActivitiesBloc>()
                              // ignore: discarded_futures
                              .getActivitiesAfter(DateTime.now()),
                          builder: (context, snapshot) {
                            final activities = snapshot.data?.where(
                                    (activity) => activity.startTime
                                        .isAfter(DateTime.now())) ??
                                [];

                            return Text(
                                '${translate.upcomingActivities}: ${activities.length}');
                          },
                        ),
                        Text('${translate.generics}: $generics'),
                        Text('${translate.sortables}: $sortables'),
                        Text('${translate.userFiles}: $userFiles'),
                        Text('${translate.supportPersons}: $supportPersons'),
                      ],
                    ),
                    const Spacer(),
                    Center(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(translate.textToSpeech),
                          Switch(
                            value: tts,
                            onChanged: context.read<SettingsCubit>().setTts,
                          ),
                        ],
                      ),
                    ),
                    LinkButton(
                      onPressed: () =>
                          context.read<SyncBloc>().add(const SyncAll()),
                      title: translate.sync,
                    ),
                    LinkButton(
                      onPressed: () => context
                          .read<AuthenticationBloc>()
                          .add(const LoggedOut()),
                      title: translate.logOut,
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
