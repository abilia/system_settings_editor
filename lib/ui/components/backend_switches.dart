import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart';
import 'package:package_info/package_info.dart';
import 'package:seagull/bloc/all.dart';
import 'package:seagull/repository/all.dart';

class BackendSwitches extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthenticationBloc, AuthenticationState>(
        builder: (context, state) {
      return Center(
        child: Wrap(
          spacing: 16.0,
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
  Widget build(BuildContext context) => Column(
        children: [
          Text(text),
          Radio(
            groupValue: userRepository.baseUrl,
            value: backEndUrl,
            onChanged: (url) => context.bloc<AuthenticationBloc>().add(
                  ChangeRepository(
                    userRepository.copyWith(
                      client: client,
                      baseUrl: url,
                    ),
                  ),
                ),
          ),
        ],
      );
}

class VersionInfo extends StatelessWidget {
  final bool showUserId;
  const VersionInfo({
    Key key,
    this.showUserId = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: BlocBuilder<AuthenticationBloc, AuthenticationState>(
        builder: (context, state) {
          return Column(
            children: [
              FutureBuilder(
                future: PackageInfo.fromPlatform(),
                builder: (context, AsyncSnapshot<PackageInfo> snapshot) => Text(
                  '${snapshot?.data?.version ?? ''} (${snapshot?.data?.buildNumber ?? ''})',
                ),
              ),
              if (showUserId && state is Authenticated)
                Text(
                  '${state.userId} (${backEndEnviorments.map((key, value) => MapEntry(value, key))[state.userRepository.baseUrl]})',
                ),
            ],
          );
        },
      ),
    );
  }
}
