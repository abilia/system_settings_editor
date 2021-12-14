import 'package:get_it/get_it.dart';
import 'package:http/http.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/repository/all.dart';
import 'package:seagull/ui/all.dart';

class BackendSwitchesDialog extends StatelessWidget {
  const BackendSwitchesDialog({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return ViewDialog(
      heading: const AppBarHeading(
        text: 'Switch backend',
        iconData: AbiliaIcons.oneDrive,
      ),
      body: Column(
        children: [
          BlocBuilder<AuthenticationBloc, AuthenticationState>(
            builder: (context, state) => Wrap(
              spacing: 8.s,
              children: [
                ...backEndEnvironments.entries.map(
                  (kvp) => BackEndButton(
                    kvp.key,
                    userRepository: state.userRepository,
                    client: GetIt.I<BaseClient>(),
                    backEndUrl: kvp.value,
                  ),
                )
              ],
            ),
          ),
          SizedBox(height: 8.s),
          const Version(),
        ],
      ),
      backNavigationWidget: OkButton(onPressed: Navigator.of(context).maybePop),
    );
  }
}

class BackEndButton extends StatelessWidget {
  final UserRepository userRepository;
  final BaseClient client;

  final String backEndUrl;
  final String text;

  const BackEndButton(
    this.text, {
    required this.userRepository,
    required this.backEndUrl,
    required this.client,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    onTap() => context.read<AuthenticationBloc>().add(
          ChangeRepository(
            userRepository.copyWith(
              client: client,
              baseUrl: backEndUrl,
            ),
          ),
        );
    return GestureDetector(
      onTap: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: 24.s,
            child: FittedBox(
              child: Radio(
                groupValue: userRepository.baseUrl,
                value: backEndUrl,
                onChanged: (url) => onTap(),
              ),
            ),
          ),
          Text(text),
        ],
      ),
    );
  }
}
