import 'package:abilia_sync/abilia_sync.dart';
import 'package:auth/auth.dart';
import 'package:carymessenger/l10n/generated/l10n.dart';
import 'package:carymessenger/ui/abilia_icons.dart';
import 'package:carymessenger/ui/components/buttons/action.dart';
import 'package:carymessenger/ui/components/cary_app_bar.dart';
import 'package:carymessenger/ui/components/cary_bottom_bar.dart';
import 'package:carymessenger/ui/components/myabilia_icon.dart';
import 'package:carymessenger/ui/themes/colors.dart';
import 'package:carymessenger/ui/themes/theme.dart';
import 'package:carymessenger/ui/widgets/buttons/back_button.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import 'package:repository_base/db.dart';
import 'package:transparent_image/transparent_image.dart';

part 'logout_button.dart';
part 'profile_picture.dart';

class MyAbiliaPage extends StatelessWidget {
  const MyAbiliaPage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = GetIt.I<UserDb>().getUser();

    return Scaffold(
      appBar: CaryAppBar(
        topPadding: MediaQuery.paddingOf(context).top,
        title: 'myAbilia',
        icon: const MyAbiliaIcon(),
      ),
      bottomNavigationBar: const CaryBottomBar(child: CaryBackButton()),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16.0),
        child: Column(
          children: [
            if (user != null) ...[
              ProfilePicture(user: user),
              const SizedBox(height: 24),
              Text(user.name, style: headlineSmall),
              const SizedBox(height: 8),
              Text(user.username, style: heading),
            ],
            const Spacer(),
            const LastSyncText(),
            const SizedBox(height: 8),
            const LogoutButton(),
          ],
        ),
      ),
    );
  }
}

class LastSyncText extends StatelessWidget {
  const LastSyncText({super.key});

  @override
  Widget build(BuildContext context) {
    final lastSyncedTime = context.watch<SyncBloc>().state.lastSynced;
    final lastSync = lastSyncedTime != null
        ? DateFormat.yMd().add_jm().format(lastSyncedTime)
        : '?';
    return GestureDetector(
      onTap: () => context.read<SyncBloc>().add(const SyncAll()),
      child: Text(
        '${Lt.of(context).last_sync} $lastSync',
        style: grey,
      ),
    );
  }
}
