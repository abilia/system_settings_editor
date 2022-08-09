import 'package:seagull/bloc/all.dart';
import 'package:seagull/models/settings/all.dart';
import 'package:seagull/ui/all.dart';
import 'package:seagull/utils/all.dart';

class MenuSettingsPage extends StatelessWidget {
  const MenuSettingsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final t = Translator.of(context).translate;
    final initial = context.read<MemoplannerSettingBloc>().state.settings.menu;
    return BlocProvider<MenuSettingsCubit>(
      create: (context) => MenuSettingsCubit(
        initial,
        context.read<GenericCubit>(),
      ),
      child: BlocBuilder<MenuSettingsCubit, MenuSettings>(
        builder: (context, state) {
          return SettingsBasePage(
            icon: AbiliaIcons.appMenu,
            title: Translator.of(context).translate.menu,
            label:
                Config.isMP ? Translator.of(context).translate.settings : null,
            bottomNavigationBar: BottomNavigation(
              backNavigationWidget: const CancelButton(),
              forwardNavigationWidget: Builder(
                builder: (context) => OkButton(
                  onPressed: () async {
                    final menuSetttingsCubit =
                        context.read<MenuSettingsCubit>();
                    final showSettingsChangeToDisable = initial.showSettings &&
                        !menuSetttingsCubit.state.showSettings;
                    final navigator = Navigator.of(context);
                    if (showSettingsChangeToDisable) {
                      final answer = await showViewDialog<bool>(
                        context: context,
                        builder: (context) => YesNoDialog(
                          heading: t.menu,
                          text: t.menuRemovalWarning,
                        ),
                      );
                      if (answer != true) return;
                    }
                    menuSetttingsCubit.save();
                    navigator.pop();
                  },
                ),
              ),
            ),
            widgets: [
              SwitchField(
                leading: const Icon(AbiliaIcons.cameraPhoto),
                value: state.showCamera,
                onChanged: (v) => context
                    .read<MenuSettingsCubit>()
                    .change(state.copyWith(showCamera: v)),
                child: Text(t.camera),
              ),
              SwitchField(
                leading: const Icon(AbiliaIcons.myPhotos),
                value: state.showPhotos,
                onChanged: (v) => context
                    .read<MenuSettingsCubit>()
                    .change(state.copyWith(showPhotos: v)),
                child: Text(t.myPhotos),
              ),
              SwitchField(
                leading: const Icon(AbiliaIcons.photoCalendar),
                value: state.showPhotoCalendar,
                onChanged: (v) => context
                    .read<MenuSettingsCubit>()
                    .change(state.copyWith(showPhotoCalendar: v)),
                child: Text(t.photoCalendar.singleLine),
              ),
              SwitchField(
                leading: const Icon(AbiliaIcons.favoritesShow),
                value: state.showTemplates,
                onChanged: (v) => context
                    .read<MenuSettingsCubit>()
                    .change(state.copyWith(showTemplates: v)),
                child: Text(t.templates.singleLine),
              ),
              SwitchField(
                leading: const Icon(AbiliaIcons.menuSetup),
                value: state.showQuickSettings,
                onChanged: (v) => context
                    .read<MenuSettingsCubit>()
                    .change(state.copyWith(showQuickSettings: v)),
                child: Text(t.quickSettingsMenu.singleLine),
              ),
              SwitchField(
                leading: const Icon(AbiliaIcons.settings),
                value: state.showSettings,
                onChanged: (v) => context
                    .read<MenuSettingsCubit>()
                    .change(state.copyWith(showSettings: v)),
                child: Text(t.settings),
              ),
            ],
          );
        },
      ),
    );
  }
}
