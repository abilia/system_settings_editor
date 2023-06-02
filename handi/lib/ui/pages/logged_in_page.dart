import 'dart:async';

import 'package:abilia_sync/abilia_sync.dart';
import 'package:auth/auth.dart';
import 'package:calendar_events/calendar_events.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:generics/generics.dart';
import 'package:sortables/sortables.dart';
import 'package:user_files/user_files.dart';

class LoggedInPage extends StatefulWidget {
  final Authenticated authenticated;

  const LoggedInPage({
    required this.authenticated,
    super.key,
  });

  @override
  State<LoggedInPage> createState() => _LoggedInPageState();
}

class _LoggedInPageState extends State<LoggedInPage> {
  List<Activity> activities = [];
  List<Generic> generics = [];
  List<Sortable> sortables = [];
  List<UserFile> userFiles = [];

  Future<void> _fetchActivities(BuildContext context) async {
    final activities = await context
        .read<ActivitiesBloc>()
        .activityRepository
        .allAfter(DateTime.now());
    setState(() => this.activities = activities.toList());
  }

  Future<void> _fetchGenerics(BuildContext context) async {
    final generics =
        await context.read<GenericCubit>().genericRepository.getAll();
    setState(() => this.generics = generics.toList());
  }

  Future<void> _fetchSortables(BuildContext context) async {
    final sortables =
        await context.read<SortableBloc>().sortableRepository.getAll();
    setState(() => this.sortables = sortables.toList());
  }

  Future<void> _fetchUserFiles(BuildContext context) async {
    final userFiles = await context
        .read<UserFileBloc>()
        .userFileRepository
        .getAllLoadedFiles();
    setState(() => this.userFiles = userFiles.toList());
  }

  @override
  void initState() {
    super.initState();
    unawaited(_fetchActivities(context));
    unawaited(_fetchGenerics(context));
    unawaited(_fetchSortables(context));
    unawaited(_fetchUserFiles(context));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ActivitiesBloc, ActivitiesChanged>(
      listener: (context, _) async => _fetchActivities(context),
      child: BlocListener<GenericCubit, GenericState>(
        listener: (context, _) async => _fetchGenerics(context),
        child: BlocListener<SortableBloc, SortableState>(
          listener: (context, _) async => _fetchSortables(context),
          child: BlocListener<UserFileBloc, UserFileState>(
            listener: (context, _) async => _fetchUserFiles(context),
            child: Scaffold(
              body: BlocListener<PushCubit, RemoteMessage>(
                listener: (context, message) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Push received ${message.data}'),
                    ),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 100),
                      Center(child: Text('${widget.authenticated.user}')),
                      const SizedBox(height: 100),
                      Center(child: Text('''
Upcoming activities: ${activities.length}
Generics: ${generics.length}
Sortables: ${sortables.length}
Loaded user files: ${userFiles.length}
                      ''')),
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
            ),
          ),
        ),
      ),
    );
  }
}
