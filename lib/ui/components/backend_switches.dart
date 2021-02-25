import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/repository/all.dart';
import 'package:seagull/ui/all.dart';
import 'package:seagull/utils/all.dart';

class BackendSwitches extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthenticationBloc, AuthenticationState>(
        builder: (context, state) {
      return Center(
        child: Wrap(
          spacing: 16.0.s,
          children: backEndEnviorments.entries
              .map(
                (kvp) => BackEndButton(
                  kvp.key,
                  userRepository: state.userRepository,
                  client: GetIt.I<BaseClient>(),
                  backEndUrl: kvp.value,
                ),
              )
              .toList(),
        ),
      );
    });
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
    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          child: Text(text),
        ),
        SizedBox(height: 8.s),
        Transform.scale(
          scale: Device.scaleFactor,
          child: Radio(
            groupValue: userRepository.baseUrl,
            value: backEndUrl,
            onChanged: (url) => onTap(),
          ),
        ),
      ],
    );
  }
}
