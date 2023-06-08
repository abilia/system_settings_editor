import 'package:abilia_sync/abilia_sync.dart';
import 'package:auth/auth.dart';
import 'package:calendar_events/calendar_events.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:generics/generics.dart';
import 'package:sortables/sortables.dart';
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

    final hasSynced = context.select((SyncBloc bloc) => bloc.hasSynced);
    return Scaffold(
      body: BlocListener<PushCubit, RemoteMessage>(
        listener: (context, message) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Push received ${message.data}'),
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
                    Center(child: Text('${authenticated.user}')),
                    const SizedBox(height: 100),
                    FutureBuilder(
                      future: context
                          .read<ActivitiesBloc>()
                          // ignore: discarded_futures
                          .getActivitiesAfter(DateTime.now()),
                      builder: (context, snapshot) {
                        final activities = snapshot.data?.where((activity) =>
                                activity.startTime.isAfter(DateTime.now())) ??
                            [];

                        return Text(
                            'Upcoming activities: ${activities.length}');
                      },
                    ),
                    Text('Generics: $generics'),
                    Text('Sortables: $sortables'),
                    Text('User files: $userFiles'),
                    const Spacer(),
                    OutlinedButton(
                      onPressed: () =>
                          context.read<SyncBloc>().add(const SyncAll()),
                      child: const Text('Sync'),
                    ),
                    OutlinedButton(
                      onPressed: () => context
                          .read<AuthenticationBloc>()
                          .add(const LoggedOut()),
                      child: const Text('Log out'),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
