import 'package:seagull/bloc/all.dart';
import 'package:seagull/ui/all.dart';
import 'package:seagull/utils/all.dart';

class PermissionPickField extends StatelessWidget {
  const PermissionPickField({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PermissionCubit, PermissionState>(
      builder: (context, state) => Stack(
        children: [
          PickField(
            leading: const Icon(AbiliaIcons.menuSetup),
            text: Text(Translator.of(context).translate.permissions),
            onTap: () async {
              final authProviders = copiedAuthProviders(context);
              context.read<PermissionCubit>().checkAll();
              await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => MultiBlocProvider(
                    providers: authProviders,
                    child: const PermissionsPage(),
                  ),
                  settings: const RouteSettings(name: 'PermissionPage'),
                ),
              );
            },
          ),
          if (state.importantPermissionMissing)
            Positioned(
              top: layout.settings.permissionsDotPosition,
              right: layout.settings.permissionsDotPosition,
              child: const OrangeDot(),
            ),
        ],
      ),
    );
  }
}
