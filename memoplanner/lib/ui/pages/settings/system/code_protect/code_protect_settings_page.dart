import 'package:memoplanner/bloc/all.dart';
import 'package:memoplanner/models/settings/all.dart';
import 'package:memoplanner/ui/all.dart';

import 'package:memoplanner/ui/pages/settings/system/code_protect/change_code_protect_page.dart';

class CodeProtectSettingsPage extends StatelessWidget {
  const CodeProtectSettingsPage({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final translate = Translator.of(context).translate;
    final settings = context.read<MemoplannerSettingsBloc>().state;

    return BlocProvider(
      create: (context) => CodeProtectCubit(
        context.read<GenericCubit>(),
        settings.codeProtect,
      ),
      child: BlocBuilder<CodeProtectCubit, CodeProtectSettings>(
        builder: (context, state) {
          return SettingsBasePage(
            icon: AbiliaIcons.numericKeyboard,
            title: translate.codeProtect,
            label: Config.isMP ? translate.system : null,
            widgets: [
              SubHeading(translate.code),
              PickField(
                  text: Text(state.code),
                  onTap: () async {
                    final codeProtect = context.read<CodeProtectCubit>();
                    final newCode = await Navigator.of(context).push<String>(
                      MaterialPageRoute(
                        builder: (_) => const ChangeCodeProtectPage(),
                        settings:
                            const RouteSettings(name: 'ChangeCodeProtectPage'),
                      ),
                    );
                    if (newCode != null) {
                      codeProtect.change(state.copyWith(code: newCode));
                    }
                  }),
              SizedBox(height: layout.formPadding.verticalItemDistance),
              const Divider(),
              SizedBox(height: layout.formPadding.verticalItemDistance),
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
                leading: const Icon(AbiliaIcons.android),
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
