// @dart=2.9

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/repository/all.dart';
import 'package:seagull/ui/all.dart';
import 'package:seagull/utils/all.dart';

class BackendSwitchesDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ViewDialog(
      heading: AppBarHeading(
        text: 'Switch backend',
        iconData: AbiliaIcons.one_drive,
      ),
      body: BlocBuilder<AuthenticationBloc, AuthenticationState>(
        builder: (context, state) => Wrap(
          spacing: 8.s,
          children: [
            ...backEndEnviorments.entries.map(
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
    @required this.userRepository,
    this.backEndUrl,
    @required this.client,
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final onTap = () => context.read<AuthenticationBloc>().add(
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
