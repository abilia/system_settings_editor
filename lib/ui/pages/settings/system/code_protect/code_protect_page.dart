import 'package:seagull/bloc/all.dart';
import 'package:seagull/models/settings/all.dart';
import 'package:seagull/ui/all.dart';

import 'package:seagull/ui/pages/settings/system/code_protect/change_code_protect_page.dart';

class CodeProtectPage extends StatelessWidget {
  const CodeProtectPage({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final translate = Translator.of(context).translate;

    return BlocProvider(
      create: (context) => CodeProtectCubit(
        context.read<GenericBloc>(),
        context.read<MemoplannerSettingBloc>().state.settings.codeProtect,
      ),
      child: BlocBuilder<CodeProtectCubit, CodeProtectSettings>(
        builder: (context, state) {
          return SettingsBasePage(
            icon: AbiliaIcons.numericKeyboard,
            title: Translator.of(context).translate.codeProtect,
            widgets: [
              SubHeading(translate.code),
              PickField(
                  text: Text(state.code),
                  onTap: () async {
                    final newCode = await Navigator.of(context).push<String>(
                      MaterialPageRoute(
                        builder: (_) => const ChangeCodeProtectPage(),
                        settings:
                            const RouteSettings(name: 'ChangeCodeProtectPage'),
                      ),
                    );
                    if (newCode != null) {
                      context
                          .read<CodeProtectCubit>()
                          .change(state.copyWith(code: newCode));
                    }
                  }),
              SizedBox(height: 8.s),
              const Divider(),
              SizedBox(height: 8.s),
              SwitchField(
                leading: const Icon(AbiliaIcons.settings),
                value: state.protectSettings,
                onChanged: (v) => context
                    .read<CodeProtectCubit>()
                    .change(state.copyWith(protectSettings: v)),
                child: Text(translate.codeProtectSettings),
              ),
              SwitchField(
                leading: const Icon(AbiliaIcons.fullScreen),
                value: state.protectCodeProtect,
                onChanged: (v) => context
                    .read<CodeProtectCubit>()
                    .change(state.copyWith(protectCodeProtect: v)),
                child: Text(translate.codeProtectThisView),
              ),
              SwitchField(
                leading:
                    const Icon(AbiliaIcons.pastPictureFromWindowsClipboard),
                value: state.protectAndroidSettings,
                onChanged: (v) => context
                    .read<CodeProtectCubit>()
                    .change(state.copyWith(protectAndroidSettings: v)),
                child: Text(translate.codeProtectAndroidSettings),
              ),
            ],
            bottomNavigationBar: BottomNavigation(
              backNavigationWidget: const CancelButton(),
              forwardNavigationWidget: Builder(
                builder: (context) => OkButton(
                  onPressed: () {
                    context.read<CodeProtectCubit>().save();
                    Navigator.of(context).pop();
                  },
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
