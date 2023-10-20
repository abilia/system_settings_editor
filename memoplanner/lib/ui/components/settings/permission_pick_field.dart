import 'package:memoplanner/bloc/all.dart';
import 'package:memoplanner/ui/all.dart';
import 'package:memoplanner/utils/all.dart';

class PermissionPickField extends StatelessWidget {
  const PermissionPickField({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PermissionCubit, PermissionState>(
      builder: (context, state) => Stack(
        children: [
          PickField(
            leading: const Icon(AbiliaIcons.menuSetup),
            text: Text(Lt.of(context).permissions),
            onTap: () async {
              final authProviders = copiedAuthProviders(context);
              await Future.wait([
                context.read<PermissionCubit>().checkAll(),
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => MultiBlocProvider(
                      providers: authProviders,
                      child: const PermissionsPage(),
                    ),
                    settings: (PermissionsPage).routeSetting(),
                  ),
                ),
              ]);
            },
          ),
          if (state.importantPermissionMissing)
            Positioned(
              top: layout.settings.permissionsDotPosition,
              right: layout.settings.permissionsDotPosition,
              child: const OrangePermissioinDot(),
            ),
        ],
      ),
    );
  }
}
